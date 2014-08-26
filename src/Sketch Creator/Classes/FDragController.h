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


#import <Cocoa/Cocoa.h>


// ------------------------------------------------------------------------
// Constants
// ------------------------------------------------------------------------
#define FDTableCellViewDataType @"FDTableCellViewDataType"



@interface FDragController : NSObjectController<NSTableViewDataSource, NSTableViewDelegate>


// ------------------------------------------------------------------------
// Properties
// ------------------------------------------------------------------------
@property (assign) IBOutlet NSTableView *FDragTableView;
@property (strong) NSMutableArray *FDragTableValues;




@end
