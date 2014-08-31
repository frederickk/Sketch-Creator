//
//  TemplateTableController.h
//  Sketch Creator
//
//  Created by Ken Frederick on 2014.08.26.
//  Copyright (c) 2014 Ken Frederick. All rights reserved.
//

#import "AppDefaults.h"
#import "FDragController.h"
#import "FPreferences.h"
#import "FUtilities.h"


@interface TemplateTableController : FDragController {
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



@end
