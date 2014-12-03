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

@interface EditProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *theData;
@property (nonatomic)  NSArray *editableInfoForCurrentCapslr;

@end

@implementation EditProfileViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    self.editableInfoForCurrentCapslr = @[[self.currenCapslrInfo valueForKey:@"name"], [self.currenCapslrInfo valueForKey:@"username"], [self.currenCapslrInfo valueForKey:@"email"]];
//    self.editableInfoForCurrentCapslr = self.currenCapslrInfo;

}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"My Profile";

}

//-(void)setEditableInfoForCurrentCapslr:(NSArray *)editableInfoForCurrentCapslr
//{
//    _editableInfoForCurrentCapslr = editableInfoForCurrentCapslr;
//    [self.tableView reloadData];
//}

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

        cell.imageView.image = [UIImage imageNamed:@"profilepic1"];
        cell.textLabel.text = @"Edit Photo";

        cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width/2;
        cell.imageView.clipsToBounds = YES;

    }else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"dataCell" forIndexPath:indexPath];
        cell.textLabel.text = self.currenCapslrInfo[indexPath.row];

    }else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];
    }
    
    return cell;
}

@end
