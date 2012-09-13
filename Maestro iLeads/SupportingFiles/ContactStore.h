//
//  ContactStore.h
//  Maestro Sales Leads
//
//  Created by Dan Frazee on 9/6/12.
//  Copyright (c) 2012 Maestro Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Person;
@class PhoneNumber;
@class PhoneTypes;

@interface ContactStore : NSObject {
    NSMutableArray *allContacts;
    NSManagedObjectContext *context;
    NSManagedObjectModel *model;
    id temporaryObject;
}

+(ContactStore *)sharedStore;

-(NSString*)contactArchivePath;
-(void)loadAllContacts;
-(NSArray *)allContacts;
-(NSArray *)sortedContacts;

-(Person *)createContact;
-(void)removeContact:(Person *)p;
-(BOOL)saveChanges;

-(PhoneNumber*)addPhoneNumber:(NSString *)number ForPerson:(Person *)person;
-(void)setType:(NSString*)type ForNumber:(PhoneNumber*)number;

-(void)addEmailAddress:(NSString*)email ForPerson:(Person *)person;

-(void)removePhoneNumber:(PhoneNumber *)number forPerson:(Person *)person;

-(void)addInfo:(NSString*)info ForObjectLabel:(NSString*)objectname ForPerson:(Person*)Person;

@end
