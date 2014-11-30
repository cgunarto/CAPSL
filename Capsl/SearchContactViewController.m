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

@interface SearchContactViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *capslrArray;
@property (nonatomic, strong) NSArray *contactsArray;
@property (nonatomic, strong) NSArray *searchResults;


@end

@implementation SearchContactViewController


//TODO:add segmented control to toggle between search CAPSLR and CONTACT

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"username contains[c] %@", searchText];

    self.searchResults = [self.capslrArray filteredArrayUsingPredicate:resultPredicate];
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

    Capslr *capslr = nil;

    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        capslr = [self.searchResults objectAtIndex:indexPath.row];
    }
    else
    {
        capslr = [self.capslrArray objectAtIndex:indexPath.row];
    }

    allContactCell.nameLabel.text = capslr.name;
    allContactCell.usernameLabel.text = capslr.username;
    allContactCell.phoneLabel.text = capslr.phone;

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
        return [self.capslrArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToCompose"])
    {
        NSIndexPath *indexPath = nil;
        Capslr *capslr = nil;

        if (self.searchDisplayController.active)
        {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            capslr = [self.searchResults objectAtIndex:indexPath.row];
        }
        else
        {
            indexPath = [self.tableView indexPathForSelectedRow];
            capslr = [self.capslrArray objectAtIndex:indexPath.row];
        }

        self.createdCapsl.recipient = capslr;

        ComposeViewController *composeVC = segue.destinationViewController;
        composeVC.createdCapsl = self.createdCapsl;
    }
}




@end
