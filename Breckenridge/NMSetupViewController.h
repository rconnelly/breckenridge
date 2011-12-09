//
//  NMSetupViewController.h
//  Breckenridge
//
//  Created by Ryan Connelly on 12/9/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NMSetupViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    id textFieldFirstResponder;
    NSInteger rowCount;
}
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITableView *listTableView;
@property (strong, nonatomic) NSMutableArray *items;

@property (weak, nonatomic) IBOutlet UITextField *itemNameTextfield;
@property (weak, nonatomic) IBOutlet UITextField *itemAbbreviationTextField;

- (IBAction)addItem:(id)sender;

@end
