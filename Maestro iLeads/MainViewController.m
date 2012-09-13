//
//  MainViewController
//  Maestro Sales Leads
//
//  Created by Dan Frazee on 9/6/12.
//  Copyright (c) 2012 Maestro Mobile. All rights reserved.
//

#import "MainViewController.h"
#import "ContactStore.h"
#import "Person.h"
#import "DetailsViewController.h"

@implementation MainViewController

-(id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    if (self) {
        UINavigationItem *n = [self navigationItem];
        n.title = @"Sales Contacts";
        
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:nil
                                                                              action:nil];
        self.navigationItem.backBarButtonItem = backButton;
        
        UIBarButtonItem *rbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewPerson:)];
        
        [[self navigationItem] setRightBarButtonItem:rbi];
        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
    }
    
    return self;
}

-(void)viewDidLoad
{
    sortedContacts = [[ContactStore sharedStore] sortedContacts];
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation==UIInterfaceOrientationIsLandscape(interfaceOrientation));
}


-(void)addNewPerson:(id)sender
{
    Person *newPerson = [[ContactStore sharedStore] createContact];
    
    DetailsViewController*detailedViewController = [[DetailsViewController alloc] initForNewContact:YES];
    detailedViewController.contact = newPerson;
    [[self navigationController] pushViewController:detailedViewController animated:YES];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        ContactStore*cs = [ContactStore sharedStore];
        NSArray *contacts = [cs allContacts];
        [cs removeContact:[contacts objectAtIndex:indexPath.row]];
        
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[ContactStore sharedStore] allContacts] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Person *item = [[[ContactStore sharedStore] allContacts]objectAtIndex:indexPath.row];
    
    cell.textLabel.text =  [item description];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DetailsViewController *detailedViewController = [[DetailsViewController alloc] initForNewContact:NO];
    detailedViewController.contact = [[[ContactStore sharedStore] allContacts] objectAtIndex:indexPath.row];
    [[self navigationController] pushViewController:detailedViewController animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
