//
//  NMKeyboardManager.m
//  MXPOS
//
//  Created by Ryan Connelly on 10/11/11.
//  Copyright (c) 2011 Nomad Apps, LLC All rights reserved.
//

#import "NMKeyboardManager.h"

static NMKeyboardManager *sharedManager = nil;

@interface NMKeyboardManager (Private)
- (void)scrollToTextField:(UITextField *)textField;
- (void)scrollToTableCellTextField:(UITextField *)textField;
- (void) increaseScrollViewHeight:(NSNumber *) newHeight;
- (NSInteger) keyboardHeightFromNotification:(NSNotification *)notification;
- (void)scrollTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath;
- (void)scrollToCursor;
- (void) ensureResponderIsVisible;
- (void)textDidBeginEditing:(NSNotification *)notification;
- (void)textViewDidBeginEditing:(NSNotification *)notification;
//- (void) showDoneButton:(BOOL) show;
@end

@implementation NMKeyboardManager
@synthesize segmentedControl, nextPrevFlexibleSpace;
@synthesize activeToolbarType, firstResponderView, doneToolbar, nextPrevToolbar, activeToolbar = _activeToolbar;
@synthesize traverseType;
@synthesize autoScrollDisabled;
//@synthesize phoneKeyboardDoneDisabled;
@synthesize doneButton;
+ (void)initialize
{
	sharedManager = [[NMKeyboardManager alloc] init];
}

+ (NMKeyboardManager *)sharedManager
{
	return sharedManager;
}


- (id)init
{
	self = [super init];
    if(self)
    {
#ifndef DISABLE_KEYBOARDMANAGER
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keybDidHide:) name:UIKeyboardDidHideNotification object:nil];
#endif

    }
	return self;
}

- (UIColor *) tintColor
{
    UIColor *tintColor = [UIColor colorWithRed:0.184 green:0.227 blue:0.235 alpha:1.0];
    return tintColor;
}

- (UIToolbar *)doneToolbar
{
	if (!doneToolbar) {
		doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		doneToolbar.barStyle = UIBarStyleBlack;
		doneToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        doneToolbar.tintColor = [self tintColor];
		UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
		UIBarButtonItem *dButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done:)];
		doneToolbar.items = [NSArray arrayWithObjects:flexibleSpace, dButton, nil];
        
	}
	return doneToolbar;
}

- (UIToolbar *)cancelToolbar
{
	if (!cancelToolbar) {
		cancelToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		cancelToolbar.barStyle = UIBarStyleBlack;
		cancelToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        cancelToolbar.tintColor = [self tintColor];
		UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil action:nil];
        
		UIBarButtonItem *dButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered
                                                                   target:self action:@selector(done:)];
		cancelToolbar.items = [NSArray arrayWithObjects:flexibleSpace, dButton, nil];
        
	}
	return cancelToolbar;
}

- (UIToolbar *)getActiveToolbar
{
    switch (activeToolbarType) {
        case NMKeyboardToolbarDone:
            return [self doneToolbar];
            break;
        case NMKeyboardToolbarCancel:
            return [self cancelToolbar];
            break;
        case NMKeyboardToolbarNextPrev:
        case NMKeyboardToolbarNextPrevDone:
            return [self nextPrevToolbar];
        default:
            return nil;
            break;
    }
    
}


- (UIToolbar *)nextPrevToolbar
{
	if (!nextPrevToolbar) {
        UIColor *tintColor = [self tintColor];
		nextPrevToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		nextPrevToolbar.barStyle = UIBarStyleBlack;
		nextPrevToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		nextPrevToolbar.tintColor = tintColor;
		nextPrevFlexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        NSArray *segItems = [NSArray arrayWithObjects:
                          NSLocalizedString(@"Previous",@"Previous form field"),
                          NSLocalizedString(@"Next",@"Next form field"),                                         
                          nil];
        segmentedControl = [[UISegmentedControl alloc] initWithItems:segItems];
        segmentedControl.tintColor = tintColor;
        segmentedControl.momentary = YES;
        [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
        [segmentedControl addTarget:self action:@selector(nextPrevious:) forControlEvents:UIControlEventValueChanged]; 
        UIBarButtonItem *segmentedBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
        UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done:)];
        NSMutableArray *items = [NSMutableArray arrayWithObjects:segmentedBarButtonItem, nextPrevFlexibleSpace, nil];
        if(activeToolbarType == NMKeyboardToolbarNextPrevDone)
        {
            [items addObject:done];
        }
        nextPrevToolbar.items = items;
	}
	return nextPrevToolbar;
}

