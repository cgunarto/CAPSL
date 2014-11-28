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
#import "JKCountDownTimer.h"

@interface CapsuleListViewController () <UITableViewDataSource, UITableViewDelegate, JKCountdownTimerDelegate>

@property (nonatomic)  NSArray *capslsArray;

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property Capsl *capsl;
@property (nonatomic)  NSString *timerString;

@end

@implementation CapsuleListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"%@", [PFUser currentUser]);

    // Dummy Data
//    self.capsl = [Capsl object];
//    self.capsl.reciever = @"jonno";
//    PFQuery *query = [Capsl query];
//    [query whereKey:@"reciever" equalTo:self.capsl.reciever];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error)
//        {
//            self.capslsArray = objects;
//        }
//    }];

    self.capsl = [Capsl object];

    self.capslr.user = [PFUser currentUser];
    NSString *objectID = self.capslr.user.objectId;

    PFQuery *query = [Capsl query];
    [query whereKey:@"recipient" equalTo:objectID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            self.capslsArray = objects;
        }
    }];

}

// Automatically reloads the tableview whenever capslsArray is updated..
-(void)setCapslsArray:(NSArray *)capslsArray
{
    _capslsArray = capslsArray;
    [self.tableView reloadData];
}

#pragma mark - Tableview Delegate Methods

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

    cell.deliveryDateLabel.text = [NSString stringWithFormat:@"D-Day: %@", [dateFormatter stringFromDate:deliveryDate]];
    cell.fromLabel.text = [NSString stringWithFormat:@"From: %@", capsl.from];

    JKCountDownTimer *timer = [[JKCountDownTimer alloc] initWithDeliveryDate:deliveryDate withDelegate:self];
    [timer updateLabel];

    cell.timerLabel.text = self.timerString;

    return cell;
}

#pragma mark - JKTimer Delegate Method

-(void)counterUpdated:(NSString *)dateString
{
    if (dateString == nil)
    {
        [self presentCanOpenMeAlert];
    }
    else
    {
        self.timerString = dateString;
    }
}

#pragma mark - Alert when timer expires
-(void)presentCanOpenMeAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"You can now open your capsl!" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Open capsl" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // UNLOCK CAPSL!!
    }];

    [alert addAction:okButton];
    [self presentViewController:alert animated:YES completion:nil];
}


@end
