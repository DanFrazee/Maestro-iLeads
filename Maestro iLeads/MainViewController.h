//
//  MainViewController.h
//  Maestro Sales Leads
//
//  Created by Dan Frazee on 9/6/12.
//  Copyright (c) 2012 Maestro Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UITableViewController{
    NSArray*sortedContacts;
}

-(void)addNewPerson:(id)sender;

@end
