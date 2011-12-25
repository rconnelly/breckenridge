//
//  NMSetupViewController.m
//  Breckenridge
//
//  Created by Ryan Connelly on 12/2/11.
//  Copyright (c) 2011 Nomad Apps, LLC. All rights reserved.
//

#import "NMGlyphSearchViewController.h"
#import "NMGestureViewController.h"
#import "ThirdParty/MultistrokeGestureRecognizer-iOS/WTMGlyph/WTMGlyphDetector.h"
#import "NMItemModel.h"
#import "NMAppDelegate.h"

// Limit for the number of search phrases returned. A larger 
// number means increased processing time. Smaller number reduces accuracy.
#define MAX_SEARCH_PHRASES 20

// Limit for the number of glyph sets that are used to permute
// with search phrases. A larger number means increased processing time. 
// Smaller number reduces accuracy.
#define MAX_GLYPH_SET 10

#define MAX_PREDICATES 200

@interface NMGlyphSearchViewController ()
- (WTMGlyphDetector *) newGlyphDetector;
- (NSArray *) findListItems:(NSArray *)searchPhrases;
- (void)addItem:(NMItemModel *)item;
@end

@implementation NMGlyphSearchViewController
@synthesize gestureLabel;
@synthesize gestureButton;
@synthesize gestureViewController;
@synthesize gestureParentView;
@synthesize saveButton;
@synthesize foundItemLabel;
@synthesize glyphDetector;
@synthesize gdv;
@synthesize listTableView;
@synthesize searchPhrases;
@synthesize listItems;
@synthesize filteredListItems;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
    gdv = (NMGestureDrawView *)gestureViewController.view;
    gdv.delegate = self;
    
    //glyphDetector = [self newGlyphDetector];
    glyphDetector = [[NMGlyphDetector alloc] init];
    glyphDetector.delegate = self;
    
    searchPhrases = [NSMutableArray arrayWithCapacity:1];
    listItems = [NSMutableArray arrayWithCapacity:1];
    filteredListItems = [NSMutableArray arrayWithCapacity:1];
}

- (WTMGlyphDetector *) newGlyphDetector
{
    WTMGlyphDetector *detector = [[WTMGlyphDetector alloc] init];
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"glyphs" ofType:@"plist"];
    
    // Build the array from the plist  
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSMutableArray *fileNames = [data objectForKey:@"GlyphFiles"];
    NSData *jsonData;
    
    for (int i = 0; i < fileNames.count; i++) {
        NSString *name = [fileNames objectAtIndex:i];
        jsonData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"json"]];        
        if (jsonData) {
            [detector addGlyphFromJSON:jsonData name:name];
        }
    }
    
    return detector;
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([textFieldFirstResponder isFirstResponder])
        [textFieldFirstResponder resignFirstResponder];
    textFieldFirstResponder = nil;
}

- (void) didEndDrawGesture:(NMGesture *)gesture
{
    //detector.points = gesture.points;
    //[detector updateLastPointTime];
    if(gesture.points.count == 1)
    {
        /*if(searchPhrases.count > 0)
         {
         NSLog(@"Found %@", [searchPhrases objectAtIndex:0]);
         }
         */
        NSArray *itms = [self findListItems:self.searchPhrases];
        if([itms count] > 0)
        {
            [self addItem:[itms objectAtIndex:0]];
            [self.listTableView reloadData];
        }
        [searchPhrases removeAllObjects];
        
    }
    else
    {
        [self.glyphDetector detectGlyph];
    }
}

- (void) didAddPoint:(CGPoint) point
{
    [self.glyphDetector addPoint:point];
}

- (NSMutableArray *) getSearchPhrases:(NSArray *)existingSearchPhrases newGlyphNames:(NSArray *)glyphNames
{
    NSMutableArray *newSearchPhrases = [NSMutableArray arrayWithCapacity:1];
    
    if(existingSearchPhrases.count == 0)
    {
        int maxSearchPhrases = MIN(MAX_SEARCH_PHRASES, glyphNames.count);
        newSearchPhrases = [[glyphNames subarrayWithRange:NSMakeRange(0, maxSearchPhrases)] mutableCopy];
    }
    else
    {
        int maxGlyphSet = MIN(MAX_GLYPH_SET, glyphNames.count);
        [[glyphNames subarrayWithRange:NSMakeRange(0, maxGlyphSet)] enumerateObjectsUsingBlock:^(NSString *glyphName, NSUInteger idx, BOOL *stop) {
            [existingSearchPhrases enumerateObjectsUsingBlock:^(NSMutableString *searchPhrase, NSUInteger idx, BOOL *stop) {
                NSString *newPhrase = [NSString stringWithFormat:@"%@%@",searchPhrase,glyphName];
                [newSearchPhrases addObject:newPhrase];
            }];
        }];
    }
    return newSearchPhrases;
}

