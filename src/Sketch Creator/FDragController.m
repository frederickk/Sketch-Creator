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
// Properties
// ------------------------------------------------------------------------
@synthesize FDragTableView;
@synthesize FDragTableValues;



#pragma mark Methods

// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------
- (void) awakeFromNib {
    // inits
    FDragTableValues = [[NSMutableArray alloc] init];
}


#pragma mark Methods-Inherited

// ------------------------------------------------------------------------

//
// Inherited from NSTableViewDataSource
//

// Get
- (NSInteger) numberOfRowsInTableView: (NSTableView *)tableView {
    if (tableView == self.FDragTableView) {
        return (int)[FDragTableValues count];
    }
    return 0;
}

- (id) tableView: (NSTableView *)tableView
objectValueForTableColumn: (NSTableColumn *)column
                      row: (NSInteger)row {

    if (tableView == self.FDragTableView) {
        return [[FDragTableValues objectAtIndex:row] valueForKey:[column identifier]];
    }

    return nil;
}

// Set
- (void) tableView: (NSTableView *)tableView
    setObjectValue: (id)value
    forTableColumn: (NSTableColumn *)column
               row: (NSInteger)row {

    if (tableView == self.FDragTableView) {
        [[FDragTableValues objectAtIndex:row] setValue:value forKey:[column identifier]];
    }
}


#pragma mark Events-Drag

// ------------------------------------------------------------------------
// Events
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
            [FDragTableValues insertObject:[FDragTableValues objectAtIndex:dragRow] atIndex:row];
            [FDragTableValues removeObjectAtIndex:dragRow];
            [self.FDragTableView noteNumberOfRowsChanged];
            [self.FDragTableView reloadData];

            return YES;
        }

        NSString *zData = [FDragTableValues objectAtIndex:dragRow];
        [FDragTableValues removeObjectAtIndex:dragRow];
        [FDragTableValues insertObject:zData atIndex:row];
        [self.FDragTableView noteNumberOfRowsChanged];
        [self.FDragTableView reloadData];

        return YES;
//    }
//    else {
//        return NO;
//    }
}



@end

