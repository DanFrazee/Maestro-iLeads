//
//  DetailsViewController.m
//  Maestro Sales Leads
//
//  Created by Dan Frazee on 9/6/12.
//  Copyright (c) 2012 Maestro Mobile. All rights reserved.
//

#import "DetailsViewController.h"
#import "ContactStore.h"
#import "PhoneNumber.h"
#import "PhoneTypes.h"
#import "Person.h"
#import "DetailTableViewCell.h"
#import "DocumentHelper.h"

@interface DetailsViewController ()

@end

@implementation DetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.isNewContact) {
        [contactNameField setHidden:YES];
        contactName.text = [NSString stringWithFormat:@"%@ %@",self.contact.firstName,self.contact.lastName];
        contactNameField.text = [NSString stringWithFormat:@"%@ %@",self.contact.firstName,self.contact.lastName];
        UIButton *editButton = (UIButton *)[self.view viewWithTag:102];
        [editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [detailsTableView reloadData];
    } else {
        if (!self.contact.firstName && !self.contact.lastName) {
            [contactNameField becomeFirstResponder];
            contactNameField.keyboardAppearance = UIKeyboardAppearanceAlert;
        }
    }
}

-(id)initForNewContact:(BOOL)isNew
{
    self = [super initWithNibName:@"DetailsViewController" bundle:nil];
    
    self.isNewContact = isNew;
    
    if(self){
        if (isNew) {
            UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
            [[self navigationItem] setRightBarButtonItem:done];
            
            UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
            [[self navigationItem] setLeftBarButtonItem:cancelItem];
        } else {
            [[self navigationItem] setRightBarButtonItem:[self editButtonItem]];
            [(UIButton*)[self.view viewWithTag:120] setTitle:@"Edit" forState:UIControlStateNormal];
        }
    }
    return  self;
}

-(IBAction)createNewTableRow:(id)sender
{
    ContactStore *contacts = [ContactStore sharedStore];
    if ([(UIButton*)sender tag]==1) {
        [(UIButton*)sender setHidden:YES];
        self.contact.company = @"";
        currentCellPosition = [NSIndexPath indexPathForRow:0 inSection:0];
    } else if ([(UIButton*)sender tag]==2) {
        [(UIButton*)sender setHidden:YES];

        tempPhoneNumber = [contacts addPhoneNumber:@"" ForPerson:self.contact];
        [self addPhoneNumberToNumberArray:tempPhoneNumber];
        currentCellPosition = [NSIndexPath indexPathForRow:0 inSection:1];
        
    }else if([(UIButton*)sender tag]==3){
        [contacts addEmailAddress:@"" ForPerson:self.contact];
        currentCellPosition = [NSIndexPath indexPathForRow:0 inSection:2];
    }
    NSLog(@"%i,%i",currentCellPosition.row,currentCellPosition.section);

    NSIndexPath *ip = [NSIndexPath indexPathForRow:currentCellPosition.row inSection:currentCellPosition.section];
    [detailsTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:ip]
                            withRowAnimation:UITableViewRowAnimationFade];
}

-(BOOL)validateInputForTextField:(UITextField*)textField
{
    if ([textField.text isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Action" message:@"You must insert something here." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    int t = textField.tag;
    ContactStore *contacts = [ContactStore sharedStore];
    NSString* type = [(DetailTableViewCell*)textField.superview cellType];
    
    if ([type isEqualToString:@"number"]) {
        if (![self.numberArray containsObject:[NSString stringWithString:textField.text]])
            [contacts addPhoneNumber:textField.text ForPerson:self.contact];
    } else if ([type isEqualToString:@"email"]) {
        [contacts addEmailAddress:textField.text ForPerson:self.contact];
    } else if ([type isEqualToString:@"organization"]) {
        self.contact.company = textField.text;
    }
    UILabel *label = (UILabel*)[self.view viewWithTag:t+50];
    label.text = textField.text;
    
    return YES;
}

-(UIView *)buildHeaderViewForSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 28)];
    UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(20, 3, 165, 21)];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeContactAdd];

    [button setFrame:CGRectMake(285, 0, 29, 29)];
    button.tag = section+1;
    [button addTarget:self action:@selector(createNewTableRow:) forControlEvents:UIControlEventTouchUpInside];
    [labelView setBackgroundColor:[UIColor clearColor]];
    [labelView setFont:[UIFont boldSystemFontOfSize:17]];
    
    [headerView addSubview:button];
    [headerView addSubview:labelView];

    if(section==0){
        labelView.text = @"Organization";
        if (!self.contact.company) {
            [button setHidden:NO];
        } else{
            [button setHidden:YES];
        }
    } else if(section==1){
        labelView.text = @"Phone Numbers";
    } else if(section==2){
        labelView.text = @"Email Address";
        if (!self.contact.email) {
            [button setHidden:NO];
        } else{
            [button setHidden:YES];
        }
    } else if(section==3){
        labelView.text = @"Image";
        [button setHidden:YES];
    }
    
    if (!tableViewHeaderViews) {
        tableViewHeaderViews = [[NSMutableArray alloc] init];
    }
    
    if (![tableViewHeaderViews containsObject:headerView] ) {
        [tableViewHeaderViews addObject:headerView];
    }
    
    return headerView;
}

