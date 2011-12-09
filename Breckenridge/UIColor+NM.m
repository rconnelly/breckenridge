//
//  UIColor+NM.m
//  Breckenridge
//
//  Created by Ryan Connelly on 12/9/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import "UIColor+NM.h"

@implementation UIColor (NM)

+ (void) hsl2Rgb:(float )h s:(float) s l:(float) l outR:(float *)outR outG:(float *)outG outB:(float *)outB
{
    float           temp1, temp2;
    float           temp[3];
    int             i;
    
    // Check for saturation. If there isn't any just return the luminance value for each, which results in gray.
    if(s == 0.0) {
        if(outR)
            *outR = l;
        if(outG)
            *outG = l;
        if(outB)
            *outB = l;
        return;
    }
    
    // Test for luminance and compute temporary values based on luminance and saturation 
    if(l < 0.5)
        temp2 = l * (1.0 + s);
    else
        temp2 = l + s - l * s;
    temp1 = 2.0 * l - temp2;
    
    // Compute intermediate values based on hue
    temp[0] = h + 1.0 / 3.0;
    temp[1] = h;
    temp[2] = h - 1.0 / 3.0;
    
    for(i = 0; i < 3; ++i) {
        
        // Adjust the range
        if(temp[i] < 0.0)
            temp[i] += 1.0;
        if(temp[i] > 1.0)
            temp[i] -= 1.0;
        
        
        if(6.0 * temp[i] < 1.0)
            temp[i] = temp1 + (temp2 - temp1) * 6.0 * temp[i];
        else {
            if(2.0 * temp[i] < 1.0)
                temp[i] = temp2;
            else {
                if(3.0 * temp[i] < 2.0)
                    temp[i] = temp1 + (temp2 - temp1) * ((2.0 / 3.0) - temp[i]) * 6.0;
                else
                    temp[i] = temp1;
            }
        }
    }
    
    // Assign temporary values to R, G, B
    if(outR)
        *outR = temp[0];
    if(outG)
        *outG = temp[1];
    if(outB)
        *outB = temp[2];
}

@end
