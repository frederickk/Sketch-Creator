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



#pragma mark Methods

// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------
- (id) init {

    return self;
}

- (void) awakeFromNib {
//    // init array
//    values = [[NSMutableArray alloc] init];
//
//    // add initial items
//    NSString *p5js = [[NSBundle bundleForClass:[self class]]
//                               pathForResource:@"p5.min"
//                                        ofType:@"js"];
//    NSString *p5domjs = [[NSBundle bundleForClass:[self class]]
//                                  pathForResource:@"p5.dom"
//                                           ofType:@"js"];
//
//    [self addPath:p5js     setActive:TRUE];
//    [self addPath:p5domjs  setActive:FALSE];
//
//    // update with saved libraries
//    [self update];
//
//    [FDTableView registerForDraggedTypes:[NSArray arrayWithObject:FDTableCellViewDataType] ];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *)theApplication {
//    [self saveValues];
    return YES;
}
- (IBAction) onQuit: (id)sender {
//    [self saveValues];
    exit(0);
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
//        NSLog(@"column:identifier %@", [column identifier]);
//        NSLog(@"values:row: %li: %@" ,row, [values objectAtIndex:row]);
//        NSLog(@"value: %@", value);
////        @try {
////            NSLog(@"values---> %@", [[values objectAtIndex:row] className]);
//            [[values objectAtIndex:row] setObject:value forKey:[column identifier]];
////        }
////        @catch(NSException *e) {
////            NSLog(@"Error: %@", e);
////        }
    }

}

// ------------------------------------------------------------------------
//- (void) update {
//    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"libraryValues"] ) {
//        [values setArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"libraryValues"]];
//    }
//}
//
//
//#pragma mark Methods-Sets
//
//// ------------------------------------------------------------------------
//
////
//// Sets
////
//- (BOOL) addPath: (NSString *)path
//       setActive: (BOOL)state {
//
//    NSMutableDictionary *val = [[NSMutableDictionary alloc] init];
//    val[@"active"] = [NSNumber numberWithBool:state];
//    val[@"name"]   = [path lastPathComponent];
//    val[@"path"]   = path;
//
//    BOOL isAdded = FALSE;
//    NSLog(@"addPath: exists: %d", [values containsObject:val]);
//    if ( values && ![values containsObject:val] ) {
//        [values addObject:val];
//        isAdded = TRUE;
//
//        [self saveValues];
//    }
//
//    return isAdded;
//}
//
//- (BOOL) removePath: (NSInteger)row {
//    BOOL isRemoved = FALSE;
//    if (row != 0 && row != 1) {
//        [values removeObjectAtIndex:row];
//        [self.FDTableView noteNumberOfRowsChanged];
//        [self.FDTableView reloadData];
//        isRemoved = TRUE;
//
//        [self saveValues];
//    }
//    
//    return isRemoved;
//}
//
//// ------------------------------------------------------------------------
//- (BOOL) saveValues {
//    // set values
//    [[NSUserDefaults standardUserDefaults] setObject:values forKey:@"libraryValues"];
//
//    // Return the results of attempting to write preferences to system
//    return [[NSUserDefaults standardUserDefaults] synchronize];
//}
//
//
//#pragma mark Methods-Gets
//
//// ------------------------------------------------------------------------
//
////
//// Gets
////
//- (NSMutableArray *) getValues; {
//    return values;
//}
//
//// ------------------------------------------------------------------------
//- (NSString *) getFilepathModal {
//    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
//    [openPanel setCanChooseFiles:YES];
//    [openPanel setCanChooseDirectories:NO];
//    [openPanel setAllowsMultipleSelection:NO];
//    [openPanel setAllowedFileTypes:[[NSArray alloc] initWithObjects:@"js", @"JS", nil]];
//
//    NSString *selected = @"";
//    if ([openPanel runModal] == NSOKButton) {
//        selected = [[[openPanel URLs] objectAtIndex: 0] absoluteString];
//        selected = [selected stringByReplacingOccurrencesOfString:@"file://" withString:@""];
//    }
//
//    return selected;
//}
//
//
//#pragma mark Events
//
//// ------------------------------------------------------------------------
//// Events
//// ------------------------------------------------------------------------
//- (IBAction) addRow: (id)sender {
//    NSString *path = [self getFilepathModal];
//    if (![path isEqualToString:@""]) {
//        [self addPath:path setActive:TRUE];
//
//        [self.FDTableView noteNumberOfRowsChanged];
//        [self.FDTableView reloadData];
//    }
//}
//
//- (IBAction) removeRow: (id)sender {
//    NSInteger row = [self.FDTableView selectedRow];
//    [self removePath:row];
//}
//
//// ------------------------------------------------------------------------
//- (IBAction) setPath: (id)sender {
//    if (sender == FDTableView) {
//        NSInteger row = [sender clickedRow];
//        NSString *path = [self getFilepathModal];
//        if (![path isEqualToString:@""]) {
//            [[values objectAtIndex:row] setObject:[path lastPathComponent] forKey:@"name"];
//            [[values objectAtIndex:row] setObject:path forKey:@"path"];
//        }
//    }
//}
//
//// ------------------------------------------------------------------------
//- (IBAction) setActive: (id)sender {
//    NSLog(@"setActive: %@", sender);
//}


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

        return YES;
//    }
//    else {
//        return NO;
//    }
}



@end

