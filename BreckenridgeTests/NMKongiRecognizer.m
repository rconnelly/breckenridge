//
//  NMKongiRecognizer.m
//  Breckenridge
//
//  Created by Ryan Connelly on 12/1/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import "NMKongiRecognizer.h"

#import <UIKit/UIKit.h>
//#import "application_headers" as required

@implementation NMKongiRecognizer

// All code under test is in the iOS Application
- (void)testAppDelegate
{
    id yourApplicationDelegate = [[UIApplication sharedApplication] delegate];
    STAssertNotNil(yourApplicationDelegate, @"UIApplication failed to find the AppDelegate");
}

@end
