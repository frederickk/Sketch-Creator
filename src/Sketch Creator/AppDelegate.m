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
@synthesize sketchTemplatePopup;
@synthesize sketchName;
@synthesize sketchPath;     // *

@synthesize hasMouse;       // *
@synthesize hasTouch;       // *
@synthesize hasKeyboard;    // *
@synthesize hasDragdrop;    // *

@synthesize hasCss;         // *
@synthesize hasBrowser;     // *
@synthesize browserPopup;   // *
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

    // setup templateBundle
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"p5" ofType:@"bundle"];
    templateBundle = [NSBundle bundleWithPath:bundlePath];

    // check and/or create ~/Library/Application Support/SketchCreator
    NSString *appSupportPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), SUPPORT_PATH];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![FUtilities isDirectory:[NSURL fileURLWithPath:appSupportPath]]) {
        [fileManager createDirectoryAtPath: appSupportPath
               withIntermediateDirectories: NO
                                attributes: nil
                                     error: nil];
    }

    // add listener for preference change of templates
    // [prefs getArray:@"templates"]
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults addObserver: self
               forKeyPath: @"templates"
                  options: NSKeyValueObservingOptionNew
                  context: NULL];

    return self;
}

- (void) awakeFromNib {
    // populate browserPopup with appropriate app names
    NSString *html = [templateBundle pathForResource: @"template_base"
                                                  ofType: @"html"];

    NSURL *url = [NSURL fileURLWithPath:html];
    browserBundleList = [self getAppBundlesFor:url];
    [browserPopup removeAllItems];
    [browserPopup addItemsWithTitles:[self getBundleAppNames:browserBundleList]];

    // update UI with saved preferences
    [self updateWithPreferences];
}

