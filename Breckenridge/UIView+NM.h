//
//  UIView+UIView_PPS.h
//  MXPOS
//
//  Created by Ryan Connelly on 10/4/11.
//  Copyright (c) 2011 Priority Payment Systems, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (NM)

- (void)appear;
- (void)disappear;
- (void)disappearWithDuration:(NSInteger)duration;
- (void)appearWithDuration:(NSInteger)duration;

/** Finds the firstresponder in the view's ancestry. */
- (BOOL)findAndResignFirstResponder;

/** */
- (NSArray *) responderFields;

/** @abstract Returns the first parent that belongs to the specified class.
 */
- (id) parentWithClass:(Class)class;

/** Returns the previous textfield with the same parent. Searches the parent view only. */
- (UIView *) prevTextFieldOrView;

/** Returns the next textfield with the same parent. Searches the parent view only. */
- (UIView *) nextTextFieldOrView;

/** Returns the next textfield. If the textfield is in a tableview, then find the next textfield
 *  inside the table heirarchy. Otherwise, search the parent view.
 */
- (UIView *) nextTextFieldOrViewByTag;

/** Returns the previous textfield. If the textfield is in a tableview, then find the next textfield
 *  inside the table heirarchy.  Otherwise, search the parent view.
 */
- (UIView *) prevTextFieldOrViewByTag;

@end
