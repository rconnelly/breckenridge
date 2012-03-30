//
//  UIView+UIView_PPS.m
//  MXPOS
//
//  Created by Ryan Connelly on 10/4/11.
//  Copyright (c) 2011 Priority Payment Systems, Inc. All rights reserved.
//

#import "UIView+NM.h"


@interface UIView ()
- (void) setLayerAlphaAndAnimate:(NSInteger)alpha withDuration:(NSInteger)duration;
- (UIView *) textFieldOrViewAtIndex:(NSInteger)i views:(NSArray *)views;
- (UIView *) getTextFieldOrViewByTag:(NSInteger)tag parentView:(UIView *)parentView;

@end

@implementation UIView (NM)

- (void)appearWithDuration:(NSInteger)duration
{
    [self setLayerAlphaAndAnimate:1 withDuration:duration];
}

- (void)disappearWithDuration:(NSInteger)duration
{
    [self setLayerAlphaAndAnimate:0 withDuration:duration];
}

- (void)appear
{
    [self setLayerAlphaAndAnimate:1 withDuration:0.3];
}

- (void)disappear
{    
    [self setLayerAlphaAndAnimate:0 withDuration:0.3];
}

- (void) setLayerAlphaAndAnimate:(NSInteger)alpha_ withDuration:(NSInteger)duration
{
    if(self.hidden && alpha_ > 0)
    {
        self.hidden = NO;
    }
    
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    self.alpha = alpha_;
    
    [UIView commitAnimations];
    
    // make sure that the element is hidden (or not)
    [self performBlock:^{
        self.hidden = (alpha_ == 0) ? YES : NO;
    } afterDelay:duration];
}

- (NSArray *) responderFields {  
    NSMutableArray *fields = [[NSMutableArray alloc] init];  
    NSInteger tag = 1;  
    UIView *aView;  
    while(YES)
    {
        aView = [self viewWithTag:tag];
        if(!aView)
            break;
        
        bool responderEnabled = [aView respondsToSelector:@selector(isEnabled)] && [(id)aView isEnabled];
        
        if([[aView class] isSubclassOfClass:[UIResponder class]]
           && !aView.isHidden && responderEnabled)
        {
            [fields addObject:aView];
        }
        tag++;  
    }
    return fields; 
}  

- (id) parentWithClass:(Class)cl
{
    
    UIView *parentView = [self superview];
    while (parentView) {
        if([parentView isKindOfClass:cl])
        {
            return (UIScrollView *)parentView;
        }
        parentView = [parentView superview];
    }
    
    return nil;
}

- (BOOL)findAndResignFirstResponder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;     
    }
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}


- (UIView *) textFieldOrViewAtIndex:(NSInteger)i views:(NSArray *)views
{
    UIView *view = [views objectAtIndex:i];
    if([view isKindOfClass:[UITextField class]] || 
       [view isKindOfClass:[UITextView class]] )
    {
        return view;
    }
    
    return nil;
}

- (UIView *) parentViewOrTableView
{
    UIView *tableView = [self parentWithClass:[UITableView class]]; // use the tableview if one exists
    UIView *parentView = (tableView) ? tableView : [self superview];
    return parentView;
}


- (UIView *) getTextFieldOrViewByTag:(NSInteger)tag parentView:(UIView *)parentView
{
    id view = [parentView viewWithTag:tag];
    if(![view isKindOfClass:[UITextField class]] &&
       ![view isKindOfClass:[UITextView class]])
        return nil;
    
    return view;
}

- (UIView *) nextTextFieldOrViewByTag
{
    int nextTag = [self tag]+1;
    UIView *parentView = [[self superview] parentViewOrTableView]; // use the tableview if one exists
    UIView *retVal = nil;
    while (nextTag < self.tag+50) { // go at most 50 tags to find the next one
      retVal = [self getTextFieldOrViewByTag:nextTag parentView:parentView];  
        if(retVal && !retVal.hidden) // stop if you find one
            return retVal;
        nextTag ++;
    }
    
    return nil;
}

- (UIView *) prevTextFieldOrViewByTag
{
    int prevTag = [self tag]-1;
    UIView *parentView = [[self superview] parentViewOrTableView]; // use the tableview if one exists
    UIView *retVal = nil;
    while (prevTag > self.tag-50) { // go at most 50 tags to find the prev one
        retVal = [self getTextFieldOrViewByTag:prevTag parentView:parentView];  
        if(retVal && !retVal.hidden) // stop if you find one
            return retVal;
        prevTag--;
    }
    
    return nil;    
}

- (UIView *) nextTextFieldOrView
{
    NSArray *siblings = [[self superview] subviews];
    NSInteger index = [siblings indexOfObject:self];  
    for(int i = index+1; i < [siblings count]; i++)
    {
        UIView *view = [self textFieldOrViewAtIndex:i views:siblings];
        if(view)
            return view;
    }
    
    return nil;
}

- (UIView *) prevTextFieldOrView
{    
    NSArray *siblings = [[self superview] subviews];
    NSInteger index = [siblings indexOfObject:self];
    for(int i = index-1; i >= 0; i--)
    {
        UIView *view = [self textFieldOrViewAtIndex:i views:siblings];
        if(view)
            return view;
    }
    
    return nil;
}


@end