- (NSArray *) findListItems:(NSArray *)sphrases
{
    
    if(sphrases.count == 0)
        return nil;
    
    NSMutableArray *subpredicates = [[NSMutableArray alloc] init];
    
    int maxPredicates = MIN(MAX_PREDICATES, sphrases.count);
    for (NSString *phrase in [sphrases subarrayWithRange:NSMakeRange(0, maxPredicates)]) {
        NSPredicate *subpredicate = [NSPredicate predicateWithFormat:@"name BEGINSWITH[cd] %@",phrase];
        [subpredicates addObject:subpredicate];
    }
    NSCompoundPredicate *predicate = [[NSCompoundPredicate alloc] initWithType:NSOrPredicateType subpredicates:subpredicates];
    
    return [[self items] filteredArrayUsingPredicate:predicate];
}

- (void) glyphResults:(NSArray *)results
{
    //NSString *msg = [NSString stringWithFormat:@"Results: %@",[results description]];
    //UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Results" 
    //                                               message:msg delegate:self 
    //                                     cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
    //[view show];
    
    NSMutableArray *glyphNames = [NSMutableArray arrayWithCapacity:1];
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [glyphNames addObject:[obj objectForKey:@"name"]];
    }];
    
    self.searchPhrases = [self getSearchPhrases:self.searchPhrases newGlyphNames:glyphNames];
    [self.glyphDetector reset];
    
}

- (void)glyphDetected:(WTMGlyph *)glyph withScore:(float)score
{
    /* NSString *msg = [NSString stringWithFormat:@"Name: %@\nScore: %.2f",glyph.name, score];
     UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Found Glyph" 
     message:msg delegate:self 
     cancelButtonTitle:@"Ok" otherButtonTitles:nil]; 
     view.tag = 1;
     [view show];
     */
}

- (void)firstResults:(char *)results size:(int)size
{
    [gestureLabel setText:@""];
    for (int i=0; i<size; ++i) {
        if (i==0) [gestureLabel setText:[NSString stringWithFormat:@"%c  ", results[i]]];
        else [gestureLabel setText:[NSString stringWithFormat:@"%@ (%c)", gestureLabel.text, results[i]]];
    }
    [self.glyphDetector reset];
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
    [self setListTableView:nil];
    [self setGestureButton:nil];
    [self setGestureLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) viewWillAppear:(BOOL)animated
{
    self.searchPhrases = nil;
    [self.glyphDetector reset];
}

#pragma mark - UITableViewDataSource

- (NSMutableArray *) items
{
    return [(NMAppDelegate *)[[UIApplication sharedApplication] delegate] items];
}

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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.textColor = [UIColor whiteColor];
        //cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.backgroundColor = [UIColor clearColor];
    }
    NMItemModel *item = [[self listItems] objectAtIndex:indexPath.row];
    cell.textLabel.text = item.name;
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self listItems].count;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
     // Delete the row from the data source
     [self.listItems removeObjectAtIndex:indexPath.row];
     [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
     }  
     else if(editingStyle == UITableViewCellEditingStyleInsert)
     {
     
     }
}


- (void)addItem:(NMItemModel *)item {
    [[self listItems] addObject:item];
}

- (IBAction)gestureButtonTouched:(id)sender {
    self.gestureButton.hidden = YES;
    self.gestureLabel.hidden = NO;
    self.gestureParentView.userInteractionEnabled = YES;
    self.gdv.hidden = NO;
}

- (void) didHide:(NMGestureDrawView *) drawView
{
    self.gestureButton.hidden = NO;
    self.gestureLabel.hidden = YES;
//    self.gestureParentView.hidden = NO;
    self.gestureParentView.userInteractionEnabled = NO;
    self.searchPhrases = nil;
    [self.glyphDetector reset];
}
@end
