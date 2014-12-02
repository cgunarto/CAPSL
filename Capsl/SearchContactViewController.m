//
//  SearchContactViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/29/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "SearchContactViewController.h"
#import "Contact.h"
#import "Capslr.h"
#import "Capsl.h"
#import "AllContactTableViewCell.h"
#import "ComposeViewController.h"

#define kTableViewHeight 94;

@interface SearchContactViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *capslrArray;
@property (nonatomic, strong) NSArray *contactsArray;
@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, strong) NSMutableArray *tableViewDataArray;

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation SearchContactViewController


//TODO:check for phone number corner cases

- (void)viewDidLoad
{
    [super viewDidLoad];

    //set default selected contact as Capslr contact
    [self.segmentedControl setSelectedSegmentIndex:0];

    [Contact retrieveAllContactsWithBlock:^(NSArray *contacts)
     {
         self.contactsArray = [contacts mutableCopy];

         [Capslr returnCapslrWithContactsArray:self.contactsArray withCompletion:^(NSArray *capslrObjectsArray, NSError *error)
          {
              self.capslrArray = capslrObjectsArray;
              [self.tableView reloadData];
          }];
         
     }];
}

//Filtering for search results
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    //If selecteSegment is 0 (Capslr contact), predicate for username
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"username contains[c] %@", searchText];
        self.searchResults = [[self.capslrArray filteredArrayUsingPredicate:resultPredicate] mutableCopy];
    }

    //If selecteSegment is 1 (Address contact), predicate for username
    {
        //TODO:add last name
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"firstName contains[c] %@", searchText];
        self.searchResults = [[self.contactsArray filteredArrayUsingPredicate:resultPredicate] mutableCopy];
    }
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}



#pragma mark Table View Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AllContactTableViewCell *allContactCell = (AllContactTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    //If selectedSegement is 0, CPSLR contact - extract Capslr object
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        Capslr *capslr = nil;

        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            capslr = [self.searchResults objectAtIndex:indexPath.row];
        }
        else
        {
            capslr = [self.capslrArray objectAtIndex:indexPath.row];
        }

        //TODO: Set profile photo
        allContactCell.nameLabel.text = capslr.name;
        allContactCell.usernameLabel.text = capslr.username;
        allContactCell.phoneLabel.text = capslr.phone;
    }

    //If selectedSegement is 1, Address Book contact - extract Contact object
    else
    {
        Contact *contact = nil;

        if (tableView == self.searchDisplayController.searchResultsTableView)
        {
            contact = [self.searchResults objectAtIndex:indexPath.row];
        }
        else
        {
            contact = [self.contactsArray objectAtIndex:indexPath.row];
        }
        allContactCell.nameLabel.text = [contact fullName];
        allContactCell.usernameLabel.text = contact.nickName;
        allContactCell.phoneLabel.text = contact.number;
    }

    return allContactCell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return [self.searchResults count];
    }
    else
    {
        if (self.segmentedControl.selectedSegmentIndex == 0)
        {
            return [self.capslrArray count];
        }
        else
        {
            return [self.contactsArray count];
        }
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kTableViewHeight;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Capslr *capslr = nil;

    if ([segue.identifier isEqualToString:@"segueToCompose"])
    {
        NSIndexPath *indexPath = nil;

        if (self.segmentedControl.selectedSegmentIndex == 0)
        {
            if (self.searchDisplayController.active)
            {
                indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                capslr = [self.searchResults objectAtIndex:indexPath.row];
            }
            else
            {
                indexPath = [self.tableView indexPathForSelectedRow];
                capslr = [self.tableViewDataArray objectAtIndex:indexPath.row];
            }

            self.createdCapsl.recipient = capslr;
            ComposeViewController *composeVC = segue.destinationViewController;
            composeVC.createdCapsl = self.createdCapsl;
        }

        else
        {
            Contact *contact = nil;

            if (self.searchDisplayController.active)
            {
                indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
                contact = [self.searchResults objectAtIndex:indexPath.row];
            }

            else
            {
                indexPath = [self.tableView indexPathForSelectedRow];
                contact = [self.tableViewDataArray objectAtIndex:indexPath.row];
            }

            //see if there is already a Cpslr with that contact number
            [Capslr returnCapslrFromPhone:contact.number withCompletion:^(Capslr *capslr, NSError *error)
             {
                 //If YES, retrieve and use that Cpslr object, then pass it
                 if (capslr)
                 {
                     self.createdCapsl.recipient = capslr;
                     ComposeViewController *composeVC = segue.destinationViewController;
                     composeVC.createdCapsl = self.createdCapsl;
                 }

                 //If NO, create that Cpslr object, save it, and then pass it
                 else
                 {
                     Capslr *newCapslr = [Capslr object];
                     newCapslr.phone = contact.number;

                     [newCapslr saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                     {
                         ComposeViewController *composeVC = segue.destinationViewController;
                         composeVC.createdCapsl = self.createdCapsl;
                     }];
                 }
             }];
        }
    }
}


- (IBAction)onContactTypeChosen:(UISegmentedControl *)sender
{
    //If selected segment is 0, TBV data array is CpslrArray
    if (sender.selectedSegmentIndex == 0)
    {
        self.tableViewDataArray = [self.capslrArray mutableCopy];
        NSLog(@"CPSLR contact chosen");
    }

    //If selected segment is 1, TBV data array is ContactsArray
    else
    {
        self.tableViewDataArray = [self.contactsArray mutableCopy];
        NSLog(@"Address book contact chosen");
    }
    [self.tableView reloadData];


}


@end
