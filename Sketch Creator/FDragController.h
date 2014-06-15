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
#import "FPreferences.h"

@interface FDragController : NSObjectController<NSTableViewDataSource, NSTableViewDelegate>{
}


// ------------------------------------------------------------------------
// Properties
// ------------------------------------------------------------------------
@property (assign) IBOutlet NSTableView *FDTableView;
@property (strong) NSMutableArray *values;

// preferences
@property (strong) FPreferences *prefs;



// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------



// ------------------------------------------------------------------------
// Events
// ------------------------------------------------------------------------
- (IBAction) setPath: (id)sender;
- (IBAction) addRow: (id)sender;
- (IBAction) removeRow: (id)sender;

//- (IBAction) setActive: (id)sender;



@end
