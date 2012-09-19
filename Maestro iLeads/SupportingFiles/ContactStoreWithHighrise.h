//
//  ContactStoreWithHighrise.h
//  Maestro iLeads
//
//  Created by Dan Frazee on 9/19/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;
@class Email;
@class PhoneNumber;
@class PhoneTypes;

@interface ContactStoreWithHighrise : NSObject <NSXMLParserDelegate> {
    NSMutableArray *allContacts;
    NSMutableArray* sortedContacts;
    NSString *tempString;
    NSMutableArray *tempArray;
    NSRange tableRange;
    NSArray *currentViewableContacts;
    
    Person *person;
    Email *email;
    PhoneNumber *number;
    PhoneTypes *phoneType;
    
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
}

+(ContactStoreWithHighrise*)sharedStore;

-(NSString*)contactArchivePath;
-(void)loadAllContacts;
-(NSArray *)allContacts;

-(BOOL)saveChanges;

-(void)sortAllContacts;
-(NSArray*)sortedContacts;

@end
