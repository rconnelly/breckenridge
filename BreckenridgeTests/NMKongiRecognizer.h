//
//  NMKongiRecognizer.h
//  Breckenridge
//
//  Created by Ryan Connelly on 12/1/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

//  Application unit tests contain unit test code that must be injected into an application to run correctly.
//  See Also: http://developer.apple.com/iphone/library/documentation/Xcode/Conceptual/iphone_development/135-Unit_Testing_Applications/unit_testing_applications.html

#import <SenTestingKit/SenTestingKit.h>

@interface NMKongiRecognizer : SenTestCase

/** Ensure that the grid has the correct number of square regions and that they are all uniform
    in size. */
- (void) testThatGridIsValid;

//- (void) testThatBox

@end