- (void) applicationDidFinishLaunching: (NSNotification *)aNotification {
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

    // update template bundle
    NSString *bundlePath = [NSString stringWithFormat:@"%@%@/%@",
                            NSHomeDirectory(), SUPPORT_PATH, [prefs getString:@"sketchTemplatePopup"]];
    templateBundle = [NSBundle bundleWithPath:bundlePath];


    // the template files to build
    NSString *html = [templateBundle pathForResource: @"template_base"
                                                  ofType: @"html"];
    NSString *js   = [templateBundle pathForResource: @"template_base"
                                                  ofType: @"js"];
    NSString *css  = [templateBundle pathForResource: @"css/default"
                                                  ofType: @"css"];


    // the contents of the template files
    NSString *htmlContent = [NSString stringWithContentsOfFile:html encoding:NSUTF8StringEncoding error:&error];
    NSString *jsContent   = [NSString stringWithContentsOfFile:js   encoding:NSUTF8StringEncoding error:&error];


    // add events to contents
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([hasKeyboard state] == 1) {
        // keyboard
        NSString *jsKeyboard = [templateBundle pathForResource: @"template_keyboard"
                                                            ofType: @"js"];
        if ([fileManager fileExistsAtPath:jsKeyboard]){
            jsKeyboard = [NSString stringWithContentsOfFile: jsKeyboard
                                                   encoding: NSUTF8StringEncoding
                                                      error: &error];
            jsContent = [NSString stringWithFormat:@"%@%@", jsContent, jsKeyboard];
        }
    }
    if ([hasMouse state] == 1) {
        // mouse
        NSString *jsMouse = [templateBundle pathForResource:@"template_mouse"
                                                         ofType: @"js"];
        if ([fileManager fileExistsAtPath:jsMouse]){
            jsMouse = [NSString stringWithContentsOfFile: jsMouse
                                                encoding: NSUTF8StringEncoding
                                                   error: &error];
            jsContent = [NSString stringWithFormat:@"%@%@", jsContent, jsMouse];
        }
    }
    if ([hasTouch state] == 1) {
        // touch
        NSString *jsTouch = [templateBundle pathForResource:@"template_touch"
                                                         ofType: @"js"];
        if ([fileManager fileExistsAtPath:jsTouch]){
            jsTouch = [NSString stringWithContentsOfFile: jsTouch
                                                encoding: NSUTF8StringEncoding
                                                   error: &error];
            jsContent = [NSString stringWithFormat:@"%@%@", jsContent, jsTouch];
        }
    }
    if ([hasDragdrop state] == 1) {
        // drag-drop
        NSString *htmlDragdrop = [templateBundle pathForResource: @"template_dragdrop"
                                                              ofType: @"html"];
        NSString *jsDragdrop   = [templateBundle pathForResource: @"template_dragdrop"
                                                              ofType: @"js"];

        if ([fileManager fileExistsAtPath:htmlDragdrop]){
            htmlDragdrop = [NSString stringWithContentsOfFile: htmlDragdrop
                                                     encoding: NSUTF8StringEncoding
                                                        error: &error];
            // replace instances ##dragdrop## with dragdrop
            htmlContent = [htmlContent stringByReplacingOccurrencesOfString: @"##dragdrop##"
                                                                 withString: htmlDragdrop];
        }
        if ([fileManager fileExistsAtPath:jsDragdrop]){
            jsDragdrop = [NSString stringWithContentsOfFile: jsDragdrop
                                                   encoding: NSUTF8StringEncoding
                                                      error: &error];
            jsContent = [NSString stringWithFormat:@"%@%@", jsContent, jsDragdrop];
        }
    }
    else {
        htmlContent = [htmlContent stringByReplacingOccurrencesOfString: @"##dragdrop##"
                                                             withString: @""];
    }


    // replace instances ##filename## with name
    htmlContent = [htmlContent stringByReplacingOccurrencesOfString: @"##filename##"
                                                         withString: name];
    jsContent = [jsContent stringByReplacingOccurrencesOfString: @"##filename##"
                                                     withString: name];


    // replace instances ##date## with actual date
    CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
    NSString *date = [NSString stringWithFormat:@"%02d.%02d.%02d", currentDate.year, currentDate.month, currentDate.day];

    htmlContent = [htmlContent stringByReplacingOccurrencesOfString: @"##date##"
                                                     withString: date];
    jsContent = [jsContent stringByReplacingOccurrencesOfString: @"##date##"
                                                     withString: date];

    if (error) {
        NSLog(@"Error reading file: %@", error);
    }

    return @{@"html":htmlContent, @"js":jsContent, @"css":css};
}

