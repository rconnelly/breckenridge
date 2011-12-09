//
//  NMButtonView.m
//  Breckenridge
//
//  Created by Ryan Connelly on 12/9/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import "NMButton.h"

@implementation NMButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *greenButtonImage = [UIImage imageNamed:@"greenButton.png"];
        UIImage *stretchableGreenButton = [greenButtonImage stretchableImageWithLeftCapWidth:12 topCapHeight:0];
        [self setBackgroundImage:stretchableGreenButton forState:UIControlStateNormal];
        
        UIImage *darkGreenButtonImage = [UIImage imageNamed:@"greenButtonActivated.png"];
        UIImage *stretchabledarkGreenButton = [darkGreenButtonImage stretchableImageWithLeftCapWidth:12 topCapHeight:0];
        [self setBackgroundImage:stretchabledarkGreenButton forState:UIControlStateHighlighted];
        
    }
    return self;
}

@end