- (void)nextPrevious:(id)sender
{
    if (nil == self.firstResponderView || ![self.firstResponderView isKindOfClass:[UITextField class]] || autoScrollDisabled) {
        return;
    }
    
    UIView *field1 = self.firstResponderView;
    UIView *field2 = nil;

    switch([(UISegmentedControl *)sender selectedSegmentIndex]) {
        case 0:
            field2 = (traverseType == NMKeyboardTraverseByTags) ? [field1 prevTextFieldOrViewByTag] : [field1 prevTextFieldOrView];
            break;
        case 1:
            field2 = (traverseType == NMKeyboardTraverseByTags) ? [field1 nextTextFieldOrViewByTag] : [field1 nextTextFieldOrView];
            break;
    }

    [field2 becomeFirstResponder];
}

#pragma mark - UITextField notifications

- (void)textDidBeginEditing:(NSNotification *)notification
{
    if([self getActiveToolbar])
        self.firstResponderView = [notification object];    
}

- (void)textViewDidBeginEditing:(NSNotification *)notification
{
    if([self getActiveToolbar])
        self.firstResponderView = [notification object];    
}

#pragma mark - Scroll Helper Methods

- (void)scrollToTextField:(UITextField *)textField
{
    if(!textField)
        return;
    
    UIScrollView *scrollView =  [textField parentWithClass:[UIScrollView class]];
    CGRect rect = textField.bounds;
    CGRect convertedRect = [scrollView convertRect:rect fromView:textField];
    convertedRect.size.height += 10; // for padding
	[scrollView scrollRectToVisible:convertedRect animated:YES];
}

- (void)scrollToTableCellTextField:(UITextField *)textField
{
    UITableViewCell *tableCell = [firstResponderView parentWithClass:[UITableViewCell class]];
    UITableView *tableView = [firstResponderView parentWithClass:[UITableView class]];
    [self scrollTableView:tableView indexPath:[tableView indexPathForCell:tableCell]];
}