// ------------------------------------------------------------------------
- (void) createStructure: (NSString *)filename
                withPath: (NSString *)path {

    // create the template content
    NSDictionary *content = [self createTemplate:filename];


    // create the directories
    path = [path stringByAppendingPathComponent:filename];
    NSString *sketchDirectory = [FUtilities createDirectory: filename
                                                   withPath: path
                                                  overwrite: bOverwrite];

    if (bOverwrite) {
        // create the sub-directories
        // empty data directory
        [FUtilities createDirectory: filename
                           withPath: [path stringByAppendingPathComponent:@"data"]
                          overwrite: bOverwrite];

        // empty lib directory
        NSString *libDirectory = [FUtilities createDirectory: filename
                                                    withPath: [path stringByAppendingPathComponent:@"lib"]
                                                   overwrite: bOverwrite];


        // move library/add-on files
        NSArray *libraries = [prefs getArray:@"libraries"];
        NSString *jsHtmlTag = @"";
        for ( NSMutableDictionary *item in libraries ) {
            NSNumber *isActive = [item valueForKey:@"active"];
            if ([isActive isEqual:[NSNumber numberWithBool:YES]]) {
                // copy files
                NSString *filename = [[item valueForKey:@"name"] stringByDeletingPathExtension];

                NSString *filepath;
                // accomodate for the appropriate path of bundled
                // javascript libraries
                if ( [filename isEqualToString:@"p5.min"] || [filename isEqualToString:@"p5.dom"] || [filename isEqualToString:@"p5.sound"] ) {
                    filepath = [[NSBundle bundleForClass:[self class]]
                                         pathForResource:filename
                                                  ofType:@"js"];
                }
                else {
                    filepath = [item valueForKey:@"path"];
                }

                // copy files to path
                [FUtilities copyFile: filepath
                            withPath: [libDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@.js", filename]]];

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
            [FUtilities copyFile: dragdrop
                        withPath: [libDirectory stringByAppendingString:@"/FDrop.min.js"]];
        }


        // css
        if ([hasCss state] == 1) {
            // empty css directory
            NSString *cssDirectory = [FUtilities createDirectory: filename
                                                        withPath: [path stringByAppendingPathComponent:@"css"]
                                                       overwrite: bOverwrite];
            // get path to default css file
            NSString *cssDefault = [content objectForKey:@"css"];

            [FUtilities copyFile: cssDefault
                        withPath: [cssDirectory stringByAppendingString:@"/default.css"]];
        }


        // create the template files
        [FUtilities createFile: [filename stringByAppendingString:@".js"]
                      withPath: sketchDirectory
                   withContent: [content objectForKey:@"js"]];

        [FUtilities createFile: [filename stringByAppendingString:@".html"]
                      withPath: sketchDirectory
                   withContent: htmlContent];


        // open containing folder in Finder
        NSArray *finderDirectory = [NSArray arrayWithObjects:[NSURL fileURLWithPath:sketchDirectory
                                                                        isDirectory:YES], nil];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:finderDirectory];

        
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



#pragma mark Methods-App-Associations

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

    [prefs setString:[[sketchTemplatePopup selectedItem] title] forKey:@"sketchTemplatePopup"];
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
        [sketchTemplatePopup selectItemWithTitle:[prefs getString:@"sketchTemplatePopup"]];

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


- (void) updateTemplatePopup {
    NSString *sel = [prefs getString:@"sketchTemplatePopup"];

    // clear out existing items
    [sketchTemplatePopup removeAllItems];

    // update items
    NSArray *templates = [prefs getArray:@"templates"];
    for( NSMutableDictionary *item in templates ) {
        [sketchTemplatePopup addItemWithTitle:item[@"name"]];

        // set selection
        if ([sel isEqualToString:item[@"name"]]) {
            [sketchTemplatePopup selectItemWithTitle:sel];
        }
    }

    if ([sketchTemplatePopup selectedItem] == nil) {
        [sketchTemplatePopup selectItemWithTitle:@"p5.bundle"];
        // set preference
        [prefs setString:[[sketchTemplatePopup selectedItem] title] forKey:@"sketchTemplatePopup"];
    }
}


#pragma mark Methods-Gets

// ------------------------------------------------------------------------

//
// Gets
//
- (NSString *) getPathModal {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
//    [openPanel setAllowedFileTypes:ext];

    NSString *selected = [prefs getString:@"sketchPath"];

    if ([openPanel runModal] == NSOKButton) {
        NSURL *path = [[openPanel URLs] objectAtIndex: 0];
        if ([FUtilities isDirectory:path]) {
            selected = [path absoluteString];
            selected = [selected stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            //        [nscell setStringValue:selected];
        }
    }

    return selected;
}



#pragma mark Events

// ------------------------------------------------------------------------
// Events
// ------------------------------------------------------------------------
- (IBAction) onCreate: (id)sender {
    NSString *filename = [sketchName stringValue];
    NSString *path     = [sketchPath stringValue];

    // create the template content
//    [self createTemplate:filename];

    // create the directory struture
    [self createStructure: filename
                 withPath: path];
    
    // set preferences
    [self setPreferences];
}


- (IBAction) chooseSketchPath: (id)sender {
    [[sketchPath cell] setStringValue:[self getPathModal]];
    [self setPreferences];
}


- (IBAction) onChooseTemplate: (id)sender {
    [self setPreferences];
}

// ------------------------------------------------------------------------
- (void) observeValueForKeyPath: (NSString *)keyPath
                       ofObject: (id)object
                         change: (NSDictionary *)change
                        context: (void *)context {
    [self updateTemplatePopup];
}

@end

