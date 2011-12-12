//
//  NMSetupViewController.h
//  Breckenridge
//
//  Created by Ryan Connelly on 12/2/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NMGestureDrawView.h"
#import "ThirdParty/MultistrokeGestureRecognizer-iOS/WTMGlyph/WTMGlyphDelegate.h"

@class NMGestureViewController, WTMGlyphDetector, NMGestureDrawView;

@interface NMGlyphSearchViewController : UIViewController <UITextFieldDelegate, NMGestureDrawViewDelegate, WTMGlyphDelegate, UITableViewDelegate, UITableViewDataSource>
{
    id textFieldFirstResponder;
}
@property (strong, nonatomic) NMGestureViewController *gestureViewController;
@property (strong, nonatomic) NSMutableArray *searchPhrases;
@property (strong, nonatomic) NSMutableArray *listItems;
@property (strong, nonatomic) NSMutableArray *filteredListItems;
@property (weak, nonatomic) IBOutlet UIView *gestureParentView;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UILabel *foundItemLabel;
@property (strong, nonatomic) WTMGlyphDetector *glyphDetector;
@property (weak, nonatomic) NMGestureDrawView *gdv;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;

- (NSMutableArray *) items;
@property (weak, nonatomic) IBOutlet UIButton *gestureButton;
- (IBAction)gestureButtonTouched:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *gestureLabel;

@end
