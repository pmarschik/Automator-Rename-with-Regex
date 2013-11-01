//
//  RenameFinderItemsWithRegex.m
//  RenameFinderItemsWithRegex
//
//  Created by Patrick Marschik on 2013-09-27.
//  Copyright (c) 2013 Patrick Marschik. All rights reserved.
//

#import <Foundation/NSRegularExpression.h>
#import <Automator/AMAction.h>

#import "RenameFinderItemsWithRegex.h"

#define RRX_OPT_CASEINSENSITIVE @"caseInsensitive"
#define RRX_PATTERN             @"pattern"
#define RRX_REPLACE             @"replace"
#define RRX_COMPONENT           @"component"

@interface RenameFinderItemsWithRegex ()

- (void)updateParametersWithDictionary:(NSDictionary *)parameters;

@end

@implementation RenameFinderItemsWithRegex

#pragma mark Initializers

- (id)initWithDefinition:(NSDictionary *)dict
			 fromArchive:(BOOL)archived
{
	self = [super initWithDefinition:dict fromArchive:archived];
	
	if (!self) return self;
	
	NSDictionary *parameters = dict[@"ActionParameters"];
	[self updateParametersWithDictionary:parameters];
	
	return self;
}

#pragma mark Private Methods

- (void)updateParametersWithDictionary:(NSDictionary *)parameters
{
	caseInsensitive = [parameters[RRX_OPT_CASEINSENSITIVE] boolValue];
    if (caseInsensitive) options = NSRegularExpressionCaseInsensitive;
    
	pattern = parameters[RRX_PATTERN];
	replace = parameters[RRX_REPLACE];
	component = [parameters[RRX_COMPONENT] intValue];
}

#pragma mark Implementation of AMBundleAction

- (void)updateParameters
{
	[self updateParametersWithDictionary:[self parameters]];
}

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo
{
    if (!input || !(pattern))
        return nil;
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:options
                                                                             error:&error];
    
    NSLog(@"pattern: %@, caseInsensitive: %d, replacement: %@, component: %ld, options: %d", pattern, caseInsensitive, replace, (long)component, options);
	
    if (!regex){
        NSLog(@"Invalid regex: %@, %@", pattern, error);
        *errorInfo = @{NSAppleScriptErrorMessage: @"Error in regular expression."};
        return nil;
    }
	
    if (!replace){
        NSLog(@"No replacement provided.");
        *errorInfo = @{NSAppleScriptErrorMessage: @"No replacement specified."};
        return nil;
    }
	
    NSArray *inputArray = [input isKindOfClass:[NSArray class]] ? input : @[input];
    NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:[inputArray count]];
	
    for (NSString *originalPath in inputArray) {
        NSString *basepath = [originalPath stringByDeletingLastPathComponent];
        NSString *filename = [originalPath lastPathComponent];
        NSString *extension = [filename pathExtension];
		
        /* if filename only remove extension */
        if (component == 1 && [extension length] != 0) {
            NSRange replaceRange = NSMakeRange([filename length] - [extension length] - 1, [extension length] + 1);
            filename = [filename stringByReplacingCharactersInRange:replaceRange withString:@""];
        }
        
        NSLog(@"Filename: %@, Extension: %@", filename, extension);
		
        // keep original when we didn't select full path
        NSString *renamedFilename = filename;
        NSString *renamedExtension = extension;
        NSRange filenameRange = NSMakeRange(0, [filename length]);
        NSRange extensionRange = NSMakeRange(0, [extension length]);
        
        NSLog(@"Range: Filename: %lu/%lu, Extension: %lu/%lu", (unsigned long)filenameRange.location, (unsigned long)filenameRange.length, (unsigned long)extensionRange.location, (unsigned long)extension.length);
		
        if(component == 0 || component == 1) {
            /* complete or filename only */
            NSLog(@"matches: %lu", (unsigned long)[regex numberOfMatchesInString:filename options:0 range:filenameRange]);
            renamedFilename = [regex stringByReplacingMatchesInString:filename
                                                              options:0
                                                                range:filenameRange
                                                         withTemplate:replace];
        }
        else if(component == 2) {
            /* extension only */
            renamedExtension = [regex stringByReplacingMatchesInString:extension
                                                               options:0
                                                                 range:extensionRange
                                                          withTemplate:replace];
        }
            
        NSLog(@"Filename: %@, Extension: %@", filename, extension);
        NSLog(@"Renamed: Filename: %@, Extension %@", renamedFilename, renamedExtension);
        
        NSString *renamedPath = renamedFilename;
		
        if (component == 1 || component == 2) /* if we separated filename/extension ... */
            renamedPath = [renamedFilename stringByAppendingPathExtension:renamedExtension];
		
        if (!renamedPath || [renamedPath length] == 0) {
            NSLog(@"resulting in empty filename");
            *errorInfo = @{NSAppleScriptErrorNumber: @"Replacement would result in an empty filename."};
            return nil;
        }
		
        renamedPath = [basepath stringByAppendingPathComponent:renamedPath];
        
        NSLog(@"originalPath: %@, renamedPath: %@", originalPath, renamedPath);
		
        NSError *error;
        BOOL success = [[NSFileManager defaultManager] moveItemAtPath:originalPath
                                                               toPath:renamedPath
                                                                error:&error];

        if(!success) {
            NSLog(@"Error renaming file: %@", [error description]);
        }
		
        [returnArray addObject:renamedPath];
    }
	
    return returnArray;
}

@end
