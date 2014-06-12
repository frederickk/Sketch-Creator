//
//  Preferences.m
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


#import "Preferences.h"

@implementation Preferences


// ------------------------------------------------------------------------
// Constants
// ------------------------------------------------------------------------
// TODO: move to seperate file?
#define DEFAULT_MOUSE 0
#define DEFAULT_TOUCH 0
#define DEFAULT_KEYBOARD 0
#define DEFAULT_DRAGDROP 0
#define DEFAULT_CSS 1
#define DEFAULT_WARNINGS 0



#pragma mark Methods

// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------

#pragma mark Methods-Sets

//
// Sets
//
+ (BOOL) set: (NSString *)sketchPath
    setMouse: (BOOL)bMouse
    setTouch: (BOOL)bTouch
  setKeyboad: (BOOL)bKeyboard
 setDragdrop: (BOOL)bDragdrop
      setCss: (BOOL)bCss
 setWarnings: (BOOL)bWarnings {

    // Set values
    [[NSUserDefaults standardUserDefaults] setObject:sketchPath forKey:@"sketchPath"];
    [[NSUserDefaults standardUserDefaults] setBool:bMouse forKey:@"bMouse"];
    [[NSUserDefaults standardUserDefaults] setBool:bTouch forKey:@"bTouch"];
    [[NSUserDefaults standardUserDefaults] setBool:bKeyboard forKey:@"bKeyboard"];
    [[NSUserDefaults standardUserDefaults] setBool:bDragdrop forKey:@"bDragdrop"];
    [[NSUserDefaults standardUserDefaults] setBool:bCss forKey:@"bCss"];
    [[NSUserDefaults standardUserDefaults] setBool:bWarnings forKey:@"bWarnings"];

    // Return the results of attempting to write preferences to system
    return [[NSUserDefaults standardUserDefaults] synchronize];

    // for Debugging
//    return [self clear];
}

// ------------------------------------------------------------------------
+ (BOOL) clear {
    NSDictionary *allObjects = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];

    for( NSString *key in allObjects ) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey: key];
    }

    return [[NSUserDefaults standardUserDefaults ] synchronize];
}


#pragma mark Methods-Gets

// ------------------------------------------------------------------------

//
// Gets
//
+ (NSString *) getSketchPath {
    NSString *path = [[NSUserDefaults standardUserDefaults] stringForKey:@"sketchPath"];

    if( path.length != 0 || path != (id)[NSNull null] ) {
        return path;
    }
    else {
        NSArray *paths = NSSearchPathForDirectoriesInDomains
                        (NSDocumentDirectory, NSUserDomainMask, YES);
        return [[paths objectAtIndex:0] stringByAppendingString:@"/Processing"];
    }
}

// ------------------------------------------------------------------------
+ (BOOL) getbMouse {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"bMouse"] != 0) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"bMouse"];
    }
    else {
        return DEFAULT_MOUSE;
    }
}

+ (BOOL) getbTouch {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"bTouch"] != 0) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"bTouch"];
    }
    else {
        return DEFAULT_TOUCH;
    }
}

+ (BOOL) getbKeyboard {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"bKeyboard"] != 0) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"bKeyboard"];
    }
    else {
        return DEFAULT_KEYBOARD;
    }
}

+ (BOOL) getbDragdrop {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"bDragdrop"] != 0) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"bDragdrop"];
    }
    else {
        return DEFAULT_DRAGDROP;
    }
}

// ------------------------------------------------------------------------
+ (BOOL) getbCss {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"bCss"] != 0) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"bCss"];
    }
    else {
        return DEFAULT_CSS;
    }
}

+ (BOOL) getbWarnings {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"bWarnings"] != 0) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:@"bWarnings"];
    }
    else {
        return DEFAULT_WARNINGS;
    }
}

// ------------------------------------------------------------------------
+ (NSArray *) getLibraryValues {
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"libraryValues"] ) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:@"libraryValues"];
    }
    else {
        return nil;
    }
}



@end

