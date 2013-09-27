//
//  RenameFinderItemsWithRegex.h
//  RenameFinderItemsWithRegex
//
//  Created by Patrick Marschik on 2013-09-27.
//  Copyright (c) 2013 Patrick Marschik. All rights reserved.
//

#import <Automator/AMBundleAction.h>

@interface RenameFinderItemsWithRegex : AMBundleAction

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;

@end
