//
//  Person.m
//  Maestro iLeads
//
//  Created by Dan Frazee on 9/20/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//

#import "Person.h"
#import "Email.h"
#import "PhoneNumber.h"


@implementation Person

@dynamic company;
@dynamic createdAt;
@dynamic firstName;
@dynamic lastName;
@dynamic notes;
@dynamic picture;
@dynamic updatedAt;
@dynamic idNumber;
@dynamic emailAddresses;
@dynamic phoneNumbers;

-(NSString *)descriptionForTableViewTitle
{
    return [NSString stringWithFormat:@"%@, %@",self.firstName,self.lastName,nil];
}

-(NSString *)descriptionForTableViewSubTitle
{
    return [NSString stringWithFormat:@"at %@",self.company,nil];
}

@end
