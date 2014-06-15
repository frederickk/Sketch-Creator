//
//  DragController.m
//  Sketch Creator
//
//  Created by Ken Frederick on 2014.06.07.
//  Copyright (c) 2014 Ken Frederick. All rights reserved.
//
//
//  Code inspired by
//  https://github.com/xuecheng/osx_dragtablecelldemo
//
//  Created by evan on 12-10-9.
//  Copyright (c) 2012年 acheng. All rights reserved.
//



#import "FDragController.h"

@implementation FDragController


// ------------------------------------------------------------------------
// Constants
// ------------------------------------------------------------------------
#define FDTableCellViewDataType @"FDTableCellViewDataType"



// ------------------------------------------------------------------------
// Properties
// ------------------------------------------------------------------------
@synthesize FDTableView;
@synthesize values;

// preferences
@synthesize prefs;



#pragma mark Methods

// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------
- (void) awakeFromNib {
    // inits
    values = [[NSMutableArray alloc] init];
    prefs = [[FPreferences alloc] init];

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

    [FDTableView registerForDraggedTypes:[NSArray arrayWithObject:FDTableCellViewDataType] ];
}

// ------------------------------------------------------------------------

#pragma mark Methods-Inherited

//
// Inherited from NSTableViewDataSource
//

// Get
- (NSInteger) numberOfRowsInTableView: (NSTableView *)tableView {
    if (tableView == FDTableView) {
        return (int)[values count];
    }
    return 0;
}

- (id) tableView: (NSTableView *)tableView
objectValueForTableColumn: (NSTableColumn *)column
                      row: (NSInteger)row {

    if (tableView == FDTableView) {
        return [[values objectAtIndex:row] valueForKey:[column identifier]];
    }

    return nil;
}

// Set
- (void) tableView: (NSTableView *)tableView
    setObjectValue: (id)value
    forTableColumn: (NSTableColumn *)column
               row: (NSInteger)row {

    if (tableView == FDTableView) {
        [[values objectAtIndex:row] setValue:value forKey:[column identifier]];
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
    for( NSMutableDictionary *item in values ) {
        if ([item[@"path"] isEqualToString:path] ) {
            isContained = TRUE;
            break;
        }
    }

    BOOL isAdded = FALSE;
    if ( values && !isContained ) { //![values containsObject:val] ) {
        [values addObject:val];
        isAdded = TRUE;

        [self setPreferences];
    }

    return isAdded;
}

- (BOOL) removePath: (NSInteger)row {
    BOOL isRemoved = FALSE;
    if (row != 0 && row != 1) {
        [values removeObjectAtIndex:row];
        [self.FDTableView noteNumberOfRowsChanged];
        [self.FDTableView reloadData];
        isRemoved = TRUE;

        [self setPreferences];
    }
    
    return isRemoved;
}

// ------------------------------------------------------------------------
- (BOOL) setPreferences {
    [prefs setArray:values forKey:@"libraries"];
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
- (NSString *) getFilepathModal: (NSArray *)extensions {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:extensions];

    NSString *selected = @"";
    if ([openPanel runModal] == NSOKButton) {
        selected = [[[openPanel URLs] objectAtIndex: 0] absoluteString];
        selected = [selected stringByReplacingOccurrencesOfString:@"file://" withString:@""];
    }

    return selected;
}


#pragma mark Events

// ------------------------------------------------------------------------
// Events
// ------------------------------------------------------------------------
- (IBAction) addRow: (id)sender {
    NSArray *extensions = [[NSArray alloc] initWithObjects:@"js", @"JS", nil];
    NSString *path = [self getFilepathModal:extensions];
    if (![path isEqualToString:@""]) {
        [self addPath:path setActive:TRUE];

        [self.FDTableView noteNumberOfRowsChanged];
        [self.FDTableView reloadData];
    }
}

- (IBAction) removeRow: (id)sender {
    NSInteger row = [self.FDTableView selectedRow];
    [self removePath:row];
}

// ------------------------------------------------------------------------
- (IBAction) setPath: (id)sender {
    if (sender == FDTableView) {
        NSInteger row = [sender clickedRow];
        NSArray *extensions = [[NSArray alloc] initWithObjects:@"js", @"JS", nil];
        NSString *path = [self getFilepathModal:extensions];
        if (![path isEqualToString:@""]) {
            [[values objectAtIndex:row] setValue:[path lastPathComponent] forKey:@"name"];
            [[values objectAtIndex:row] setValue:path forKey:@"path"];
        }
    }
}


#pragma mark Events-Drag

// ------------------------------------------------------------------------

//
// Drag
//
- (BOOL) tableView: (NSTableView *)tableView
writeRowsWithIndexes: (NSIndexSet *)rows
        toPasteboard: (NSPasteboard *)pasteboard {

    NSData *zNSIndexSetData = [NSKeyedArchiver archivedDataWithRootObject:rows];
    [pasteboard declareTypes:[NSArray arrayWithObject:FDTableCellViewDataType] owner:self];
    [pasteboard setData:zNSIndexSetData forType:FDTableCellViewDataType];

    return YES;
}

- (NSDragOperation) tableView: (NSTableView *)tableView
                 validateDrop: (id <NSDraggingInfo>)info
                  proposedRow: (NSInteger)row
        proposedDropOperation: (NSTableViewDropOperation)op {

//    NSLog(@"validate Drop: %@", info);
    return NSDragOperationEvery;
}

// ------------------------------------------------------------------------
- (BOOL) tableView: (NSTableView *)tableView
        acceptDrop: (id <NSDraggingInfo>)info
               row: (NSInteger)row
     dropOperation: (NSTableViewDropOperation)operation {

    NSPasteboard *pasteboard = [info draggingPasteboard];
    NSData *rowData = [pasteboard dataForType:FDTableCellViewDataType];
    NSIndexSet *rows = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    NSInteger dragRow = [rows firstIndex];


//    if (dragRow != 0 && dragRow != 1 && row != 0 && row != 1) {
        if (dragRow < row) {
            [values insertObject:[values objectAtIndex:dragRow] atIndex:row];
            [values removeObjectAtIndex:dragRow];
            [self.FDTableView noteNumberOfRowsChanged];
            [self.FDTableView reloadData];

            return YES;
        }

        NSString *zData = [values objectAtIndex:dragRow];
        [values removeObjectAtIndex:dragRow];
        [values insertObject:zData atIndex:row];
        [self.FDTableView noteNumberOfRowsChanged];
        [self.FDTableView reloadData];

        [self setPreferences];

        return YES;
//    }
//    else {
//        return NO;
//    }
}



@end

