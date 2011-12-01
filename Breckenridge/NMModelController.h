//
//  NMModelController.h
//  Breckenridge
//
//  Created by Ryan Connelly on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NMDataViewController;

@interface NMModelController : NSObject <UIPageViewControllerDataSource>
- (NMDataViewController *)viewControllerAtIndex:(NSUInteger)index storyboard:(UIStoryboard *)storyboard;
- (NSUInteger)indexOfViewController:(NMDataViewController *)viewController;
@end
