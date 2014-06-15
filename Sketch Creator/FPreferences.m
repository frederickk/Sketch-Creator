//
//  FPreferences.m
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


#import "FPreferences.h"

@implementation FPreferences


// ------------------------------------------------------------------------
// Constants
// ------------------------------------------------------------------------



#pragma mark Methods

// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------
//- (id) init {
//    return self;
//}


#pragma mark Methods-Sets

//
// Sets
//
- (BOOL) setBool: (BOOL)value
          forKey: (NSString *)key {

    [[NSUserDefaults standardUserDefaults] setBool:value forKey:key];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) setFloat: (float)value
           forKey: (NSString *)key {

    [[NSUserDefaults standardUserDefaults] setFloat:value forKey:key];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) setDouble: (double)value
            forKey: (NSString *)key {

    [[NSUserDefaults standardUserDefaults] setDouble:value forKey:key];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) setInteger: (NSInteger)value
             forKey: (NSString *)key {

    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:key];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) setString: (NSString *)value
            forKey: (NSString *)key {

    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) setArray: (NSArray *)value
           forKey: (NSString *)key {

    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    return [[NSUserDefaults standardUserDefaults] synchronize];
}

// ------------------------------------------------------------------------
- (BOOL) clear {
    NSDictionary *allObjects = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];

    for( NSString *key in allObjects ) {
        [self clear: key];
        //        [[NSUserDefaults standardUserDefaults] removeObjectForKey: key];
    }

    return [[NSUserDefaults standardUserDefaults ] synchronize];
}

- (BOOL) clear: (NSString *)key {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: key];
    return [[NSUserDefaults standardUserDefaults ] synchronize];
}

#pragma mark Methods-Gets

// ------------------------------------------------------------------------

//
// Gets
//
- (BOOL) getBool: (NSString *)key {
    BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if ( value != 0) {
        return value;
    }
    else {
        return NO;
    }
}

- (float) getFloat: (NSString *)key {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:key] != 0) {
        return [[NSUserDefaults standardUserDefaults] floatForKey:key];
    }
    else {
        return (float)0.0;
    }
}

- (double) getDouble: (NSString *)key {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:key] != 0) {
        return [[NSUserDefaults standardUserDefaults] doubleForKey:key];
    }
    else {
        return (double)0.0;
    }
}

- (NSInteger) getInteger: (NSString *)key {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:key] != 0) {
        return [[NSUserDefaults standardUserDefaults] integerForKey:key];
    }
    else {
        return 0;
    }
}

- (NSString *) getString: (NSString*)key {
    NSString *value = [[NSUserDefaults standardUserDefaults] stringForKey:key];
    if( value.length != 0 || value != (id)[NSNull null] ) {
        return value;
    }
    else {
        return @"";
    }
}

- (NSArray *) getArray: (NSString *)key {
    if ( [[NSUserDefaults standardUserDefaults] objectForKey:key] ) {
        return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    }
    else {
        return nil;
    }
}



@end

