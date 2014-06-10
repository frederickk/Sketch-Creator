//
//  Preferences.h
//  Sketch Creator
//
//  Created by Ken Frederick on 2014.06.07.
//  Copyright (c) 2014 Ken Frederick. All rights reserved.
//
//
//  Code inspired by
//  http://iosdevelopertips.com/cocoa/read-and-write-user-preferences.html
//
//  All Content Copyright (c) 2008-2014
//  iOS Developer Tips, All Rights Reserved.
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject


// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------

//
// Sets
//
+ (BOOL) set: (NSString *)sketchPath
    setMouse: (BOOL)bMouse
    setTouch: (BOOL)bTouch
  setKeyboad: (BOOL)bKeyboard
 setDragdrop: (BOOL)bDragdrop
      setCss: (BOOL)bCss
 setWarnings: (BOOL)bWarnings;

+ (BOOL) clear;

//
// Gets
//
+ (NSString *) getSketchPath;

+ (BOOL) getbMouse;
+ (BOOL) getbTouch;
+ (BOOL) getbKeyboard;
+ (BOOL) getbDragdrop;

+ (BOOL) getbCss;
+ (BOOL) getbWarnings;

@end