- (void)scrollTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) 
    {
        UITableViewCell *thisCell = (UITableViewCell *)[[(UIView *)self.firstResponderView superview] superview];
        indexPath = [tableView indexPathForCell:thisCell];
    }
    [tableView scrollToRowAtIndexPath:indexPath
                     atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - Keyboard notifications

- (void) ensureResponderIsVisible
{
    if(!autoScrollDisabled)
    {
        if(![firstResponderView isKindOfClass:[UITextField class]] &&
           ![firstResponderView isKindOfClass:[UITextView class]])
            return;
        
        UIScrollView *scrollView = [firstResponderView parentWithClass:[UIScrollView class]];
        UITableView *tableView = [firstResponderView parentWithClass:[UITableView class]];
        
        if(tableView) { // Handle table view
            [self scrollToTableCellTextField:firstResponderView];
        }
        else if(scrollView) // Handle scroll views
        {
            
            [self increaseScrollViewHeight:[NSNumber numberWithInt:-keyboardHeight]];
            [self scrollToTextField:firstResponderView];  
            resizeScrollView = YES;
        }
    }
}

- (void)keybDidShow:(NSNotification *)notification
{
    [self ensureResponderIsVisible];
}
/*
- (void) showDoneButton:(BOOL) show
{
    if(show)
    {
        self.activeToolbar.items = [NSMutableArray arrayWithObjects:segmentedControl, nextPrevFlexibleSpace, done, nil];
    }
    else
    {
        self.activeToolbar.items = [NSMutableArray arrayWithObjects:segmentedControl, nextPrevFlexibleSpace, nil];
    }
}
*/
- (void)keybWillShow:(NSNotification *)notification
{
    keyboardHeight = [self keyboardHeightFromNotification:notification];
    _activeToolbar = [self getActiveToolbar];

    if(!self.activeToolbar)
        return;
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	NSDictionary *userInfo = [notification userInfo];
	
    NSValue *frm = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect frame;
    [frm getValue:&frame];
    
	CGFloat yOffset = (frame.size.height/2.0)+44;
	CGPoint beginCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    
	if (![[self activeToolbar] isDescendantOfView:window]) {
		[self activeToolbar].alpha = 0.0;
		[self activeToolbar].frame = CGRectMake(0, beginCenter.y-yOffset, window.bounds.size.width, 44);
		[window addSubview:[self activeToolbar]];
	}
	
	[UIView beginAnimations:nil context:NULL];
	
	NSValue *ac = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	UIViewAnimationCurve animCurve = 0;
	[ac getValue:&animCurve];
	[UIView setAnimationCurve:animCurve];
	
	NSValue *ad = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animDur = 0;
	[ad getValue:&animDur];
	[UIView setAnimationDuration:animDur];
	
    frm = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    [frm getValue:&frame];
    
	CGPoint endCenter = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    
	[self activeToolbar].alpha = 1.0;
	[self activeToolbar].frame = CGRectMake(0, endCenter.y-yOffset, window.bounds.size.width, 44);
	
	[UIView commitAnimations];
    
    //BOOL isPhoneKeyboard = [];
    //[self showDoneButton:(activeToolbarType == NMKeyboardToolbarDone || (NMKeyboardToolbarNextPrev && ))];
    
}

- (void)hideToolbar:(NSNotification *)notification
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
	NSDictionary *userInfo = [notification userInfo];
	
	[UIView beginAnimations:@"hide" context:NULL];
	
	NSValue *ac = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	UIViewAnimationCurve animCurve = 0;
	[ac getValue:&animCurve];
	[UIView setAnimationCurve:animCurve];
	
	NSValue *ad = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSTimeInterval animDur = 0;
	[ad getValue:&animDur];
	[UIView setAnimationDuration:animDur-0.05];
	
	[self activeToolbar].alpha = 0.0;
	[self activeToolbar].frame = CGRectMake(0, window.bounds.size.height-44, window.bounds.size.width, 44);
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[UIView commitAnimations];
}

- (void) increaseScrollViewHeight:(NSNumber *) newHeight
{
    NSAssert(firstResponderView,@"firstResponderViewView cannot be nil.");
    UIScrollView *scrollView = [firstResponderView parentWithClass:[UIScrollView class]];
    NSAssert(scrollView,@"no parent scrollview was found.");
    CGRect newRect = scrollView.frame;
    newRect.size.height += [newHeight intValue];
    scrollView.frame = newRect;
}

- (NSInteger) keyboardHeightFromNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *keyBounds = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
    return [keyBounds CGRectValue].size.height;
}

- (void)keybWillHide:(NSNotification *)notification
{
    if(resizeScrollView)
    {   
        [self increaseScrollViewHeight:[NSNumber numberWithInt:keyboardHeight]];   
    }
    
    if ([self activeToolbar]) 
    {
        [self performSelector:@selector(hideToolbar:) withObject:notification afterDelay:0.001];
	}    
}

- (void)keybDidHide:(NSNotification *)notification
{
    if(resizeScrollView)
    {
        CGRect rect = CGRectMake(0, 0, 1, 1);
        [[self.firstResponderView parentWithClass:[UIScrollView class]] scrollRectToVisible:rect animated:YES];
        resizeScrollView = NO;
    }
    
	if ([self activeToolbar]) {
		[UIView beginAnimations:@"hide" context:NULL];
		[UIView setAnimationDuration:0.1];
		
		[self activeToolbar].alpha = 0.0;
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView commitAnimations];
	}
    
	self.firstResponderView = nil;
}

#pragma mark - Animation delegate

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if ([animationID isEqualToString:@"hide"] && [self activeToolbar])
    {
		[[self activeToolbar] removeFromSuperview];
    }
}

#pragma mark - Actions

- (void)done:(id)sender
{
	[self.firstResponderView performSelector:@selector(resignFirstResponder) withObject:nil afterDelay:0.05];
}

@end
