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
#import "AppDelegate.h"

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
        
        AppDelegate*appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSDate* date = [NSDate date];
        dateOfFullIntegration = date;
        [appDelegate setDateOfFullIntegration:date];
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

-(void)loadUpdatedContacts
{
    NSLog(@"Begin Connection");
    HighRiseAFHTTPClient *client = [[HighRiseAFHTTPClient alloc] init];
    
    //TODO: write date to string in yyyymmddhhmmss format and in UTC and insert it as an object in dictionary for @"since" key
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:@"20120921000000" forKey:@"since"];
    NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:@"people.xml" parameters:dict];
        
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
// This is how to compare 2 integers ...  NSNumber*nsn = p.idNumber;
//                                                                    [nsn isEqualToNumber:[NSNumber numberWithInteger:[[idNumbers objectAtIndex:j] integerValue]]]

-(void)sortAllContacts
{
    [idNumbers removeAllObjects];
    sortedContacts = [[NSMutableArray alloc] init];
    NSArray *sectionHeaderArray = [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
    int curIndex = 0;
    for (int i=0; i<sectionHeaderArray.count; i++) {
        NSMutableArray *sectionArray = [[NSMutableArray alloc]init];        
        NSString *headerForComparison =[sectionHeaderArray objectAtIndex:i];
        if (curIndex>=allContacts.count-1) {
            [sortedContacts addObject:sectionArray];
            curIndex++;
            continue;
        }
        for (int j=curIndex; j<allContacts.count; j++) {
            NSString *firstNameString = (NSString *)[[allContacts objectAtIndex: j ] firstName];
            NSString *firstLetter = [NSString stringWithString:[firstNameString substringWithRange:(NSRange){0,1}]];
            if ([headerForComparison isEqualToString:[firstLetter uppercaseString]]) {
                Person*p = [allContacts objectAtIndex:j];
                [idNumbers addObject:p.idNumber];
                [sectionArray addObject:[allContacts objectAtIndex: j ]];
                NSLog(@"idNumbers.count = %i, j = %i",idNumbers.count, j );
                if (j==allContacts.count-1) {
                    curIndex=j;
                    [sortedContacts addObject:sectionArray];
                }
            } else {
                [sortedContacts addObject:sectionArray];
                curIndex=j;
                break;
            }
        }
    }
}

-(void)postCompletionNotification
{
    [self sortAllContacts];
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Updating Found" message:@"Click Ok to continue with update" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    //[alert show];

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
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"YYYY-MM-ddHH:mm:ss"];

    if ([elementName isEqualToString:@"people"]) {
        NSSortDescriptor*alphabetizer = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
        [allContacts sortUsingDescriptors:[NSArray arrayWithObject:alphabetizer]];
    }
    
    if ([elementName isEqualToString:@"person"]) {
        [allContacts addObject:person];
        //NSLog(@"%@, Peoplecount = %i, idNumberCount = %i", [person descriptionForTableViewTitle],allContacts.count,idNumbers.count);
        person = nil;
    }

    if ([elementName isEqualToString:@"id"]) {
        if (IsIdForPerson) {

        NSNumber *idNumber =[NSNumber numberWithInteger:[tempString integerValue]];
        if (!idNumbers) {
            idNumbers = [[NSMutableArray alloc]init];
        }
            
        if([idNumbers containsObject:idNumber]){
            //NSLog(@"~*similar id found*~ idNumber = %i, idNumbers.count = %i, allContacts.count = %i",[idNumber integerValue],idNumbers.count,allContacts.count);
            [allContacts removeObjectAtIndex:[idNumbers indexOfObject:idNumber]];
            [idNumbers removeObject:idNumber];
        }        
        [idNumbers addObject:idNumber];
        IsIdForPerson =NO;
        person.idNumber = idNumber;
        }
        
    }

    if ([elementName isEqualToString:@"created-at"]) {
        NSString*dstring = [tempString stringByReplacingOccurrencesOfString:@"T" withString:@""];
        dstring = [dstring stringByReplacingOccurrencesOfString:@"Z" withString:@""];
        NSDate *date =[df dateFromString:dstring];;
        person.createdAt =[date dateByAddingTimeInterval:-4 * 60 * 60];
    }
    
    if ([elementName isEqualToString:@"updated-at"]) {
        NSString*dstring = [tempString stringByReplacingOccurrencesOfString:@"T" withString:@""];
        dstring = [dstring stringByReplacingOccurrencesOfString:@"Z" withString:@""];
        NSDate *date =[df dateFromString:dstring];;
        person.updatedAt =[date dateByAddingTimeInterval:-4 * 60 * 60];
    }
    
    if ([elementName isEqualToString:@"first-name"]) {
        NSString *firstLetter = [NSString stringWithString:[tempString substringWithRange:(NSRange){0,1}]];
        if ([firstLetter isEqualToString:@"\""]) {
            tempString = [tempString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        }
        BOOL isUppercase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[firstLetter characterAtIndex:0]];
        if(!isUppercase){
            NSString *restOfString = [NSString stringWithString:[tempString substringWithRange:(NSRange){1,tempString.length-1}]];
            tempString = [NSString stringWithFormat:@"%@%@",firstLetter.uppercaseString,restOfString];
        }
        
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
    
    //TODO: - check id against all coredata person.idNumbers
    
    if ([elementName isEqualToString:@"person"]){
        person = [NSEntityDescription insertNewObjectForEntityForName:@"Person" inManagedObjectContext:context];
        IsIdForPerson = YES;
    }else {
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
