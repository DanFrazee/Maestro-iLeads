//
//  Person.m
//  Maestro iLeads
//
//  Created by Dan Frazee on 9/13/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//

#import "Person.h"
#import "PhoneNumber.h"


@implementation Person

@dynamic email;
@dynamic firstName;
@dynamic lastName;
@dynamic notes;
@dynamic picture;
@dynamic phoneNumbers;

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@, %@",self.firstName,self.lastName,nil];
}

@end
