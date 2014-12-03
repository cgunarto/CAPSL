//
//  EditProfileViewController.m
//  Capsl
//
//  Created by Jonathan Kim on 12/3/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "EditProfileViewController.h"
#import "EditProfilePicTableViewCell.h"

@interface EditProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *theData;

@end

@implementation EditProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"My Profile";

    self.theData = @[@"One",@"Two",@"Three",@"Four",@"Five"];
    [self.tableView reloadData];
}


#pragma mark - Tableview delegate methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1)
        return self.theData.count;
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 200;
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;

    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"profilePic" forIndexPath:indexPath];
        cell.imageView.image = [UIImage imageNamed:@"profilepic1"];
        cell.textLabel.text = @"Edit Photo";

    }else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"dataCell" forIndexPath:indexPath];
        cell.textLabel.text = self.theData[indexPath.row];

    }else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];
    }
    
    return cell;
}

@end
