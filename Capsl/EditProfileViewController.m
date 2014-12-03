//
//  EditProfileViewController.m
//  Capsl
//
//  Created by Jonathan Kim on 12/3/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "EditProfileViewController.h"
#import "EditProfilePicTableViewCell.h"
#import "Capslr.h"

#define kNameLabel @"Name"
#define kUsernameLabel @"Username"
#define kEmailLabel @"Email"


@interface EditProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *infoArray;

@end

@implementation EditProfileViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSLog(@"%@", self.currentProfilePicture);

    self.infoArray = @[kNameLabel, kUsernameLabel, kEmailLabel];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"My Profile";

}

-(void)setCurrenCapslrInfo:(NSArray *)currenCapslrInfo
{
    _currenCapslrInfo = currenCapslrInfo;
    [self.tableView reloadData];
}

#pragma mark - Tableview delegate methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1)
        return self.currenCapslrInfo.count;
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

        cell.imageView.image = self.currentProfilePicture;
        cell.textLabel.text = @"Edit Photo";

    }else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"dataCell" forIndexPath:indexPath];

        cell.textLabel.text = self.infoArray[indexPath.row];
        cell.detailTextLabel.text = self.currenCapslrInfo[indexPath.row];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    }else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 1)
//    {
//        <#statements#>
//    }
}

@end
