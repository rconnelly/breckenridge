//
//  PPSKeyboardManager.h
//  MXPOS
//
//  Created by Ryan Connelly on 10/11/11.
//  Copyright (c) 2011 Priority Payment Systems, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum 
{
  NMKeyboardToolbarNormal = 0,
  NMKeyboardToolbarDone,
  NMKeyboardToolbarCancel,
  NMKeyboardToolbarNextPrev,
  NMKeyboardToolbarNextPrevDone
} NMKeyboardToolbarType;

typedef enum 
{
    NMKeyboardTraverseByTags = 0,
    NMKeyboardTraverseSiblings
} NMKeyboardTraverseFieldsType;

@protocol PPSKeyboardManagerDelegate
- (NMKeyboardToolbarType)keyboardToolbarType;
@end

@interface NMKeyboardManager : NSObject {
    NMKeyboardToolbarType activeToolbarType;
	UIToolbar *doneToolbar;
    UIToolbar *cancelToolbar;
  	UIToolbar *nextPrevToolbar;
  	UIToolbar *_activeToolbar;
    UISegmentedControl *segmentedControl;
    NSInteger keyboardHeight;
    NMKeyboardTraverseFieldsType traverseType;
    BOOL resizeScrollView;
    BOOL typingInTextView;
//    BOOL phoneKeyboardDoneDisabled;
    BOOL autoScrollDisabled;
    UIBarButtonItem *doneButton;
    UIBarButtonItem *nextPrevFlexibleSpace;
//    BOOL editing;
}

@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@property (nonatomic, retain) UIBarButtonItem *doneButton;
@property (nonatomic, retain) UIBarButtonItem *nextPrevFlexibleSpace;
@property (nonatomic) NMKeyboardToolbarType activeToolbarType;
@property (nonatomic) NMKeyboardTraverseFieldsType traverseType;
@property (nonatomic, assign) id firstResponderView;
@property (nonatomic, readonly) UIToolbar *doneToolbar;
@property (nonatomic, readonly) UIToolbar *cancelToolbar;
@property (nonatomic, readonly) UIToolbar *nextPrevToolbar;
@property (nonatomic, readonly) UIToolbar *activeToolbar;
@property(nonatomic, getter=isAutoScrollDisabled) BOOL autoScrollDisabled;
//@property(nonatomic, getter=isPhoneKeyboardDoneDisabled) BOOL phoneKeyboardDoneDisabled;

+ (NMKeyboardManager *)sharedManager;
- (void) nextPrevious:(id) sender;


@end