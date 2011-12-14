//
//  NSManagedObjectContext+NM.m
//  Breckenridge
//
//  Created by Ryan Connelly on 12/13/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import "NSManagedObjectContext+NM.h"

@implementation NSManagedObjectContext (NM)

- (void) save
{
    NSError *error = nil;
    [self save:&error];
    if(error)
    {
        DebugLog(@"Could not save managed object context. %@", error);
    }
}

@end
