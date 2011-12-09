//
//  NMSetupViewController.m
//  Breckenridge
//
//  Created by Ryan Connelly on 12/2/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import "NMSetupViewController.h"
#import "NMGestureViewController.h"

@implementation NMSetupViewController
@synthesize gestureViewController;
@synthesize gestureParentView;
@synthesize saveButton;

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
    
    
    UIImage *greenButtonImage = [UIImage imageNamed:@"greenButton.png"];
    UIImage *stretchableGreenButton = [greenButtonImage stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [self.saveButton setBackgroundImage:stretchableGreenButton forState:UIControlStateNormal];
    
    UIImage *darkGreenButtonImage = [UIImage imageNamed:@"greenButtonActivated.png"];
    UIImage *stretchabledarkGreenButton = [darkGreenButtonImage stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [self.saveButton setBackgroundImage:stretchabledarkGreenButton forState:UIControlStateHighlighted];
    self.saveButton.titleLabel.textColor = [UIColor whiteColor];
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
