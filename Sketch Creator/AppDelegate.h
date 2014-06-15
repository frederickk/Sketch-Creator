//
//  AppDelegate.h
//  Sketch Creator
//
//  Created by Ken Frederick on 2014.06.07.
//  Copyright (c) 2014 Ken Frederick. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FPreferences.h"


@interface AppDelegate : NSObject <NSApplicationDelegate> {
    BOOL bOverwrite;
}


// ------------------------------------------------------------------------
// Properties
// ------------------------------------------------------------------------
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPanel *panel;

@property (weak) NSArray *libraryValues;

@property (weak) IBOutlet NSTextField *sketchName;
@property (weak) IBOutlet NSTextField *sketchPath;

@property (weak) IBOutlet NSButton *bMouse;
@property (weak) IBOutlet NSButton *bTouch;
@property (weak) IBOutlet NSButton *bKeyboard;
@property (weak) IBOutlet NSButton *bDragdrop;

@property (weak) IBOutlet NSButton *bCss;
@property (weak) IBOutlet NSButton *bBrowser;
@property (weak) IBOutlet NSButton *bWarnings;

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
