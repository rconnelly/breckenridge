//
//  NMSetupViewController.h
//  Breckenridge
//
//  Created by Ryan Connelly on 12/2/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMGestureDrawView.h"
@class NMGestureViewController;

@interface NMSetupViewController : UIViewController <UITextFieldDelegate, NMGestureDrawViewDelegate>
{
    id textFieldFirstResponder;
}
@property (strong, nonatomic) NMGestureViewController *gestureViewController;
@property (weak, nonatomic) IBOutlet UIView *gestureParentView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end
