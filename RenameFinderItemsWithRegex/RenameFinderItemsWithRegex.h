//
//  RenameFinderItemsWithRegex.h
//  RenameFinderItemsWithRegex
//
//  Created by Patrick Marschik on 2013-09-27.
//  Copyright (c) 2013 Patrick Marschik. All rights reserved.
//

#import <Automator/AMBundleAction.h>

@interface RenameFinderItemsWithRegex : AMBundleAction
{
	// regex params
	BOOL caseInsensitive;
	int options;
	
	NSString *pattern;
	NSString *replace;
	NSInteger component;
}

- (id)initWithDefinition:(NSDictionary *)dict fromArchive:(BOOL)archived;

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;

- (void)updateParameters;

@end
