//
//  DragController.h
//  DragTableCellDemo
//
//  Created by evan on 12-10-9.
//  Copyright (c) 2012年 acheng. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DragController : NSObjectController<NSTableViewDataSource, NSTableViewDelegate>



// ------------------------------------------------------------------------
// Properties
// ------------------------------------------------------------------------
@property (assign) NSMutableArray *cellArray;
@property (assign) IBOutlet NSTableView *dragTableView;



@end
