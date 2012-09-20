//
//  Person.h
//  Maestro iLeads
//
//  Created by Dan Frazee on 9/20/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Email, PhoneNumber;

@interface Person : NSManagedObject

@property (nonatomic, retain) NSString * company;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * idNumber;
@property (nonatomic, retain) NSSet *emailAddresses;
@property (nonatomic, retain) NSSet *phoneNumbers;
@end

@interface Person (CoreDataGeneratedAccessors)

- (void)addEmailAddressesObject:(Email *)value;
- (void)removeEmailAddressesObject:(Email *)value;
- (void)addEmailAddresses:(NSSet *)values;
- (void)removeEmailAddresses:(NSSet *)values;

- (void)addPhoneNumbersObject:(PhoneNumber *)value;
- (void)removePhoneNumbersObject:(PhoneNumber *)value;
- (void)addPhoneNumbers:(NSSet *)values;
- (void)removePhoneNumbers:(NSSet *)values;

-(NSString *)descriptionForTableViewTitle;
-(NSString *)descriptionForTableViewSubTitle;

@end
