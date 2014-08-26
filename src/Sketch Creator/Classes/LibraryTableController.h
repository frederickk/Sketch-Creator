//
//  LibraryTable.h
//  Sketch Creator
//
//  Created by Ken Frederick on 2014.06.17.
//  Copyright (c) 2014 Ken Frederick. All rights reserved.
//

#import "FDragController.h"
#import "FPreferences.h"


@interface LibraryTableController : FDragController {
    NSArray *extensions;
}


// ------------------------------------------------------------------------
// Properties
// ------------------------------------------------------------------------
@property (strong) FPreferences *prefs;



// ------------------------------------------------------------------------
// Events
// ------------------------------------------------------------------------
- (IBAction) addRow: (id)sender;
- (IBAction) removeRow: (id)sender;
- (IBAction) setPath: (id)sender;



@end
