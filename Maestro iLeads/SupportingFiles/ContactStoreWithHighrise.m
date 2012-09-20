//
//  ContactStoreWithHighrise.m
//  Maestro iLeads
//
//  Created by Dan Frazee on 9/19/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//

#import "ContactStoreWithHighrise.h"
#import "Person.h"
#import "Email.h"
#import "PhoneNumber.h"
#import "PhoneTypes.h"
#import "AFNetworking.h"
#import "HighRiseAFHTTPClient.h"


@implementation ContactStoreWithHighrise

+(ContactStoreWithHighrise *)sharedStore
{
    static ContactStoreWithHighrise *sharedStore = nil;
    
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

-(void)loadAllContacts
{
    if(!allContacts)
    {
        allContacts = [[NSMutableArray alloc] init];
        
        NSLog(@"Begin Connection");
        HighRiseAFHTTPClient *client = [[HighRiseAFHTTPClient alloc] init];

        NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:@"people.xml" parameters:nil];
        
        AFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request
        success:^(AFHTTPRequestOperation *request, id responseObject) {
                            [(NSXMLParser*)responseObject setDelegate:self];
                            NSLog(@"%d",[responseObject parse]);
                            [self saveChanges];
                            [self postCompletionNotification];
                        }
        failure:^(AFHTTPRequestOperation *request, NSError *error) {
                            NSLog(@"Request Failed with Error: %@, %@", error, error.userInfo);
                        }];
     
        [client enqueueHTTPRequestOperation:operation];
    }
}

-(void)sortAllContacts
{    
    sortedContacts = [[NSMutableArray alloc] init];
    NSArray *sectionHeaderArray = [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    int curIndex = 0;

    for (int i=0; i<sectionHeaderArray.count; i++) {
        NSMutableArray *sectionArray = [[NSMutableArray alloc]init];        
        NSString *headerForComparison =[sectionHeaderArray objectAtIndex:i];
        for (int j=curIndex; j<allContacts.count; j++) {
            NSString *firstNameString = (NSString *)[[allContacts objectAtIndex: j ] firstName];
            NSString *firstLetter = [NSString stringWithString:[firstNameString substringWithRange:(NSRange){0,1}]];
            if ([headerForComparison isEqualToString:[firstLetter uppercaseString]]) {
                [sectionArray addObject:[allContacts objectAtIndex: j ]];
            } else {
                [sortedContacts addObject:sectionArray];
                curIndex=j+1;
                break;
            }
        }
    }
}

-(void)postCompletionNotification
{
    [self sortAllContacts];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ContactLoadComplete" object:nil];
}

-(NSArray*)sortedContacts
{
    return sortedContacts;
}

-(BOOL)saveChanges
{
    NSError *err = nil;
    BOOL success = [context save:&err];
    
    if(success)
        NSLog(@"Error saving: %@", [err localizedDescription]);
    
    return success;
}


#pragma mark NSXMLParser Controlls
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"people"]) {
        NSSortDescriptor*alphabetizer = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
        [allContacts sortUsingDescriptors:[NSArray arrayWithObject:alphabetizer]];
    }
    
    if ([elementName isEqualToString:@"person"]) {
        [allContacts addObject:person];
        person = nil;
    }

    if ([elementName isEqualToString:@"id"]) {
        person.idNumber = [NSNumber numberWithInteger:[tempString integerValue]];
        NSLog(@"%@",person.idNumber);
    }

    if ([elementName isEqualToString:@"created-at"]) {
//        NSDateFormatter *df = [[NSDateFormatter alloc] init];
//        [df setDateFormat:@"EEE MMM dd HH:mm:ss ZZ yyyy"];
//        person.createdAt =[df dateFromString:@"2012-06-12T14:57:35Z"];
//        NSLog(@"%@",person.createdAt);
        //person.createdAt = tempString;
    }
    
    if ([elementName isEqualToString:@"updated-at"]) {
        //person.updatedAt = tempString;
    }
    
    if ([elementName isEqualToString:@"first-name"]) {
        person.firstName = tempString;
    }
    
    if ([elementName isEqualToString:@"last-name"]) {
        person.lastName = tempString;
    }
    
    if ([elementName isEqualToString:@"company-name"]) {
        person.company = tempString;
    }
    
    if ([elementName isEqualToString:@"email-addresses"]) {
        person.emailAddresses = [NSSet setWithArray:tempArray];
        tempArray = nil;
    }
    
    if ([elementName isEqualToString:@"address"]) {
        email = [NSEntityDescription insertNewObjectForEntityForName:@"Email" inManagedObjectContext:context];
        [email setAddress:tempString];
        [tempArray addObject:email];
    }
    
    if ([elementName isEqualToString:@"phone-numbers"]) {
        person.phoneNumbers = [NSSet setWithArray:tempArray];
        tempArray = nil;
    }
    
    if ([elementName isEqualToString:@"number"]) {
        number = [NSEntityDescription insertNewObjectForEntityForName:@"PhoneNumber" inManagedObjectContext:context];
        
        //Still need to set the type to first part of string prior to "\n".... I think I would just create entity for name "PhoneTypes"
        NSString *string = [tempString stringByReplacingOccurrencesOfString:@"\n      " withString:@":"];
        [number setNumber:string];

        [tempArray addObject:number];
        number = nil;
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"person"])
        person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
    else {
        if ([elementName isEqualToString:@"email-addresses"] || [elementName isEqualToString:@"phone-numbers"]){
            tempArray = [[NSMutableArray alloc] init];
        }
        
        // Bypassing setting tempString to a blank string here because we want contents of the @"location" element which is directly before the @"number" element.
        if ([elementName isEqualToString:@"number"]) {
            return;
        }
        tempString = @"";
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    tempString = [tempString stringByAppendingString:string];
}

@end
