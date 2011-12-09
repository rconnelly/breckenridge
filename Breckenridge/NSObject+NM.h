//
//  NSObject+NM.h
//  Breckenridge
//
//  Created by Ryan Connelly on 12/9/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NM)
- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
@end
