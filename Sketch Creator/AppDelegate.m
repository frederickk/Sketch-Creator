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
@synthesize libraryList;

@synthesize sketchName;
@synthesize sketchPath;

@synthesize bMouse;
@synthesize bTouch;
@synthesize bKeyboard;
@synthesize bDragdrop;

// preferences
@synthesize libraryScroll;
@synthesize libraryTable;
@synthesize bCss;
@synthesize bWarnings;



// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------
- (void) applicationDidFinishLaunching: (NSNotification *)aNotification {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains
                    (NSDocumentDirectory, NSUserDomainMask, YES);
//    NSLog(@"user: %@", NSHomeDirectory());

    // set default/placeholder values
    [[sketchName cell] setPlaceholderString:@"sketch"];

    NSString *savepathPlaceholder = [[paths objectAtIndex:0] stringByAppendingString:@"/Processing"];
    [[sketchPath cell] setPlaceholderString:savepathPlaceholder];
    [[sketchPath cell] setStringValue:savepathPlaceholder];

//    [[addons cell] setDelegate:addons];

}

- (void)awakeFromNib {

    NSString *p5js = [[NSBundle bundleForClass:[self class]]
                               pathForResource:@"p5.min"
                                        ofType:@"js"];
    NSString *p5Djs = [[NSBundle bundleForClass:[self class]]
                                pathForResource:@"p5DOM"
                                         ofType:@"js"];
    NSLog(@"p5.js: %@", p5js);
    NSLog(@"p5Dom.js: %@", p5Djs);

    NSString *filename = [p5js lastPathComponent];

    NSLog(@"p5.js-file: %@", filename);

    NSLog(@"rows: %lil", (long)[libraryTable numberOfRows]);
    NSLog(@"columns: %ld", (long)[libraryTable numberOfColumns]);

    NSMutableArray *cellArray;
	[cellArray addObject:@"aaaaaaaaaaaaaaaaa"];
	[cellArray addObject:@"cccccccc"];

}

// ------------------------------------------------------------------------
- (NSString *) createDirectory: (NSString *)dirname :(NSString *)path {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dirSuccess = FALSE;
    BOOL bOverwrite = TRUE;
    
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

- (NSString *) createFile: (NSString *)filename :(NSString *)path :(NSString *)content {
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

- (NSString *) copyFile: (NSString *)src :(NSString *)dest {
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
        NSLog(@"jsContent: %@", jsContent);
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
    
    // debug
//    NSLog(@"name: %@", name);
//    NSLog(@"htmlContents: %@", htmlContent);
//    NSLog(@"jsContent: %@", jsContent);

    return @{@"html":htmlContent, @"js":jsContent};
}

// ------------------------------------------------------------------------
- (void) createStructure: (NSString *)filename :(NSString *)path {
    // create the template content
    NSDictionary *content = [self createTemplate:filename];
    

    // create the directories
    path = [path stringByAppendingPathComponent:filename];
    NSString *sketchDirectory = [self createDirectory:filename :path];
    // empty data directory
    [self createDirectory:filename :[path stringByAppendingPathComponent:@"data"]];
    // empty lib directory
    NSString *libDirectory = [self createDirectory:filename :[path stringByAppendingPathComponent:@"lib"]];


    // create the template files
    [self createFile:[filename stringByAppendingString:@".html"] :sketchDirectory :[content objectForKey:@"html"]];
    [self createFile:[filename stringByAppendingString:@".js"]   :sketchDirectory :[content objectForKey:@"js"]];

    // move library files
    // TODO: feed this from token list
    NSString *src = [[NSBundle bundleForClass:[self class]]
                              pathForResource:@"p5.min"
                                       ofType:@"js"];
    [self copyFile:src :[libDirectory stringByAppendingString:@"/p5.min.js"]];

    // css
    if ([bCss state] == 1) {
        // empty css directory
        NSString *cssDirectory = [self createDirectory:filename :[path stringByAppendingPathComponent:@"css"]];
        // move css files
        NSString *cssDefault = [[NSBundle bundleForClass:[self class]]
                                         pathForResource:@"default"
                                                  ofType:@"css"];
        [self copyFile:cssDefault :[cssDirectory stringByAppendingString:@"/default.css"]];
    }

}

- (void) getPathModal: (NSCell *)nscell {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel setCanChooseFiles:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];

    NSString *selected;
    if ([openPanel runModal] == NSOKButton) {
        selected = [[[openPanel URLs] objectAtIndex: 0] absoluteString];
        selected = [selected stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        [nscell setStringValue:selected];
    }
}

- (void) getFilepathModal: (NSCell *)nscell {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];

    NSString *selected;
    if ([openPanel runModal] == NSOKButton) {
        selected = [[[openPanel URLs] objectAtIndex: 0] absoluteString];
        selected = [selected stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        [nscell setStringValue:selected];
    }
}

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
// Events
// ------------------------------------------------------------------------
- (IBAction) onCreate: (id)sender {
    NSString *filename = [sketchName stringValue];
    if ([filename isEqualToString:@""]) {
        filename = [[sketchName cell] placeholderString];
    }

    NSString *path = [sketchPath stringValue];
    if ([path isEqualToString:@""]) {
        path =  [[sketchPath cell] placeholderString];
    }


    // create the template content
    [self createTemplate:filename];


    // create the directories
    // TODO: handle overwrite confirmation
    [self createStructure:filename :path];
    NSLog(@"button %@", filename);
}


- (IBAction) chooseSketchPath: (id)sender {
    [self getPathModal:[sketchPath cell]];
}

- (IBAction)testTable:(id)sender {
}



// ------------------------------------------------------------------------











@end
