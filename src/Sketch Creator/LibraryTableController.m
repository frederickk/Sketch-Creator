//
//  LibraryTable.m
//  Sketch Creator
//
//  Created by Ken Frederick on 2014.06.17.
//  Copyright (c) 2014 Ken Frederick. All rights reserved.
//

#import "LibraryTableController.h"

@implementation LibraryTableController


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
    extensions = [[NSArray alloc] initWithObjects:@"js", @"JS", nil];

    // update UI with saved preferences
    [self updateWithPreferences];

    // add initial items
    NSString *p5js = [[NSBundle bundleForClass:[self class]]
                      pathForResource:@"p5.min"
                      ofType:@"js"];
    NSString *p5domjs = [[NSBundle bundleForClass:[self class]]
                         pathForResource:@"p5.dom"
                         ofType:@"js"];

    [self addPath:p5js     setActive:TRUE];
    [self addPath:p5domjs  setActive:FALSE];

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


#pragma mark Methods-Sets

//
// Sets
//
- (BOOL) addPath: (NSString *)path
       setActive: (BOOL)state {

    NSMutableDictionary *val = [[NSMutableDictionary alloc] init];
    val[@"active"] = [NSNumber numberWithBool:state];
    val[@"name"]   = [path lastPathComponent];
    val[@"path"]   = path;

    BOOL isContained = FALSE;
    for( NSMutableDictionary *item in self.FDragTableValues ) {
        if ([item[@"name"] isEqualToString:val[@"name"]] ) {
            //        if ([item[@"path"] isEqualToString:path] ) {
            isContained = TRUE;
            break;
        }
    }

    BOOL isAdded = FALSE;
    if ( self.FDragTableValues && !isContained ) { //![values containsObject:val] ) {
        [self.FDragTableValues addObject:val];
        isAdded = TRUE;

        [self setPreferences];
    }

    return isAdded;
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
        isRemoved = TRUE;

        [self setPreferences];
    }

    return isRemoved;
}

// ------------------------------------------------------------------------
- (BOOL) setPreferences {
    [prefs setArray:self.FDragTableValues forKey:@"libraries"];
    return YES;
}

- (void) updateWithPreferences {
    // may seem backwards, but this prevents
    // an index out of bounds error
    NSArray *libraries = [prefs getArray:@"libraries"];
    for( NSMutableDictionary *item in libraries ) {
        [self addPath:item[@"path"]
            setActive:(BOOL)item[@"active"]];
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

        if (![self isDirectory:path]) {
            selected = [path absoluteString];
            selected = [selected stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        }
    }

    return selected;
}

// ------------------------------------------------------------------------
//
//  http://stackoverflow.com/questions/22277117/how-to-find-out-if-the-nsurl-is-a-directory-or-not
//
- (BOOL) isDirectory: (NSURL *)path {
    NSNumber *isDirectory;
    BOOL success = [path getResourceValue: &isDirectory
                                   forKey: NSURLIsDirectoryKey
                                    error: nil];

    if (success && [isDirectory boolValue]) {
        // NSLog(@"Congratulations, it's a directory!");
        return YES;
    }
    else {
        // NSLog(@"It seems it's just a file.");
        return NO;
    }
}


#pragma mark Events

// ------------------------------------------------------------------------
// Events
// ------------------------------------------------------------------------
- (IBAction) addRow: (id)sender {
    NSString *path = [self getFilepathModal:extensions];
    if (![path isEqualToString:@""]) {
        [self addPath:path setActive:TRUE];

        [self.FDragTableView noteNumberOfRowsChanged];
        [self.FDragTableView reloadData];
    }
}

- (IBAction) removeRow: (id)sender {
    NSInteger row = [self.FDragTableView selectedRow];
    [self removePath:row];
}

// ------------------------------------------------------------------------
- (IBAction) setPath: (id)sender {
    if (sender == self.FDragTableView) {
        NSInteger row = [sender clickedRow];
        NSString *path = [self getFilepathModal:extensions];
        if (![path isEqualToString:@""]) {
            [[self.FDragTableValues objectAtIndex:row] setValue:[path lastPathComponent] forKey:@"name"];
            [[self.FDragTableValues objectAtIndex:row] setValue:path forKey:@"path"];
        }
    }
}



@end
