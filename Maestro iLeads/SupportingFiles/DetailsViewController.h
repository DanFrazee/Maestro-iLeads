//
//  DetailsViewController.h
//  Maestro Sales Leads
//
//  Created by Dan Frazee on 9/6/12.
//  Copyright (c) 2012 Maestro Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
#import "PhoneTypes.h"

@class Person;

@interface DetailsViewController : UIViewController <UITableViewDelegate,UITableViewDataSource, UITextFieldDelegate , UIImagePickerControllerDelegate> {
    NSMutableArray *tableViewHeaderViews;
    __weak IBOutlet UITableView *detailsTableView;
    
    __weak IBOutlet UILabel *contactName;
    __weak IBOutlet UITextField *contactNameField;
    
    UIButton *currentTextFieldEditButton;
    UITextField *currentTextField;
    
    NSIndexPath *currentCellPosition;
    PhoneNumber *tempPhoneNumber;
}

@property (nonatomic,strong) UIImage* image;
@property (nonatomic, strong) NSArray *numberArray;
@property (nonatomic, strong) Person *contact;
@property (nonatomic) BOOL isNewContact;
@property (nonatomic, weak) NSString *currentPhoneNumber;

-(id)initForNewContact:(BOOL)isNew;

-(UIView *)buildHeaderViewForSection:(NSInteger)section;

-(void)createNewTableRow:(id)sender;
-(IBAction)editTextField:(UIButton*)sender;
-(void)scrollToTextField:(UITextField*)textField withTimeDelay:(id)sender;

-(BOOL)setNewContactName:(NSString*)fullName;
-(BOOL)validateInputForTextField:(UITextField*)textField;

-(IBAction)beginImageInsertion:(id)sender;

-(void)addPhoneNumberToNumberArray:(PhoneNumber*)number;
-(void)setTypeForNumber:(NSString*)type;

-(void)removePhoneNumberFromNumberArray:(PhoneNumber*)number;
-(NSString*)getInfoForTextField:(UITextField*)textField;

@end
