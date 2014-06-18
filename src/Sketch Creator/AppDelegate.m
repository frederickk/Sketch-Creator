//
//  AppDelegate.m
//  Sketch Creator
//
//  Created by Ken Frederick on 2014.06.07.
//  Copyright (c) 2014 Ken Frederick. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate


// ------------------------------------------------------------------------
// Properties
// ------------------------------------------------------------------------
@synthesize sketchName;
@synthesize sketchPath;   // *

@synthesize hasMouse;       // *
@synthesize hasTouch;       // *
@synthesize hasKeyboard;    // *
@synthesize hasDragdrop;    // *

@synthesize hasCss;         // *
@synthesize hasBrowser;     // *
@synthesize browserPopup; // *
@synthesize hasWarnings;    // *

// preferences
@synthesize prefs;



// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------
#pragma mark Methods-Init
- (id) init {
    // inits
    prefs = [[FPreferences alloc] init];
    bOverwrite = TRUE;

    // set default/placeholder values
    [[sketchName cell] setPlaceholderString:SKETCH_NAME];
    if ([prefs getString:@"sketchPath"] == nil) {
        [prefs setString:[NSString stringWithFormat:@"%@%@", NSHomeDirectory(), SKETCH_PATH] forKey:@"sketchPath"];
    }

    return self;
}

- (void) awakeFromNib {
    // populate browserPopup with appropriate app names
    NSString *html = [[NSBundle bundleForClass:[self class]]
                      pathForResource:@"template_base"
                      ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:html];
    browserBundleList = [self getAppBundlesFor:url];
    [browserPopup removeAllItems];
    [browserPopup addItemsWithTitles:[self getBundleAppNames:browserBundleList]];
}

- (void) applicationDidFinishLaunching: (NSNotification *)aNotification {
    // update UI with saved preferences
    [self updateWithPreferences];

    // set preferences
    [self setPreferences];
}


#pragma mark Methods-Quit

// ------------------------------------------------------------------------
- (void) onClose: (id)sender {
    [self setPreferences];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)theApplication {
    [self setPreferences];
    return YES;
}
- (IBAction) onQuit: (id)sender {
    [self setPreferences];
    exit(0);
}


#pragma mark Methods-create

// ------------------------------------------------------------------------
- (NSDictionary *) createTemplate: (NSString *)name {
    NSError *error;

    // the template files to build
    NSString *html = [[NSBundle bundleForClass:[self class]]
                      pathForResource:@"template_base"
                      ofType:@"html"];
    NSString *js = [[NSBundle bundleForClass:[self class]]
                    pathForResource:@"template_base"
                    ofType:@"js"];

    // the contents of the template files
    NSString *htmlContent = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:&error];
    NSString *jsContent   = [NSString stringWithContentsOfFile:js encoding:NSUTF8StringEncoding error:&error];


    // add events to contents
    if ([hasKeyboard state] == 1) {
        // keyboard
        NSString *jsKeyboard = [[NSBundle bundleForClass:[self class]]
                                pathForResource:@"template_keyboard"
                                ofType:@"js"];
        jsKeyboard = [NSString stringWithContentsOfFile:jsKeyboard encoding:NSUTF8StringEncoding error:&error];

        jsContent = [NSString stringWithFormat:@"%@%@", jsContent, jsKeyboard];
    }
    if ([hasMouse state] == 1) {
        // mouse
        NSString *jsMouse = [[NSBundle bundleForClass:[self class]]
                             pathForResource:@"template_mouse"
                             ofType:@"js"];
        jsMouse = [NSString stringWithContentsOfFile:jsMouse encoding:NSUTF8StringEncoding error:&error];

        jsContent = [NSString stringWithFormat:@"%@%@", jsContent, jsMouse];
    }
    if ([hasTouch state] == 1) {
        // touch
        NSString *jsTouch = [[NSBundle bundleForClass:[self class]]
                             pathForResource:@"template_touch"
                             ofType:@"js"];
        jsTouch = [NSString stringWithContentsOfFile:jsTouch encoding:NSUTF8StringEncoding error:&error];

        jsContent = [NSString stringWithFormat:@"%@%@", jsContent, jsTouch];
    }
    if ([hasDragdrop state] == 1) {
        // drag-drop
        NSString *htmlDragdrop = [[NSBundle bundleForClass:[self class]]
                                  pathForResource:@"template_dragdrop"
                                  ofType:@"html"];
        htmlDragdrop = [NSString stringWithContentsOfFile:htmlDragdrop encoding:NSUTF8StringEncoding error:&error];

        // replace instances ##dragdrop## with dragdrop
        htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"##dragdrop##"
                                                             withString:htmlDragdrop];

        NSString *jsDragdrop = [[NSBundle bundleForClass:[self class]]
                                pathForResource:@"template_dragdrop"
                                ofType:@"js"];
        jsDragdrop = [NSString stringWithContentsOfFile:jsDragdrop encoding:NSUTF8StringEncoding error:&error];

        jsContent = [NSString stringWithFormat:@"%@%@", jsContent, jsDragdrop];
    }
    else {
        htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"##dragdrop##"
                                                             withString:@""];
    }


    // replace instances ##filename## with name
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString:@"##filename##"
                                                         withString:name];
    jsContent = [jsContent stringByReplacingOccurrencesOfString:@"##filename##"
                                                     withString:name];

    CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
    NSString *date = [NSString stringWithFormat:@"%02d.%02d.%02d", currentDate.year, currentDate.month, currentDate.day];
    jsContent = [jsContent stringByReplacingOccurrencesOfString:@"##date##"
                                                     withString:date];

    if (error) {
        NSLog(@"Error reading file: %@", error);
    }

    return @{@"html":htmlContent, @"js":jsContent};
}

