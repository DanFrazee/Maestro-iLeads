//
//  MainViewController.h
//  Maestro Sales Leads
//
//  Created by Dan Frazee on 9/6/12.
//  Copyright (c) 2012 Maestro Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UITableViewController <UISearchDisplayDelegate, UISearchBarDelegate>{
    NSArray*contacts;
    NSArray*sectionedArray;
}

@property (nonatomic,retain) UIActivityIndicatorView *activityIndicatorView;

-(void)addNewPerson:(id)sender;
-(void)initialContactLoad;
@end
