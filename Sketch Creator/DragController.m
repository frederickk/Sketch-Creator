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



#import "DragController.h"
//#import "Preferences.m"

@implementation DragController


// ------------------------------------------------------------------------
// Properties
// ------------------------------------------------------------------------
@synthesize valuesArray;
@synthesize dragTableView;

#define DCTableCellViewDataType @"DCTableCellViewDataType"



#pragma mark Methods

// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------
- (void) awakeFromNib {
    // init array
    valuesArray = [[NSMutableArray alloc] init];

    // update with saved libraries
    [self update];

    // add initial items
    NSString *p5js = [[NSBundle bundleForClass:[self class]]
                               pathForResource:@"p5.min"
                                        ofType:@"js"];
    NSString *p5domjs = [[NSBundle bundleForClass:[self class]]
                                  pathForResource:@"p5.dom"
                                           ofType:@"js"];

    [self addPath:p5js     setActive:TRUE];
    [self addPath:p5domjs  setActive:FALSE];


    [dragTableView registerForDraggedTypes:[NSArray arrayWithObject:DCTableCellViewDataType] ];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)theApplication {
    [self saveValues];
    return YES;
}
- (IBAction) onQuit: (id)sender {
    [self saveValues];
    exit(0);
}

// ------------------------------------------------------------------------

#pragma mark Methods-Inherited

//
// Inherited from NSTableViewDataSource
//

// Get
- (NSInteger) numberOfRowsInTableView: (NSTableView *)tableView {
    if (tableView == dragTableView) {
        return (int)[valuesArray count];
    }
    return 0;
}

- (id) tableView: (NSTableView *)tableView
objectValueForTableColumn: (NSTableColumn *)column
                      row: (NSInteger)row {

    if (tableView == dragTableView) {
        return [[valuesArray objectAtIndex:row] valueForKey:[column identifier]];
    }

    return nil;
}

// Set
- (void) tableView: (NSTableView *)tableView
    setObjectValue: (id)value
    forTableColumn: (NSTableColumn *)column
               row: (NSInteger)row {

    if (tableView == dragTableView) {
        [[valuesArray objectAtIndex:row] setObject:value forKey:[column identifier]];
    }

}

// ------------------------------------------------------------------------
- (void) update {
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"libraryValues"] ) {
        [valuesArray setArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"libraryValues"]];
    }
}


#pragma mark Methods-Sets

// ------------------------------------------------------------------------

//
// Sets
//
- (BOOL) addPath: (NSString *)path
       setActive: (BOOL)state {

    NSMutableDictionary *val = [[NSMutableDictionary alloc] init];
    val[@"active"] = [NSNumber numberWithBool:state];
    val[@"name"]   = [path lastPathComponent];
    val[@"path"]   = path;

    BOOL isAdded = FALSE;
    if ( valuesArray && ![valuesArray containsObject:val] ) {
        [valuesArray addObject:val];
        isAdded = TRUE;

        [self saveValues];
    }

    return isAdded;
}

- (BOOL) removePath: (NSInteger)row {
    BOOL isRemoved = FALSE;
    if (row != 0 && row != 1) {
        [valuesArray removeObjectAtIndex:row];
        [self.dragTableView noteNumberOfRowsChanged];
        [self.dragTableView reloadData];
        isRemoved = TRUE;

        [self saveValues];
    }
    
    return isRemoved;
}

// ------------------------------------------------------------------------
- (BOOL) saveValues {
    // set values
    [[NSUserDefaults standardUserDefaults] setObject:valuesArray forKey:@"libraryValues"];

    // Return the results of attempting to write preferences to system
    return [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark Methods-Gets

// ------------------------------------------------------------------------

//
// Gets
//
- (NSArray *) getValues; {
    return (NSArray *)valuesArray;
}

// ------------------------------------------------------------------------
- (NSString *) getFilepathModal {
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setAllowedFileTypes:[[NSArray alloc] initWithObjects:@"js", @"JS", nil]];

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
- (IBAction)addRow:(id)sender {
    NSString *path = [self getFilepathModal];
    if (![path isEqualToString:@""]) {
        [self addPath:path setActive:TRUE];

        [self.dragTableView noteNumberOfRowsChanged];
        [self.dragTableView reloadData];
    }
}

- (IBAction)removeRow:(id)sender {
    NSInteger row = [self.dragTableView selectedRow];
    [self removePath:row];
}

// ------------------------------------------------------------------------
- (IBAction) setPath: (id)sender {
    if (sender == dragTableView) {
        NSInteger row = [sender clickedRow];
        NSString *path = [self getFilepathModal];
        if (![path isEqualToString:@""]) {
            [[valuesArray objectAtIndex:row] setObject:[path lastPathComponent] forKey:@"name"];
            [[valuesArray objectAtIndex:row] setObject:path forKey:@"path"];
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
        toPasteboard: (NSPasteboard *)pboard {

    NSData *zNSIndexSetData = [NSKeyedArchiver archivedDataWithRootObject:rows];
    [pboard declareTypes:[NSArray arrayWithObject:DCTableCellViewDataType] owner:self];
    [pboard setData:zNSIndexSetData forType:DCTableCellViewDataType];
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

    NSPasteboard *pboard = [info draggingPasteboard];
    NSData *rowData = [pboard dataForType:DCTableCellViewDataType];
    NSIndexSet *rows = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    NSInteger dragRow = [rows firstIndex];

//    if (dragRow != 0 && dragRow != 1 && row != 0 && row != 1) {
        if (dragRow < row) {
            [valuesArray insertObject:[valuesArray objectAtIndex:dragRow] atIndex:row];
            [valuesArray removeObjectAtIndex:dragRow];
            [self.dragTableView noteNumberOfRowsChanged];
            [self.dragTableView reloadData];

            return YES;
        }

        NSString *zData = [valuesArray objectAtIndex:dragRow];
        [valuesArray removeObjectAtIndex:dragRow];
        [valuesArray insertObject:zData atIndex:row];
        [self.dragTableView noteNumberOfRowsChanged];
        [self.dragTableView reloadData];

        [self saveValues];

        return YES;
//    }
//    else {
//        return NO;
//    }
}



@end

