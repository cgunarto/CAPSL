//
//  CapslrContactViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/28/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "CapslrContactViewController.h"

#import "Contact.h"
#import "Capslr.h"


@interface CapslrContactViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSArray *capslrArray;
@property (nonatomic, strong) NSArray *contactsArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation CapslrContactViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Getting contacts from the phone
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //Getting contacts from the phone
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



//Check if there is Capslr that has the same phone number
//Query for

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.capslrArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    Capslr *capslr = self.capslrArray[indexPath.item];
    cell.textLabel.text = capslr.username;
    cell.detailTextLabel.text = capslr.email;
    
    return cell;
}


@end
