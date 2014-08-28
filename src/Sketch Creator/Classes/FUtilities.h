//
//  FUtilities.h
//  Sketch Creator
//
//  Created by Ken Frederick on 2014.08.27.
//  Copyright (c) 2014 Ken Frederick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FUtilities : NSObject {
}


// ------------------------------------------------------------------------
// Properties
// ------------------------------------------------------------------------



// ------------------------------------------------------------------------
// Methods
// ------------------------------------------------------------------------
+ (NSString *) createDirectory: (NSString *)dirname withPath: (NSString *)path overwrite: (BOOL)bOverwrite;
+ (NSString *) createFile: (NSString *)filename withPath: (NSString *)path withContent: (NSString *)content;
+ (NSString *) copyFile: (NSString *)src withPath: (NSString *)dest;

+ (BOOL) warningPrompt: (NSString *)filename message: (NSString *)messageText informativeText: (NSString *)infoText;

+ (BOOL) isDirectory: (NSURL *)path;



@end
