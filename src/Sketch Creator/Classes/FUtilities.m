//
//  FUtilities.m
//  Sketch Creator
//
//  Created by Ken Frederick on 2014.08.27.
//  Copyright (c) 2014 Ken Frederick. All rights reserved.
//

#import "FUtilities.h"

@implementation FUtilities


#pragma mark Methods-File-Handling

// ------------------------------------------------------------------------
+ (NSString *) createDirectory: (NSString *)dirname
                      withPath: (NSString *)path
                     overwrite: (BOOL)bOverwrite {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL dirSuccess = FALSE;

    // check if directory exists
    if ([fileManager fileExistsAtPath:path]) {
        // display overwrite warning
        if (bOverwrite) {
            // TODO: localized strings
            NSString *info = [NSString stringWithFormat:@"%@, \"%@,\" %@", @"A file with this name", [path lastPathComponent], @"already exists. Are you sure you wish to overwrite?"];
            NSString *msg = [NSString stringWithFormat:@"%@ \"%@\"", @"Overwrite", [path lastPathComponent]];

            bOverwrite = [self warningPrompt: dirname
                                     message: msg
                             informativeText: info];
            [fileManager removeItemAtPath:path error:&error];
        }
    }
    if (![fileManager fileExistsAtPath:path] && bOverwrite) {
        dirSuccess = [fileManager createDirectoryAtPath: path
                            withIntermediateDirectories: NO
                                             attributes: nil
                                                  error: &error];
        if (!dirSuccess) {
            NSLog(@"Directory creation error: %@", error);
            path = nil;
        }
    }

    return path;
}

// ------------------------------------------------------------------------
+ (NSString *) createFile: (NSString *)filename
                 withPath: (NSString *)path
              withContent: (NSString *)content {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileSuccess = FALSE;

    NSString *file = [NSString stringWithFormat:@"%@/%@", path, filename];

    // check if file exists
    if (![fileManager fileExistsAtPath:file]) {
        fileSuccess = [content writeToFile: file
                                atomically: YES
                                  encoding: NSUTF8StringEncoding
                                     error: &error];

        if (!fileSuccess) {
            NSLog(@"File creation error: %@", error);
            file = nil;
        }
    }

    return file;
}


// ------------------------------------------------------------------------
+ (NSString *) copyFile: (NSString *)src
               withPath: (NSString *)dest {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL copySuccess = FALSE;

    // check if file exists
    if ([fileManager fileExistsAtPath:dest]) {
        [fileManager removeItemAtPath:dest error:&error];
    }
    copySuccess = [fileManager copyItemAtPath: src
                                       toPath: dest
                                        error: &error];

    if (!copySuccess) {
        NSLog(@"File copying error: %@", error);
        src = nil;

        // let the user know there was a copying error
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert setMessageText:[error localizedDescription]];
        [alert setInformativeText:[error localizedFailureReason]];
        [alert addButtonWithTitle:@"Dismiss"];
        [alert runModal];
    }

    return src;
}


// ------------------------------------------------------------------------
+ (BOOL) warningPrompt: (NSString *)filename
               message: (NSString *)messageText
       informativeText: (NSString *)infoText {

    BOOL val = FALSE;

    NSAlert *alert = [[NSAlert alloc] init];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert setMessageText:messageText];
    [alert setInformativeText:infoText];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        val = TRUE;
    }

    return val;
}



#pragma mark Methods-Gets

// ------------------------------------------------------------------------

//
// Gets
//

//
//  http://stackoverflow.com/questions/22277117/how-to-find-out-if-the-nsurl-is-a-directory-or-not
//
+ (BOOL) isDirectory: (NSURL *)path {
    NSNumber *isDirectory;
    BOOL success = [path getResourceValue: &isDirectory
                                   forKey: NSURLIsDirectoryKey
                                    error: nil];

    if (success && [isDirectory boolValue]) {
        // NSLog(@"Congratulations, it's a directory!");
        return YES;
    }
    else {
        // NSLog(@"It seems it's just a file.");
        return NO;
    }
}



@end
