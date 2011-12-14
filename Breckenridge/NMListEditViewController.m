//
//  NMSetupViewController.m
//  Breckenridge
//
//  Created by Ryan Connelly on 12/9/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "NMListEditViewController.h"
#import "NMItemModel.h"
#import "NMAppDelegate.h"
#i
#import "CoreDataManager.h"

@implementation NMListEditViewController

@synthesize noneLabel;
@synthesize addButton;
@synthesize listTableView;
@synthesize itemNameTextfield;
@synthesize itemAbbreviationTextField;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/
- (NSMutableArray *) items
{
    return [(NMAppDelegate *)[[UIApplication sharedApplication] delegate] items];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.listTableView.layer.cornerRadius = 8.0f;
    self.listTableView.layer.borderWidth = 1.0f;
    self.listTableView.layer.borderColor = [[UIColor grayColor] CGColor];
    [NMKeyboardManager sharedManager].activeToolbarType = NMKeyboardToolbarCancel;
    
}

- (void)viewDidUnload
{
    [self setAddButton:nil];
    [self setListTableView:nil];
    [self setItemNameTextfield:nil];
    [self setItemAbbreviationTextField:nil];
    [self setNoneLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
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
    if(textField == self.itemNameTextfield)
    {
        [self.itemAbbreviationTextField becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
        if(self.itemNameTextfield.text.length > 0)
            [self addItem:textField];
    }
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDataSource

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [textFieldFirstResponder resignFirstResponder];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SetupViewTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.backgroundColor = [UIColor clearColor];
    }
    NMItemModel *item = [[self items] objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    cell.detailTextLabel.text = item.abbreviation;
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self items].count;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.items removeObjectAtIndex:indexPath.row];
        rowCount--;
        
        noneLabel.hidden = rowCount != 0;
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }  
    else if(editingStyle == UITableViewCellEditingStyleInsert)
    {
                
    }
}

- (IBAction)addItem:(id)sender {
    NMItemModel *item = [[NMItemModel alloc] init];
    
    item.name = self.itemNameTextfield.text;
    item.abbreviation = self.itemAbbreviationTextField.text;
    [self.items addObject:item];
    NSArray *indexes = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.items.count-1 inSection:0]];
        rowCount++;
    [self.listTableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationLeft];
  //  [self.listTableView reloadData];
    self.itemNameTextfield.text = nil;
    self.itemAbbreviationTextField.text = nil;
    [self.itemNameTextfield resignFirstResponder];
    [self.itemAbbreviationTextField resignFirstResponder];
    [self setEditing:NO];
    noneLabel.hidden = YES;
    
    NSManagedObjectContext *context = [[CoreDataManager sharedInstance] newManagedObjectContext];
    Item *itemModel = [NSEntityDescription insertNewObjectForEntityForName:@"Item"
                                                               inManagedObjectContext:context]; 
    
    [context insertObject:itemModel];
    [context save];
}
@end
