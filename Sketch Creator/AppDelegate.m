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
@synthesize sketchPath; // *

@synthesize bMouse;     // *
@synthesize bTouch;     // *
@synthesize bKeyboard;  // *
@synthesize bDragdrop;  // *

@synthesize bCss;       // *
@synthesize bWarnings;  // *

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

    return self;
}

- (void) awakeFromNib {
    // set default/placeholder values
    [[sketchName cell] setPlaceholderString:@"sketch"];
}

- (void) applicationDidFinishLaunching: (NSNotification *)aNotification {
    // update UI with saved preferences
    [self updateWithPreferences];

    // set preferences
    [self setPreferences];
}


#pragma mark Methods-Quit

// ------------------------------------------------------------------------
- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)theApplication {
    [self onQuit:self];
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
    if ([bKeyboard state] == 1) {
        // keyboard
        NSString *jsKeyboard = [[NSBundle bundleForClass:[self class]]
                                         pathForResource:@"template_keyboard"
                                                  ofType:@"js"];
        jsKeyboard = [NSString stringWithContentsOfFile:jsKeyboard encoding:NSUTF8StringEncoding error:&error];

        jsContent = [NSString stringWithFormat:@"%@%@", jsContent, jsKeyboard];
    }
    if ([bMouse state] == 1) {
        // mouse
        NSString *jsMouse = [[NSBundle bundleForClass:[self class]]
                                      pathForResource:@"template_mouse"
                                               ofType:@"js"];
        jsMouse = [NSString stringWithContentsOfFile:jsMouse encoding:NSUTF8StringEncoding error:&error];

        jsContent = [NSString stringWithFormat:@"%@%@", jsContent, jsMouse];
    }
    if ([bTouch state] == 1) {
        // touch
        NSString *jsTouch = [[NSBundle bundleForClass:[self class]]
                                      pathForResource:@"template_touch"
                                               ofType:@"js"];
        jsTouch = [NSString stringWithContentsOfFile:jsTouch encoding:NSUTF8StringEncoding error:&error];

        jsContent = [NSString stringWithFormat:@"%@%@", jsContent, jsTouch];
    }
    if ([bDragdrop state] == 1) {
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
        // TODO: feed this from token list
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
//        NSArray *libraries = [prefs getLibraryValues];
//        NSString *jsHtmlTag = @"";
//        for( NSMutableDictionary *item in libraries ) {
//            NSNumber *isActive = [item valueForKey:@"active"];
//            if ([isActive isEqual:[NSNumber numberWithBool:YES]]) {
//                // copy files
//                NSString *src = [item valueForKey:@"path"];
//                NSString *srcName = [@"/" stringByAppendingString:[item valueForKey:@"name"]];
//                [self copyFile:src :[libDirectory stringByAppendingString:srcName]];
//                // update html
//                jsHtmlTag = [jsHtmlTag stringByAppendingString:[NSString stringWithFormat:@"<script type=\"text/javascript\" src=\"./lib%@\"></script>\r\t\t", srcName]];
//            }
//        }
//        // replace instances ##libraries## with <script..
//        NSString *htmlContent = [[content objectForKey:@"html"] stringByReplacingOccurrencesOfString:@"##libraries##"
//                                                             withString:jsHtmlTag];

        // drag-drop is a special case
        if ([bDragdrop state] == 1) {
            NSString *dragdrop = [[NSBundle bundleForClass:[self class]]
                                           pathForResource:@"FDrop.min" // this should match table value
                                                    ofType:@"js"];
            [self copyFile:dragdrop
                  withPath:[libDirectory stringByAppendingString:@"/FDrop.min.js"]];
        }


        // css
        if ([bCss state] == 1) {
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
//        [self createFile:[filename stringByAppendingString:@".html"] :sketchDirectory :htmlContent];
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

    // the directory
    NSString *directory = path;

    // check if directory exists
    if ([fileManager fileExistsAtPath:path]) {
        // display overwrite warning
        if ([bWarnings integerValue] == 0) {
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
            directory = nil;
        }
    }

    return directory;
}

- (NSString *) createFile: (NSString *)filename
                 withPath: (NSString *)path
              withContent: (NSString *)content {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileSuccess = FALSE;

    NSString *file = [NSString stringWithFormat:@"%@/%@", path, filename];

    // check if file exist
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

    // check if file exist
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


#pragma mark Methods-Sets

// ------------------------------------------------------------------------

//
// Sets
//
- (void) setPreferences {
    NSLog(@"setPreferences");

    [prefs setString:[sketchPath stringValue] forKey:@"sketchPath"];

    [prefs setBool:[bMouse state] forKey:@"bMouse"];
    [prefs setBool:[bTouch state] forKey:@"bTouch"];
    [prefs setBool:[bKeyboard state] forKey:@"bKeyboard"];
    [prefs setBool:[bDragdrop state] forKey:@"bDragdrop"];

    [prefs setBool:[bCss state] forKey:@"bCss"];
    [prefs setBool:[bWarnings state] forKey:@"bWarnings"];
}

- (void) updateWithPreferences {
    NSLog(@"updateWithPreferences");

    [[sketchPath cell] setPlaceholderString:[prefs getString:@"sketchPath"]];
    [[sketchPath cell] setStringValue:[prefs getString:@"sketchPath"]];

    [bMouse setIntValue:[prefs getBool:@"bMouse"]];
    [bTouch setIntValue:[prefs getBool:@"bTouch"]];
    [bKeyboard setIntValue:[prefs getBool:@"bKeyboard"]];
    [bDragdrop setIntValue:[prefs getBool:@"bDragdrop"]];

    [bCss setIntValue:[prefs getBool:@"bCss"]];
    [bWarnings setIntValue:[prefs getBool:@"bWarnings"]];
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

    NSLog(@"onCreate: %@%@", path, filename);
}


- (IBAction) chooseSketchPath: (id)sender {
    [[sketchPath cell] setStringValue:[self getPathModal]];
}



@end

