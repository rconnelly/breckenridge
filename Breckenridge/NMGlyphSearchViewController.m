//
//  NMSetupViewController.m
//  Breckenridge
//
//  Created by Ryan Connelly on 12/2/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import "NMGlyphSearchViewController.h"
#import "NMGestureViewController.h"

@implementation NMGlyphSearchViewController
@synthesize gestureViewController;
@synthesize gestureParentView;
@synthesize saveButton;
@synthesize foundItemLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    gestureViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GestureViewController"];
    [self.gestureParentView addSubview:self.gestureViewController.view];
    
    gestureViewController.view.frame = self.gestureParentView.bounds;
    NMGestureDrawView *gdv = (NMGestureDrawView *)gestureViewController.view;
    gdv.delegate = self;
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([textFieldFirstResponder isFirstResponder])
        [textFieldFirstResponder resignFirstResponder];
    textFieldFirstResponder = nil;
}

- (void) didEndDrawGesture:(NMGesture *)gesture
{
    
}

- (void) didBeginDrawGesture:(NMGesture *)gesture
{
    if([textFieldFirstResponder isFirstResponder])
        [textFieldFirstResponder resignFirstResponder];
    textFieldFirstResponder = nil;
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    textFieldFirstResponder = textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setGestureParentView:nil];
    [self setSaveButton:nil];
    [self setFoundItemLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
