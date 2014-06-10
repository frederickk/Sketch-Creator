//
//  DragController.m
//  DragTableCellDemo
//
//  Created by evan on 12-10-9.
//  Copyright (c) 2012年 acheng. All rights reserved.
//

#import "DragController.h"

@implementation DragController


// ------------------------------------------------------------------------
// Properties
// ------------------------------------------------------------------------
@synthesize cellArray;
@synthesize dragTableView;

#define MyTableCellViewDataType @"MyTableCellViewDataType"



// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------
-(void) awakeFromNib {
//	cellArray = [[NSMutableArray alloc]init];
//	[cellArray addObject:@"aaaaaaaaaaaaaaaaa"];
//	[cellArray addObject:@"cccccccc"];
//	[cellArray addObject:@"bbbbbbbbbbbbbbb"];
//	[cellArray addObject:@"eeeeeeeeeeeeeeeeeeeee"];
//	[cellArray addObject:@"44444444444444444444444444"];
//	[cellArray addObject:@"aaaaaaaaaadfgwerwerwerwerweraaaaaaa"];
//	[cellArray addObject:@"4fsdfsdfsdfdgdfg"];
//	
//	[dragTableView registerForDraggedTypes:[NSArray arrayWithObject:MyTableCellViewDataType] ];
}


// ------------------------------------------------------------------------
- (NSInteger) numberOfRowsInTableView: (NSTableView *)tableView {
	if (tableView == dragTableView) {
		return (int)[cellArray count];
	}
	return 0;
}


- (id) tableView: (NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
             row: (NSInteger)row {
	if (tableView == dragTableView) {
		return [cellArray objectAtIndex:row];
	}
	return NULL;
}

- (void) tableView: (NSTableView *)aTableView
    setObjectValue: (id)anObject
    forTableColumn: (NSTableColumn *)aTableColumn
               row: (NSInteger)rowIndex {
	
}


// ------------------------------------------------------------------------
// Events
// ------------------------------------------------------------------------

// drag operation stuff
- (BOOL) tableView: (NSTableView *)tv
    writeRowsWithIndexes: (NSIndexSet *)rowIndexes
            toPasteboard: (NSPasteboard*)pboard {
    // Copy the row numbers to the pasteboard.
	NSData *zNSIndexSetData = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
	[pboard declareTypes:[NSArray arrayWithObject:MyTableCellViewDataType] owner:self];
	[pboard setData:zNSIndexSetData forType:MyTableCellViewDataType];
	return YES;
}

- (NSDragOperation) tableView: (NSTableView*)tv
                 validateDrop: (id <NSDraggingInfo>)info
                  proposedRow: (NSInteger)row
        proposedDropOperation: (NSTableViewDropOperation)op {
		// Add code here to validate the drop
		// NSLog(@"validate Drop");
	return NSDragOperationEvery;
}

- (BOOL) tableView: (NSTableView *)aTableView
        acceptDrop: (id <NSDraggingInfo>)info
               row: (NSInteger)row
     dropOperation: (NSTableViewDropOperation)operation {

	NSPasteboard* pboard = [info draggingPasteboard];
	NSData* rowData = [pboard dataForType:MyTableCellViewDataType];
	NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
	NSInteger dragRow = [rowIndexes firstIndex];
	
    // Move the specified row to its new location...
    // if we remove a row then everything moves down by one
    // so do an insert prior to the delete
    // --- depends which way we're moving the data!!!
	if (dragRow < row) {
		[cellArray insertObject:[cellArray objectAtIndex:dragRow] atIndex:row];
		[cellArray removeObjectAtIndex:dragRow];
		[self.dragTableView noteNumberOfRowsChanged];
		[self.dragTableView reloadData];
		
		return YES;
	}
	
	NSString * zData = [cellArray objectAtIndex:dragRow];
	[cellArray removeObjectAtIndex:dragRow];
	[cellArray insertObject:zData atIndex:row];
	[self.dragTableView noteNumberOfRowsChanged];
	[self.dragTableView reloadData];
	
	return YES;
}


@end
