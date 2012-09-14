//
//  Person.m
//  Maestro iLeads
//
//  Created by Dan Frazee on 9/14/12.
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
@dynamic company;
@dynamic phoneNumbers;

-(NSString *)description
{
    if (self.company) {
        return [NSString stringWithFormat:@"%@,%@ - %@",self.firstName,self.lastName,self.company,nil];
    }
    return [NSString stringWithFormat:@"%@,%@",self.firstName,self.lastName,nil];
}

@end
