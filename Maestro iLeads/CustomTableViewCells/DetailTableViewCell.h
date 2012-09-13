//
//  DetailTableViewCell.h
//  Maestro Sales Leads
//
//  Created by Dan Frazee on 9/8/12.
//  Copyright (c) 2012 Maestro Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneNumber.h"
#import "PhoneTypes.h"

@interface DetailTableViewCell : UITableViewCell  {
    BOOL swipedToDelete;
    UITableView*typeTable;
    NSArray *cellPhoneTypes;
    UILabel *typeLabel;
}
@property (nonatomic) BOOL isNew;
@property (nonatomic,strong) NSString*cellType;
@property (nonatomic, strong) id delegate;
@property (nonatomic, strong) IBOutlet UILabel *titleLable;
@property (nonatomic, strong) IBOutlet UITextField *titleLableTextField;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) PhoneNumber*phoneNumberObject;

-(void)setUpAtPosition:(int)position;
-(void)setEditing:(BOOL)editing;
-(void)setUpForPhoneNumberTypeSelection;

-(void)typeSelected:(id)sender;

@end
