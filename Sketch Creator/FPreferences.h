//
//  FPreferences.h
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

@interface FPreferences : NSObject


// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------

//
// Sets
//
- (BOOL) setBool: (BOOL)value forKey: (NSString *)key;
- (BOOL) setFloat: (float)value forKey: (NSString *)key;
- (BOOL) setDouble: (double)value forKey: (NSString *)key;
- (BOOL) setInteger: (NSInteger)value forKey: (NSString *)key;
- (BOOL) setString: (NSString *)value forKey: (NSString *)key;
- (BOOL) setArray: (NSArray *)value forKey: (NSString *)key;

- (BOOL) clear;
- (BOOL) clear: (NSString *)key;

//
// Gets
//
- (BOOL) getBool: (NSString *)key;
- (float) getFloat: (NSString *)key;
- (double) getDouble: (NSString *)key;
- (NSInteger) getInteger: (NSString *)key;
- (NSString *) getString: (NSString*)key;
- (NSArray *) getArray: (NSString *)key;



@end