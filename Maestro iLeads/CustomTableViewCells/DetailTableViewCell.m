//
//  DetailTableViewCell.m
//  Maestro Sales Leads
//
//  Created by Dan Frazee on 9/8/12.
//  Copyright (c) 2012 Maestro Mobile. All rights reserved.
//

#import "DetailTableViewCell.h"
#import "ContactStore.h"
#import "DetailsViewController.h"
#import "PhoneTypes.h"

@implementation DetailTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *cellArray = [[NSBundle mainBundle] loadNibNamed:@"DetailTableViewCell" owner:self options:nil];
        self = [cellArray objectAtIndex:0];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
   // [super setSelected:selected animated:animated];
    //Fade the BG in...
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    
    if (swipedToDelete) {
        return;
    } else {
    
    UITextField *tf = self.titleLableTextField;
    UILabel *tl = self.titleLable;
    UILabel *ttl;
    CGSize typeSize;
    CGFloat tlWidth = 200;
    CGFloat tlXPos = 20;
        
    if (self.phoneNumberObject.type) {
        typeLabel.text = self.phoneNumberObject.type.name;
        tlWidth = 155.0;
        typeSize = [typeLabel.text sizeWithFont:typeLabel.font];
        ttl = typeLabel;
        tlXPos = 20.0 + typeSize.width + 2.0;
    }
        
    if (editing) {
        [UIView animateWithDuration:.5 animations:^{
            [ttl setFrame:CGRectMake(self.bounds.origin.x + 40, 9, typeSize.width, 21)];
            [tl setFrame:CGRectMake(tlXPos+20.0, 9, tlWidth, 21)];
            [tf setFrame:CGRectMake(40, 5, 260, 31)];
        }];
        
    } else {        
        [UIView animateWithDuration:.5 animations:^{
            [ttl setFrame:CGRectMake(self.bounds.origin.x + 20, 9, typeSize.width, 21)];
            [tl setFrame:CGRectMake(tlXPos, 9, 200, 21)];
            [tf setFrame:CGRectMake(20, 5, 280, 31)];
        }];        
    }
    }
}

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    if (state == UITableViewCellStateShowingDeleteConfirmationMask) {
        swipedToDelete = YES;
        //NSLog(@"UITableViewCellStateShowingDeleteConfirmationMask");
    } else if(state == UITableViewCellStateShowingEditControlMask) {
        swipedToDelete = NO;
    } else if(state == UITableViewCellStateDefaultMask){
        swipedToDelete = NO;
    } 
}

-(void)setUpAtPosition:(int)position
{
    self.titleLableTextField.delegate = self.delegate;
    self.titleLableTextField.tag = 3+position;
    self.editButton.tag = self.titleLableTextField.tag +100;
    self.titleLable.tag = self.titleLableTextField.tag +50;
    
    if (self.phoneNumberObject.type) {
        [self setUpTypeLabelForType:self.phoneNumberObject.type.name];
    }
    
    [self.editButton addTarget:self.delegate action:@selector(editTextField:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.isNew) {
        if ([self.cellType isEqualToString:@"number"]) {
            [self setUpForPhoneNumberTypeSelection];
        } else if ([self.cellType isEqualToString:@"notes"]){
            [self setUpForNotesSection];
        } else
            [self.titleLableTextField becomeFirstResponder];

    } else {
        [self.titleLableTextField setHidden:YES];
        [self.editButton setTitle:@"Edit" forState:UIControlStateNormal];
    }
}

-(void)setEditing:(BOOL)editing
{
    if (editing) {
        [self.editButton setHidden:NO];
        [self.editButton setAlpha:0.0];
        [UIView animateWithDuration:.5 animations:^{
            [self.editButton setAlpha:1.0];
        }];
    } else{
        [UIView animateWithDuration:.5 animations:^{
            [self.editButton setAlpha:0.0];
        } completion:^(BOOL finished){
            if (finished) {
                [self.editButton setHidden:YES];
            }
        }];
    }
}

-(void)setUpForPhoneNumberTypeSelection
{
    cellPhoneTypes = [NSArray arrayWithObjects: @"Cell",@"Home",@"Work", nil];
    UISegmentedControl *typeSelector = [[UISegmentedControl alloc] initWithItems:cellPhoneTypes];
    CGRect frame = CGRectMake(self.bounds.origin.x+20,
                              self.bounds.origin.y+3,
                              self.bounds.size.width-34,
                              35);
    
    typeSelector.frame = frame;
    [typeSelector addTarget:self action:@selector(typeSelected:) forControlEvents:UIControlEventValueChanged];
    typeSelector.segmentedControlStyle = UISegmentedControlStyleBar;
    typeSelector.momentary = YES;

    [UIView animateWithDuration:5 animations:^(){
       typeSelector.alpha = 1;
    }];
    
    [self addSubview:typeSelector];
}

-(void)setUpForNotesSection
{
    [self.titleLableTextField removeFromSuperview];
    
    UITextView*textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 5, 280, 100)];
    [self addSubview:textView];
    [textView becomeFirstResponder];
    textView.keyboardAppearance = UIKeyboardAppearanceAlert;
}


-(void)typeSelected:(UISegmentedControl*)sender
{
    [UIView animateWithDuration:.5 animations:^(){
        sender.alpha = 0;
    }];
    NSString *type = [NSString stringWithFormat:@"%@:",[cellPhoneTypes objectAtIndex:sender.selectedSegmentIndex]];
    
    [self.delegate setTypeForNumber:type];
    [self setUpTypeLabelForType:self.phoneNumberObject.type.name];
    
    typeLabel.text = type;
    
    [self.titleLableTextField becomeFirstResponder];
}

-(void)setUpTypeLabelForType:(NSString*)type
{
    typeLabel = [[UILabel alloc] init];
    
    typeLabel.backgroundColor = [UIColor clearColor];
    
    typeLabel.font = [UIFont boldSystemFontOfSize:17.0];
    CGSize typeSize = [type sizeWithFont:typeLabel.font];
        
    [self.titleLable setFrame:CGRectMake(self.bounds.origin.x + typeSize.width + 22,
                                         self.titleLable.frame.origin.y,
                                         self.titleLable.frame.size.width - typeSize.width - 5,
                                         self.titleLable.frame.size.height)];
    
    [typeLabel setFrame:CGRectMake(self.bounds.origin.x + 20,
                                   self.titleLable.frame.origin.y,
                                   typeSize.width,
                                   self.titleLable.frame.size.height)];
    
    [self insertSubview:typeLabel belowSubview:self.titleLableTextField];
    
    typeLabel.text = type;
}

@end
