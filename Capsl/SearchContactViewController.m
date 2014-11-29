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

@interface SearchContactViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (nonatomic, strong) NSArray *capslrArray;
@property (nonatomic, strong) NSArray *contactsArray;


@end

@implementation SearchContactViewController

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
    return self.capslrArray.count;
}

@end
