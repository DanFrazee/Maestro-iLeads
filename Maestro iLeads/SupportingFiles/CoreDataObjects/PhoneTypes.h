//
//  PhoneTypes.h
//  Maestro iLeads
//
//  Created by Dan Frazee on 9/13/12.
//  Copyright (c) 2012 Maestro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PhoneNumber;

@interface PhoneTypes : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *number;
@end

@interface PhoneTypes (CoreDataGeneratedAccessors)

- (void)addNumberObject:(PhoneNumber *)value;
- (void)removeNumberObject:(PhoneNumber *)value;
- (void)addNumber:(NSSet *)values;
- (void)removeNumber:(NSSet *)values;

@end
