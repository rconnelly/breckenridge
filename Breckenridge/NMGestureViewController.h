//
//  NMGestureViewController.h
//  Breckenridge
//
//  Created by Ryan Connelly on 12/9/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMGestureDrawView.h"

#define kPaletteHeight          30
#define kPaletteSize            5
#define kMinEraseInterval       0.5

// Padding for margins
#define kLeftMargin             10.0
#define kTopMargin              10.0
#define kRightMargin            10.0



@interface NMGestureViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *exitButton;
- (IBAction)exitButtonTouched:(id)sender;
@property (weak, nonatomic) NMGestureDrawView *drawingView;
@end