- (void) createStructure: (NSString *)filename
                withPath: (NSString *)path {
    // create the template content
    NSDictionary *content = [self createTemplate:filename];


    // create the directories
    path = [path stringByAppendingPathComponent:filename];
    NSString *sketchDirectory = [self createDirectory:filename
                                             withPath:path];

    if (bOverwrite) {
        // create the sub-directories
        // empty data directory
        [self createDirectory:filename
                     withPath:[path stringByAppendingPathComponent:@"data"]];
        // empty lib directory
        NSString *libDirectory = [self createDirectory:filename
                                              withPath:[path stringByAppendingPathComponent:@"lib"]];


        // move library/add-on files
        NSArray *libraries = [prefs getArray:@"libraries"];
        NSString *jsHtmlTag = @"";
        for ( NSMutableDictionary *item in libraries ) {
            NSNumber *isActive = [item valueForKey:@"active"];
            //            NSLog(@"isActive: %d", [isActive isEqual:[NSNumber numberWithBool:YES]]);
            if ([isActive isEqual:[NSNumber numberWithBool:YES]]) {
                // copy files
                NSString *filename = [[item valueForKey:@"name"] stringByDeletingPathExtension];

                NSString *filepath;
                // accomodate for the appropriate path of bundled
                // javascript libraries
                if ( [filename isEqualToString:@"p5.min"] || [filename isEqualToString:@"p5.dom"] ) {
                    filepath = [[NSBundle bundleForClass:[self class]]
                                         pathForResource:filename
                                                  ofType:@"js"];
                }
                else {
                    filepath = [item valueForKey:@"path"];
                }

                // copy files to path
                [self copyFile:filepath
                      withPath:[libDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@.js", filename]]];

                // update html
                jsHtmlTag = [jsHtmlTag stringByAppendingString:[NSString stringWithFormat:@"<script type=\"text/javascript\" src=\"./lib/%@.js\"></script>\r\t\t", filename]];
            }
        }

        // replace instances ##libraries## with <script..
        NSString *htmlContent = [[content objectForKey:@"html"]
                                 stringByReplacingOccurrencesOfString:@"##libraries##"
                                 withString:jsHtmlTag];

        // drag-drop is a special case
        if ([hasDragdrop state] == 1) {
            NSString *dragdrop = [[NSBundle bundleForClass:[self class]]
                                           pathForResource:@"FDrop.min" // this should match table value
                                                    ofType:@"js"];
            [self copyFile:dragdrop
                  withPath:[libDirectory stringByAppendingString:@"/FDrop.min.js"]];
        }


        // css
        if ([hasCss state] == 1) {
            // empty css directory
            NSString *cssDirectory = [self createDirectory:filename
                                                  withPath:[path stringByAppendingPathComponent:@"css"]];
            // move css files
            NSString *cssDefault = [[NSBundle bundleForClass:[self class]]
                                    pathForResource:@"default"
                                    ofType:@"css"];
            [self copyFile:cssDefault
                  withPath:[cssDirectory stringByAppendingString:@"/default.css"]];
        }


        // create the template files
        [self createFile:[filename stringByAppendingString:@".js"]
                withPath:sketchDirectory
             withContent:[content objectForKey:@"js"]];

        [self createFile:[filename stringByAppendingString:@".html"]
                withPath:sketchDirectory
             withContent:htmlContent];


        // open in browser
        if ([hasBrowser state] == 1 ) {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@/%@%@", sketchDirectory, filename, @".html"]];

            NSString *stringToSearch = [[browserPopup selectedItem] title];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", stringToSearch];
            NSString *result = @"";
            @try {
                result = [browserBundleList filteredArrayUsingPredicate:predicate][0];
            }
            @catch(NSException *exception) {
                NSLog(@"Error opening browser: %@", exception);
            }
            [self openBrowser:url with:result];

        }

    }

    // reset overwrite value
    bOverwrite = TRUE;
}


#pragma mark Methods-File-Handling

// ------------------------------------------------------------------------
- (NSString *) createDirectory: (NSString *)dirname
                      withPath: (NSString *)path {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dirSuccess = FALSE;

    // check if directory exists
    if ([fileManager fileExistsAtPath:path]) {
        // display overwrite warning
        if ([hasWarnings integerValue] == 0) {
            bOverwrite = [self warningPrompt:dirname];
        }
        if (bOverwrite) {
            [fileManager removeItemAtPath:path error:&error];
        }
    }
    if (![fileManager fileExistsAtPath:path] && bOverwrite) {
        dirSuccess = [fileManager createDirectoryAtPath:path
                            withIntermediateDirectories:NO
                                             attributes:nil
                                                  error:&error];
        if (!dirSuccess) {
            NSLog(@"Directory creation error: %@", error);
            path = nil;
        }
    }

    return path;
}

- (NSString *) createFile: (NSString *)filename
                 withPath: (NSString *)path
              withContent: (NSString *)content {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileSuccess = FALSE;

    NSString *file = [NSString stringWithFormat:@"%@/%@", path, filename];

    // check if file exists
    if (![fileManager fileExistsAtPath:file]) {
        fileSuccess = [content writeToFile:file
                                atomically:YES
                                  encoding:NSUTF8StringEncoding
                                     error:&error];

        if (!fileSuccess) {
            NSLog(@"File creation error: %@", error);
            file = nil;
        }
    }

    return file;
}

- (NSString *) copyFile: (NSString *)src
               withPath: (NSString *)dest {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL copySuccess = FALSE;

    // check if file exists
    if ([fileManager fileExistsAtPath:dest]) {
        [fileManager removeItemAtPath:dest error:&error];
    }
    copySuccess = [fileManager copyItemAtPath:src
                                       toPath:dest
                                        error:&error];

    if (!copySuccess) {
        NSLog(@"File copying error: %@", error);
        src = nil;
    }

    return src;
}

// ------------------------------------------------------------------------
//
// http://stackoverflow.com/questions/12796391/retrieve-all-app-bundle-identifiers-which-can-open-file-at-given-url
//
- (NSArray *) getAppBundlesFor: (NSURL *)url {
    NSError *error;
    NSString *utiType = nil;
    NSArray *bundleIdentifiers;

    BOOL success = [url getResourceValue: &utiType
                                  forKey: NSURLTypeIdentifierKey
                                   error: &error];
    if (!success) {
        NSLog(@"Error finding valid app bundles: %@", error);
    }
    else {
        bundleIdentifiers = (__bridge NSArray *)LSCopyAllRoleHandlersForContentType((__bridge CFStringRef)utiType, kLSRolesShell | kLSRolesViewer);
    }

    return bundleIdentifiers;
}

- (NSArray *) getBundleAppNames: (NSArray *)list {
    NSMutableArray *names = [[NSMutableArray alloc] init];
    for (int i=0; i<[list count]; i++) {
        NSArray *name = [list[i] componentsSeparatedByString: @"."];
        [names addObject:[name [[name count]-1] capitalizedString]];
    }
    return (NSArray *)names;
}

// ------------------------------------------------------------------------
- (BOOL) warningPrompt: (NSString *)filename {
    BOOL val = FALSE;
    NSAlert *alert = [[NSAlert alloc] init];
    NSString *msg = [NSString stringWithFormat:@"%@\n%@\n%@", @"A sketch with this name already exists", [sketchPath stringValue], @"Are you sure you wish to overwrite?"];

    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert setMessageText:[NSString stringWithFormat:@"%@ \"%@\"", @"Overwrite", filename]];
    [alert setInformativeText:msg];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        val = TRUE;
    }
    //    [alert release];

    return val;
}

