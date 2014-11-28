//
//  CapsuleListViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "CapsuleListViewController.h"
#import "CapslTableViewCell.h"
#import "Capsl.h"
#import "Capslr.h"

@interface CapsuleListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic)  NSArray *capslsArray;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property Capslr *capslr;
@property Capsl *capsl;

@end

@implementation CapsuleListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Dummy Data
    self.capslr = [Capslr object];

    self.capsl = [Capsl object];

    self.capslr.objectId = @"SszsqhyTMB";


    PFQuery *query = [Capsl query];

    [query whereKey:@"recipient" equalTo:self.capslr.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            self.capslsArray = objects;
        }
    }];
}


//JKTimer Delegate Method
-(void)counterUpdated:(NSString *)dateString
{

}


-(void)setCapslsArray:(NSArray *)capslsArray
{
    _capslsArray = capslsArray;
    [self.tableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.capslsArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CapslTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];

    Capsl *capsl = self.capslsArray[indexPath.row];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSDate *deliveryDate = capsl.deliveryTime;

    cell.deliveryDateLabel.text = [dateFormatter stringFromDate:deliveryDate];
    
    return cell;
}

@end