- (void)viewDidUnload {
    detailsTableView = nil;
    contactNameField = nil;
    contactName = nil;
    [super viewDidUnload];
}


//Eventually this should work generically for all textfields -- This can be the delegate for custom UITableViewCells with UITextFields
-(IBAction)editTextField:(UIButton*)sender
{
    UITextField*textField = (UITextField*)[sender.superview viewWithTag:sender.tag-100];
    UILabel*labelField = (UILabel*)[sender.superview viewWithTag:sender.tag-50];
    BOOL isATableCell = [sender.superview isKindOfClass:[DetailTableViewCell class]];
    NSString *info;
    
    if ([sender.titleLabel.text isEqualToString:@"Done"]) {
        if (isATableCell) {
            if (![self validateInputForTextField:textField]) {
                return;
            }
        } else {
            if (![self setNewContactName:contactNameField.text]) {
                return;
            }
        }
        info = textField.text;
        [textField setHidden:YES];
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        [textField resignFirstResponder];
        
        if (!self.isNewContact && !detailsTableView.isEditing) {
            [sender setHidden:YES];
        }
    }else if ([sender.titleLabel.text isEqualToString:@"Edit"]) {
        if(isATableCell){
            info =[self getInfoForTextField:textField];
        } else {
            info = [NSString stringWithFormat:@"%@ %@",self.contact.firstName,self.contact.lastName];
        }
        textField.keyboardAppearance = UIKeyboardAppearanceAlert;
        [textField setHidden:NO];
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        [textField becomeFirstResponder];
        textField.keyboardAppearance = UIKeyboardAppearanceAlert;
    }
    
    textField.text = info;
    labelField.text = info;
}

-(void)setTypeForNumber:(NSString*)type
{
    ContactStore *contacts = [ContactStore sharedStore];
    [contacts setType:type ForNumber:tempPhoneNumber];
}

-(BOOL)setNewContactName:(NSString *)fullName
{
    NSArray*stringArray = [fullName componentsSeparatedByString:@" "];
    
    if (stringArray.count < 2) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Action" message:@"You Must have at least 2 names to identify person" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return NO;
    } else {
        self.contact.firstName = [stringArray objectAtIndex:0];
        self.contact.lastName = [stringArray objectAtIndex:1];
        contactName.text = [NSString stringWithFormat:@"%@ %@",self.contact.firstName,self.contact.lastName];
        //[sender setTitle:@"Edit" forState:UIControlStateNormal];
    }
    return YES;
}

-(void)save
{
    if (![[self.view viewWithTag:2] isHidden]) {
        if (![self setNewContactName:contactNameField.text]) {
            return;
        }
    }
    
    self.isNewContact = NO;
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

-(void)cancel
{
    [[NSFileManager defaultManager] removeItemAtPath:self.contact.picture error:nil];
    [[ContactStore sharedStore] removeContact:self.contact];
    [[self navigationController] popToRootViewControllerAnimated:YES];
}

#pragma mark  - UITextField Controls

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    int t = textField.tag;
    //ContactStore *contacts = [ContactStore sharedStore];
    
    UIButton *editButton = (UIButton*)[self.view viewWithTag:t+100];
    
    if (textField==contactNameField) {
        if (![self setNewContactName:textField.text]) {
            return NO;
        }
    } else {
        if (![self validateInputForTextField:textField]) {
            return NO;
        }
    }
    
    [textField setHidden:YES];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [editButton setHidden:NO];
    
    if (textField.isFirstResponder) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField.superview isKindOfClass:[DetailTableViewCell class]]) {
        NSString *cellType = [(DetailTableViewCell*)textField.superview cellType];
        if (cellType==@"number") {
            [textField setKeyboardType:UIKeyboardTypePhonePad];
        } else if (cellType==@"email"){
            [textField setKeyboardType:UIKeyboardTypeEmailAddress];
        }
    }
    int t = textField.tag;
    UIButton *editButton = (UIButton*)[self.view viewWithTag:t+100];
    [editButton setHidden:NO];
        
    [NSTimer scheduledTimerWithTimeInterval:.25 target:self selector:@selector(scrollToTextFieldWithTimeDelay:) userInfo:textField repeats:NO];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.superview isKindOfClass:[DetailTableViewCell class]]) {
        NSString *cellType = [(DetailTableViewCell*)textField.superview cellType];
        if (cellType==@"organization"){
            UIButton*btn = (UIButton*)[[tableViewHeaderViews objectAtIndex:0] viewWithTag:1];
            [btn setHidden:YES];
        } else if (cellType==@"number"){
            UIButton*btn = (UIButton*)[[tableViewHeaderViews objectAtIndex:1] viewWithTag:2];
            [btn setHidden:NO];
        } else if (cellType==@"email"){
            [detailsTableView setContentOffset:CGPointMake(0, 0) animated:YES];
            UIButton*btn = (UIButton*)[[tableViewHeaderViews objectAtIndex:2] viewWithTag:3];
            [btn setHidden:YES];
        }
    }
}

