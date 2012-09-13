//
//  ContactStore.m
//  Maestro Sales Leads
//
//  Created by Dan Frazee on 9/6/12.
//  Copyright (c) 2012 Maestro Mobile. All rights reserved.
//

#import "ContactStore.h"
#import "Person.h"
#import "PhoneNumber.h"
#import "PhoneTypes.h"


@implementation ContactStore

+(ContactStore *)sharedStore
{
    static ContactStore *sharedStore = nil;
    
    if (!sharedStore)
        sharedStore =[[super allocWithZone:nil]init];
    
    return sharedStore;
}

+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

-(id)init
{
    self = [super init];
    
    if (self) {
        if(!allContacts)
            allContacts = [[NSMutableArray alloc] init];
        
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
        
        NSString *path = [self contactsArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            [NSException raise:@"Open Failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        [context setUndoManager:nil];
        [self loadAllContacts];
    }
    
    return self;
}

-(void)removeContact:(Person *)p
{
    [context deleteObject:p];
    [allContacts removeObjectIdenticalTo:p];
}

-(NSString*)contactsArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

-(NSArray *)allContacts
{
    return  allContacts;
}

-(NSArray *)sortedContacts
{
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:YES];
    return [allContacts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sd]];
}

-(BOOL)saveChanges
{
    NSError *err = nil;
    BOOL success = [context save:&err];
    
    if(success)
        NSLog(@"Error saving: %@", [err localizedDescription]);
    
    return success;
}

-(void)loadAllContacts
{
    if(!allContacts)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"Person"];
        [request setEntity:e];
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
        [request setSortDescriptors:[NSArray arrayWithObject:sd]];
        
        NSError *error = nil;
        NSArray *result = [context executeFetchRequest:request error:&error];
        
        if (!result) {
            [NSException raise:@"Fetch failed" format:@"Reason: %@", [error localizedDescription]];
        }
        
        allContacts =[[NSMutableArray alloc] initWithArray:result];
    }
}


-(Person *)createContact
{
    
    Person *p = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
        
    [allContacts addObject:p];
    
    return p;
}

//This will need to turn into addNumber:number forPerson:person andType:type
-(PhoneNumber*)addPhoneNumber:(NSString *)number ForPerson:(Person *)person
{
    NSMutableSet *numbers = [NSMutableSet setWithSet:person.phoneNumbers];
    PhoneNumber *numberObject;
    if([number isEqualToString:@""]){
        numberObject = [NSEntityDescription insertNewObjectForEntityForName:@"PhoneNumber" inManagedObjectContext:context];
        temporaryObject = numberObject;
    } else
    {
        numberObject = temporaryObject;
    }
    
    [numberObject setNumber:number];
    [numberObject setPerson:person];
    //[numberObject setType:type];
    
    [numbers addObject:numberObject];
    
    [person setPhoneNumbers:[NSSet setWithSet:numbers]];
    
    return numberObject;
}

-(void)addEmailAddress:(NSString*)email ForPerson:(Person *)person
{
    [person setEmail:email];
}

-(void)removePhoneNumber:(PhoneNumber *)number forPerson:(Person *)person
{
    [context deleteObject:number];
    NSMutableSet *numbers = [NSMutableSet setWithSet:person.phoneNumbers];
    [numbers removeObject:number];
    
    [person setPhoneNumbers:[NSSet setWithSet:numbers]];
}

-(void)addInfo:(NSString *)info ForObjectLabel:(NSString *)objectname ForPerson:(Person *)Person
{
    //write out method 
}

-(void)setType:(NSString*)type ForNumber:(PhoneNumber *)number
{
    //Not currently using the number that is being passed in but is using the temporaryObject
    PhoneTypes* newType = [NSEntityDescription insertNewObjectForEntityForName:@"PhoneTypes" inManagedObjectContext:context];
    newType.name = type;
    [(PhoneNumber *)temporaryObject setType:newType];
}

@end
