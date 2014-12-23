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
#import "DateTableViewController.h"
#import "BackgroundGenerator.h"

#define kTableViewHeight 94;

@interface SearchContactViewController () <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *dismissButton;

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
              self.tableViewDataArray = [self.capslrArray mutableCopy];
          }];
         
     }];

    if (!self.backgroundImage)
    {

        self.backgroundImage = [BackgroundGenerator generateDefaultBackground];

    }
    else if (self.createdCapsl.photo)
    {

        self.backgroundImage = [BackgroundGenerator blurImage:self.backgroundImage withRadius:kChosenImageBlurRadius];

    }

    self.view.backgroundColor = [UIColor colorWithPatternImage:self.backgroundImage];

}

- (void)viewDidAppear:(BOOL)animated
{
    //Tableview needs to be reloaded otherwise profile pic will not show up the first time view loads
    [self.tableView reloadData];
}

#pragma mark Setter for TBV Data

-(void)setTableViewDataArray:(NSMutableArray *)tableViewDataArray
{
    _tableViewDataArray = tableViewDataArray;
    [self.tableView reloadData];
//    [self.searchDisplayController.searchResultsTableView reloadData];
}


#pragma mark Lock Orientation

- (BOOL) shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

#pragma mark Filtering Search

//Filtering for search results
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    //If selecteSegment is 0 (Capslr contact), predicate for username
    if (self.segmentedControl.selectedSegmentIndex == 0)
    {
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"username contains[c] %@", searchText];
        self.searchResults = [[self.capslrArray filteredArrayUsingPredicate:resultPredicate] mutableCopy];
        NSLog(@"%lu",(unsigned long)self.searchResults.count);

    }

    //If selecteSegment is 1 (Address contact), predicate for username
    else
    {
        //TODO:add last name
        NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"allNameString contains[c] %@", searchText];
        self.searchResults = [[self.contactsArray filteredArrayUsingPredicate:resultPredicate] mutableCopy];
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView*)tableView
{
    UIImage *processedImage = [BackgroundGenerator blurImage:self.backgroundImage withRadius:kChosenImageBlurRadius];
    [tableView setBackgroundColor:[UIColor colorWithPatternImage:processedImage]];
    tableView.tag = 1;

}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.searchDisplayController.searchResultsTableView setBackgroundColor:[UIColor clearColor]];

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

        allContactCell.nameLabel.text = capslr.name;
        allContactCell.usernameLabel.text = capslr.username;
        allContactCell.phoneLabel.text = capslr.phone;

        [capslr.profilePhoto getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                  allContactCell.photoImageView.image = [UIImage imageWithData:data];
             }
             else
             {
                 NSLog(@"%@", error.localizedDescription);
             }
         }];
    }

    //If selectedSegement is 1, Address Book contact - extract Contact object
    else
    {
        Contact *contact = nil;

        if (tableView.tag == 1)
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
        allContactCell.photoImageView.image = [UIImage imageWithData:contact.photo];
    }

    //Make the profile rounded
    allContactCell.photoImageView.layer.cornerRadius = allContactCell.photoImageView.frame.size.width/2;
    allContactCell.photoImageView.clipsToBounds = YES;
    allContactCell.contentView.backgroundColor = [UIColor clearColor];


    return allContactCell;


}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1)
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
    Capslr *capslr = [Capslr object];

    if ([segue.identifier isEqualToString:@"segueToDatePicker"])
    {
        UINavigationController *navVC = segue.destinationViewController;
        DateTableViewController *dateTableViewVC = navVC.childViewControllers.firstObject;
        dateTableViewVC.backgroundImage = self.backgroundImage;

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
            dateTableViewVC.createdCapsl = self.createdCapsl;
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
                     dateTableViewVC.createdCapsl = self.createdCapsl;
                 }

                 //If NO, create that Cpslr object, save it, and then pass it
                 else
                 {
                     Capslr *newCapslr = [Capslr object];
                     newCapslr.phone = contact.number;

                     [newCapslr saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                     {
                         dateTableViewVC.createdCapsl = self.createdCapsl;
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
    }

    //If selected segment is 1, TBV data array is ContactsArray
    else
    {
        self.tableViewDataArray = [self.contactsArray mutableCopy];
    }
    [self.tableView reloadData];

}

#pragma mark - Actions

- (IBAction)onDismissButtonTapped:(UIBarButtonItem *)sender
{

    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
