//
//  TemplateTableController.m
//  Sketch Creator
//
//  Created by Ken Frederick on 2014.06.17.
//  Copyright (c) 2014 Ken Frederick. All rights reserved.
//

#import "TemplateTableController.h"

@implementation TemplateTableController


// ------------------------------------------------------------------------
// Properties
// ------------------------------------------------------------------------
@synthesize prefs;



#pragma mark Methods

// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------
- (void) awakeFromNib {
    // inits
    self.FDragTableValues = [[NSMutableArray alloc] init];
    prefs = [[FPreferences alloc] init];

    // set viable extensions
    extensions = [[NSArray alloc] initWithObjects:@"bundle", @"BUNDLE", nil];

    // update UI with saved preferences
    [self updateWithPreferences];

    // setup templateBundle
    NSString *coreTemplate = [[NSBundle mainBundle] pathForResource:@"p5" ofType:@"bundle"];
    [self addPath:coreTemplate];

    [self.FDragTableView registerForDraggedTypes:[NSArray arrayWithObject:FDTableCellViewDataType]];
}

// ------------------------------------------------------------------------
- (void) isUpdated {
    [self updateWithPreferences];
}


// ------------------------------------------------------------------------

#pragma mark Methods-Inherited

//
// Inherited from NSTableViewDataSource
//

// Set
- (void) tableView: (NSTableView *)tableView
    setObjectValue: (id)value
    forTableColumn: (NSTableColumn *)column
               row: (NSInteger)row {

    if (tableView == self.FDragTableView) {
        [[self.FDragTableValues objectAtIndex:row] setValue:value forKey:[column identifier]];
        [self setPreferences];
    }
}

// ------------------------------------------------------------------------


#pragma mark Methods

- (BOOL) validBundle: (NSString *)path {
    BOOL isValid = NO;

    // update template bundle
    NSBundle *bundle = [NSBundle bundleWithPath:path];

    // inspect bundle for core files to ensure compatibility
    NSString *html = [bundle pathForResource: @"template_base"
                                      ofType: @"html"];
    NSString *js   = [bundle pathForResource: @"template_base"
                                      ofType: @"js"];
    NSString *css  = [bundle pathForResource: @"css/default"
                                      ofType: @"css"];

    if (html != nil && js != nil) {
        isValid = YES;
        if (css == nil) {
            // TODO: localized strings
            [FUtilities warningPrompt: @"inform"
                              message: [NSString stringWithFormat:@"\"%@\" does not contain a valid CSS file.", [path lastPathComponent]]
                      informativeText: [NSString stringWithFormat:@"\"Include bundled CSS styles\" will have no effect."]];
        }
    }

    return isValid;
}


// ------------------------------------------------------------------------


#pragma mark Methods-Sets

//
// Sets
//
- (BOOL) addPath: (NSString *)path {
    NSString *appSupportPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), SUPPORT_PATH];

    NSMutableDictionary *val = [[NSMutableDictionary alloc] init];
    val[@"name"] = [path lastPathComponent];
    val[@"path"] = [NSString stringWithFormat:@"%@/%@", appSupportPath, val[@"name"]];


    // check that bundle is valid
    if ([self validBundle:path]) {

        BOOL isContained = FALSE;
        for( NSMutableDictionary *item in self.FDragTableValues ) {
            if ([item[@"name"] isEqualToString:val[@"name"]] ) {
                isContained = TRUE;
                break;
            }
        }

        BOOL isAdded = FALSE;
        if ( self.FDragTableValues && !isContained ) { //![values containsObject:val] ) {
            [self.FDragTableValues addObject:val];
            isAdded = TRUE;

            if (![FUtilities isExists:[NSURL fileURLWithPath:val[@"path"]]]) {
            // copy chosen file into ~/Library/Application Support/Sketch Creator
                [FUtilities copyFile: path
                            withPath: val[@"path"] ];
            }
            [self setPreferences];
        }

        return isAdded;
    }
    else {
        // TODO: localized strings
        [FUtilities warningPrompt: @"alert"
                          message: [NSString stringWithFormat:@"\"%@\" is an invalid bundle for Sketch Creator", [path lastPathComponent]]
                  informativeText: @""];

        return NO;
    }

}

- (BOOL) removePath: (NSInteger)row {
    NSString *filename = [self.FDragTableValues objectAtIndex:row][@"name"];

    BOOL isRemoved = FALSE;
    BOOL isP5 = [filename rangeOfString:@"p5" options:NSCaseInsensitiveSearch].location != NSNotFound;

    if (isP5) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:[NSString stringWithFormat:@"\"%@\" cannot be removed.", filename]];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
    }
    else {
        [self.FDragTableValues removeObjectAtIndex:row];
        [self.FDragTableView noteNumberOfRowsChanged];
        [self.FDragTableView reloadData];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *appSupportPath = [NSString stringWithFormat:@"%@%@", NSHomeDirectory(), SUPPORT_PATH];
        [fileManager removeItemAtPath:[appSupportPath stringByAppendingPathComponent:filename] error:nil];

        isRemoved = TRUE;

        [self setPreferences];
    }

    return isRemoved;
}

// ------------------------------------------------------------------------
- (BOOL) setPreferences {
    [prefs setArray:self.FDragTableValues forKey:@"templates"];
    return YES;
}

- (void) updateWithPreferences {
    NSLog(@"templateTable.updateWithPreferences");
    // may seem backwards, but this prevents
    // an index out of bounds error
    NSArray *templates = [prefs getArray:@"templates"];
    for( NSMutableDictionary *item in templates ) {
        [self addPath:item[@"path"]];
    }
}



#pragma mark Methods-Gets

// ------------------------------------------------------------------------
- (NSString *) getFilepathModal: (NSArray *)ext {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setAllowsMultipleSelection:NO];
    //    [openPanel setAllowedFileTypes:ext];

    NSString *selected = @"";

    if ([openPanel runModal] == NSOKButton) {
        NSURL *path = [[openPanel URLs] objectAtIndex: 0];

        if ([FUtilities isDirectory:path]) {
            selected = [path absoluteString];
            selected = [selected stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        }
    }

    return selected;
}



#pragma mark Events

// ------------------------------------------------------------------------
// Events
// ------------------------------------------------------------------------
- (IBAction) addRow: (id)sender {
    NSString *path = [self getFilepathModal:extensions];

    if (![path isEqualToString:@""]) {
        [self addPath:path];

        [self.FDragTableView noteNumberOfRowsChanged];
        [self.FDragTableView reloadData];
    }
}

- (IBAction) removeRow: (id)sender {
    NSInteger row = [self.FDragTableView selectedRow];
    [self removePath:row];
}



@end