-(void)scrollToTextFieldWithTimeDelay:(NSTimer*)sender
{
    UITextField *textField = (UITextField*)sender.userInfo;
    
    if (textField==contactNameField)
        return;
    
    int t = textField.tag;
    int hasOrg=0;
    
    if (self.contact.company) {
        hasOrg=1;
    }
    
    CGPoint point = [textField.superview convertPoint:textField.frame.origin toView:detailsTableView];
    CGPoint contentOffset = detailsTableView.contentOffset;
    
    if (point.y>80)
        contentOffset.y =  (textField.tag-3)*45 - 28;
            else
        contentOffset.y = 0;
    
    if (t >[self.numberArray count]+hasOrg+2) {
        contentOffset.y +=42;
    }
    
    [detailsTableView setContentOffset:contentOffset animated:YES];
}


#pragma mark - TableView Controls

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //This is all being called here because this happends before viewWillAppear
    if (!self.numberArray && self.contact.phoneNumbers)
        self.numberArray =  [self.contact.phoneNumbers allObjects];
    
    if (!self.image && self.contact.picture)
        self.image = [UIImage imageWithContentsOfFile:self.contact.picture];
    
    if (self.image)
        return 4;
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DefaultCell";
    static NSString *CellIdentifier2 = @"ImageCell";
    
    if (indexPath.section == 3) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (!cell)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
        
        UIImage *img = [UIImage imageWithContentsOfFile:self.contact.picture];
        CGFloat height = (280/img.size.width)*img.size.height;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(cell.bounds.origin.x+11, cell.bounds.origin.y+2, 298, height)];
        [imageView setBackgroundColor:[UIColor clearColor]];
        imageView.layer.cornerRadius = 10;
        imageView.clipsToBounds = YES;
        [imageView.layer setBorderColor: [[UIColor grayColor] CGColor]];
        [imageView.layer setBorderWidth: 0.25];
        [imageView setImage:img];
        [cell addSubview:imageView];
        [cell setBackgroundColor:[UIColor clearColor]];
        [cell setUserInteractionEnabled:NO];
        return cell;
    }

    //This whole section could be cleaned up with proper initializers;
    DetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[DetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.delegate = self;
    
    NSString *info;
    int position;
    int hasOrg=0;
    
    if (indexPath.section==0) {
        if (self.contact.company)
            hasOrg = 1;
        position = 0;
        info =  self.contact.company;
        cell.cellType =@"organization";
    } else if(indexPath.section==1){
        PhoneNumber*number =  (PhoneNumber*)[self.numberArray objectAtIndex:indexPath.row];
        cell.phoneNumberObject = number;
        position = [self.numberArray count]+hasOrg-1;
        info =  number.number;
        cell.cellType =@"number";
    } else if(indexPath.section==2){
        position = [self.numberArray count]+hasOrg;
        info =self.contact.email;
        cell.cellType =@"email";
    }
    
    if (![info isEqualToString:@""]) {
        cell.isNew = NO;
        cell.titleLable.text = info;
    } else {
        cell.isNew = YES;
    }

    [cell setUpAtPosition:position];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    if (section==0) {
        if (self.contact.company)
            return 1;
    } else if(section==1){
        return [self.numberArray count];
    } else if(section==2){
        if (self.contact.email)
            return 1;
    } else if (section==3){
        if (self.image)
            return 1;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 28;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==3) {
        UIImage *img = [UIImage imageWithContentsOfFile:self.contact.picture];
        CGFloat height = (280/img.size.width)*img.size.height +4;
        return height;
    }
    
    return 40;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        ContactStore *ps = [ContactStore sharedStore];
        
        if (indexPath.section==0) {
            self.contact.company = nil;
            UIButton*btn = (UIButton*)[[tableViewHeaderViews objectAtIndex:0] viewWithTag:1];
            [btn setHidden:NO];
        } else if (indexPath.section==1) {
            PhoneNumber *number = [self.numberArray objectAtIndex:indexPath.row];
            [ps removePhoneNumber:number forPerson:self.contact];
            [self removePhoneNumberFromNumberArray:number];
        } else if (indexPath.section==2) {
            self.contact.email = nil;
            UIButton*btn = (UIButton*)[[tableViewHeaderViews objectAtIndex:2] viewWithTag:3];
            [btn setHidden:NO];
        }
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    NSArray *posArray = detailsTableView.indexPathsForVisibleRows;
    for (NSIndexPath*position in posArray)
    {
        DetailTableViewCell*cell = (DetailTableViewCell*)[detailsTableView cellForRowAtIndexPath:position];
        [cell setEditing:editing];
    }
    
    BOOL isNameCorrect = [self setNewContactName:contactNameField.text];

    if ([detailsTableView isEditing]) {
        if (isNameCorrect) {
            [[self.view viewWithTag:20] setHidden:YES];
            UIButton *editButton =(UIButton*)[self.view viewWithTag:120];
            [editButton setTitle:@"Edit" forState:UIControlStateNormal];
            [editButton setHidden:NO];
            [UIView animateWithDuration:.5 animations:^{
                [editButton setAlpha:0.0];
            } completion:^(BOOL finished){
                if (finished)
                    [editButton setHidden:YES];
            }];
        [detailsTableView setEditing:!isNameCorrect animated:YES];
        }
    } else {
        [detailsTableView setEditing:YES animated:YES];
        UIButton *editButton =(UIButton*)[self.view viewWithTag:120];
        [editButton setHidden:NO];
        [editButton setAlpha:0.0];
        [UIView animateWithDuration:.5 animations:^{ [editButton setAlpha:1.0]; }];
        isNameCorrect = NO;
    }
    [super setEditing:!isNameCorrect animated:animated];

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self buildHeaderViewForSection:section];
}

