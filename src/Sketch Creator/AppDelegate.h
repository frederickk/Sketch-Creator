//
//  AppDelegate.h
//  Sketch Creator
//
//  Created by Ken Frederick on 2014.06.07.
//  Copyright (c) 2014 Ken Frederick. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import "AppDefaults.h"
#import "FPreferences.h"


@interface AppDelegate : NSObject <NSApplicationDelegate> {
    BOOL bOverwrite;
    NSArray *browserBundleList;
}


// ------------------------------------------------------------------------
// Properties
// ------------------------------------------------------------------------
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPanel *panel;

@property (weak) NSArray *libraryValues;

@property (weak) IBOutlet NSTextField *sketchName;
@property (weak) IBOutlet NSTextField *sketchPath;

@property (weak) IBOutlet NSButton *hasMouse;
@property (weak) IBOutlet NSButton *hasTouch;
@property (weak) IBOutlet NSButton *hasKeyboard;
@property (weak) IBOutlet NSButton *hasDragdrop;

@property (weak) IBOutlet NSButton *hasCss;
@property (weak) IBOutlet NSButton *hasBrowser;
@property (weak) IBOutlet NSPopUpButton *browserPopup;
@property (weak) IBOutlet NSButton *hasWarnings;

// preferences
@property (strong) FPreferences *prefs;



// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------



// ------------------------------------------------------------------------
// Events
// ------------------------------------------------------------------------
- (IBAction) onCreate: (id)sender;
- (IBAction) chooseSketchPath: (id)sender;

- (IBAction) onClose: (id)sender;

@end
