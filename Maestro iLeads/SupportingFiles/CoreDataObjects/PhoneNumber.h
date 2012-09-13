//
//  PhoneNumber.h
//  Maestro iLeads
//
//  Created by Dan Frazee on 9/13/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person, PhoneTypes;

@interface PhoneNumber : NSManagedObject

@property (nonatomic, retain) NSString * number;
@property (nonatomic, retain) Person *person;
@property (nonatomic, retain) PhoneTypes *type;

@end
