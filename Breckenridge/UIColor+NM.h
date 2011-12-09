//
//  UIColor+NM.h
//  Breckenridge
//
//  Created by Ryan Connelly on 12/9/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (NM)

+ (void) hsl2Rgb:(float )h s:(float) s l:(float) l outR:(float *)outR outG:(float *)outG outB:(float *)outB;
@end