#pragma mark - ImagePickerController Controls
-(IBAction)beginImageInsertion:(id)sender
{
    UIImagePickerController *imagePicker =[[UIImagePickerController alloc] init];
    
    // Checking  and setting source types - ignoring photo albums    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    imagePicker.delegate = (id)self;

    imagePicker.mediaTypes = [NSArray arrayWithObjects:
                              (NSString *) kUTTypeImage,
                              (NSString *) kUTTypeMovie, nil];
    
    imagePicker.allowsEditing = YES;
    [self presentModalViewController:imagePicker 
                            animated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        NSString *filePath = [DocumentHelper setDocumentPathForImage:image];
        self.contact.picture = filePath;
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Invalid Action" message:@"Videos are not allowed for placement" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
    [detailsTableView reloadData];
    [self dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Helper Methods
                         
-(NSString*)getInfoForTextField:(UITextField*)textField
{
    NSString *info;
    NSString *cellType = [(DetailTableViewCell*)textField.superview cellType];
    
    if ([cellType isEqualToString:@"organization"])
        info = self.contact.company;
    else if ([cellType isEqualToString:@"number"])
        info = [(PhoneNumber*)[self.numberArray objectAtIndex:currentCellPosition.row] number];
    else if ([cellType isEqualToString:@"email"])
        info = self.contact.email;
    
    return info;
}

-(void)addPhoneNumberToNumberArray:(PhoneNumber*)number
{
    NSMutableArray *tempArray;
    if (!self.numberArray)
        tempArray = [[NSMutableArray alloc] init];
            else
        tempArray = [NSMutableArray arrayWithArray:self.numberArray];
    
    [tempArray insertObject:number atIndex:0];
    
    self.numberArray = [NSArray arrayWithArray:tempArray];
}

-(void)removePhoneNumberFromNumberArray:(PhoneNumber*)number
{
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.numberArray];

    [tempArray removeObjectIdenticalTo:number];
    
    self.numberArray = [NSArray arrayWithArray:tempArray];    
}

@end
