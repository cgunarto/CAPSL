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
#import "AllContactTableViewCell.h"

@interface SearchContactViewController () <UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate>
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
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
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
    AllContactTableViewCell *allContactCell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    Capslr *capslr = self.capslrArray[indexPath.row];
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



































@end