// ------------------------------------------------------------------------
- (BOOL) openBrowser: (NSURL *)url
                with: (NSString *)appBundleIdentifier {
    BOOL browser = FALSE;

    // try preferred browser first
    if ( !browser ) {
        browser = [[NSWorkspace sharedWorkspace]
                   openURLs:@[url]
                   withAppBundleIdentifier:appBundleIdentifier
                   options:NSWorkspaceLaunchAllowingClassicStartup
                   additionalEventParamDescriptor:nil
                   launchIdentifiers:nil];
    }

    // ok... try default browser
    if ( !browser ) {
        browser = [[NSWorkspace sharedWorkspace] openURL:url];
    }

    // still nothing. alert!
    if ( !browser ) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:@"Failed to open sketch."];
        [alert setInformativeText:[NSString stringWithFormat:@"A viable browser could not be found to open\r%@", url]];
        [alert runModal];
    }

    return browser;
}


#pragma mark Methods-Sets

// ------------------------------------------------------------------------

//
// Sets
//
- (void) setPreferences {
    // check if this the first launch
    if (![prefs getBool:@"hasLaunched"]) {
        [prefs setBool:YES forKey:@"hasLaunched"];
    }

    [prefs setString:[sketchPath stringValue] forKey:@"sketchPath"];

    [prefs setBool:[hasMouse state] forKey:@"bMouse"];
    [prefs setBool:[hasTouch state] forKey:@"bTouch"];
    [prefs setBool:[hasKeyboard state] forKey:@"bKeyboard"];
    [prefs setBool:[hasDragdrop state] forKey:@"bDragdrop"];

    [prefs setBool:[hasCss state] forKey:@"bCss"];
    [prefs setBool:[hasBrowser state] forKey:@"bBrowser"];
    [prefs setString:[[browserPopup selectedItem] title] forKey:@"browserPopup"];
    [prefs setBool:[hasWarnings state] forKey:@"bWarnings"];

    NSLog(@"Sketch-Creator: setPreferences hasLaunched:%d", [prefs getBool:@"hasLaunched"]);
}

- (void) updateWithPreferences {
//    if ([prefs getString:@"sketchPath"]) {
        [[sketchPath cell] setPlaceholderString:[prefs getString:@"sketchPath"]];
        [[sketchPath cell] setStringValue:[prefs getString:@"sketchPath"]];
//    }

    if ([prefs getBool:@"hasLaunched"]) {
        [hasMouse setIntValue:[prefs getBool:@"bMouse"]];
        [hasTouch setIntValue:[prefs getBool:@"bTouch"]];
        [hasKeyboard setIntValue:[prefs getBool:@"bKeyboard"]];
        [hasDragdrop setIntValue:[prefs getBool:@"bDragdrop"]];

        [hasCss setIntValue:[prefs getBool:@"bCss"]];
        [hasBrowser setIntValue:[prefs getBool:@"bBrowser"]];
        [browserPopup selectItemWithTitle:[prefs getString:@"browserPopup"]];
        [hasWarnings setIntValue:[prefs getBool:@"bWarnings"]];
    }

    NSLog(@"Sketch-Creator: updateWithPreferences hasLaunched:%d", [prefs getBool:@"hasLaunched"]);
}


#pragma mark Methods-Gets

// ------------------------------------------------------------------------

//
// Gets
//
- (NSString *) getPathModal {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];

    NSString *selected = @"";
    if ([openPanel runModal] == NSOKButton) {
        selected = [[[openPanel URLs] objectAtIndex: 0] absoluteString];
        selected = [selected stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        //        [nscell setStringValue:selected];
    }

    return selected;
}

//- (void) getFilepathModal: (NSCell *)nscell {
//    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
//    [openPanel setCanChooseFiles:YES];
//    [openPanel setCanChooseDirectories:NO];
//    [openPanel setAllowsMultipleSelection:NO];
//
//    NSString *selected = @"";
//    if ([openPanel runModal] == NSOKButton) {
//        selected = [[[openPanel URLs] objectAtIndex: 0] absoluteString];
//        selected = [selected stringByReplacingOccurrencesOfString:@"file://" withString:@""];
//        [nscell setStringValue:selected];
//    }
//    return selected;
//}


#pragma mark Events

// ------------------------------------------------------------------------
// Events
// ------------------------------------------------------------------------
- (IBAction) onCreate: (id)sender {
    NSString *filename = [sketchName stringValue];
    NSString *path = [sketchPath stringValue];

    // create the template content
    [self createTemplate:filename];

    // create the directory struture
    [self createStructure:filename
                 withPath:path];
    
    // set preferences
    [self setPreferences];
}


- (IBAction) chooseSketchPath: (id)sender {
    [[sketchPath cell] setStringValue:[self getPathModal]];
}



@end

