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
#import "UpdateProfileInfoViewController.h"
#import "UpdateProfileInfoViewController.h"
#import "RootViewController.h"

#define kNameLabel @"Name"
#define kUsernameLabel @"Username"
#define kEmailLabel @"Email"


@interface EditProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property NSArray *infoArray;

@end

@implementation EditProfileViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {

        self.currenCapslrInfo = @[currentCapslr.name, currentCapslr.username, currentCapslr.email];
    }];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.infoArray = @[kNameLabel, kUsernameLabel, kEmailLabel];

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
        cell.textLabel.text = @"LOGOUT";
    }

#warning fix this later...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // FOR SECTION ONE
    if (indexPath.section == 0)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *chooseFromLibrary = [UIAlertAction actionWithTitle:@"Choose from Library"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *action) {
            // CHOOSE FROM PHOTO LIBRARY
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

            [self presentViewController:picker animated:YES completion:NULL];

            [alert dismissViewControllerAnimated:YES completion:nil];
        }];

        UIAlertAction *takePhoto = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // CAMERA
            if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
            {
                UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                      message:@"Device has no camera"
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles: nil];
                [myAlertView show];

            }

            else
            {
                UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                picker.allowsEditing = YES;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                
                
                [self presentViewController:picker animated:YES completion:NULL];
            }
            
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];

        UIAlertAction *delete = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            // add code here
        }];

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];

        [alert addAction:chooseFromLibrary];
        [alert addAction:takePhoto];
        [alert addAction:delete];
        [alert addAction:cancel];

        [self presentViewController:alert animated:YES completion:nil];
    }

    // FOR SECTION TWO
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            [self performSegueWithIdentifier:@"editNameSegue" sender:self.currenCapslrInfo[0]];
        }
        else if (indexPath.row == 1)
        {
            [self performSegueWithIdentifier:@"editUsernameSegue" sender:self.currenCapslrInfo[1]];
        }
        else if (indexPath.row == 2)
        {
            [self performSegueWithIdentifier:@"editEmailSegue" sender:self.currenCapslrInfo[2]];
        }
    }
    else if (indexPath.section == 2)
    {
        RootViewController *rootVC = [[RootViewController alloc] init];

        [PFUser logOut];
        [self.navigationController popToViewController:rootVC animated:YES];
    }
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

//TODO: implement this later

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    //Accessing uncropped image from info dictionary
//    self.chosenImage = info[UIImagePickerControllerOriginalImage];
//    self.imageView.image = self.chosenImage;
//
//    [picker dismissViewControllerAnimated:YES completion:NULL];
//    
//    //Settign CPSL image to be sent
//    NSData *imageData = UIImageJPEGRepresentation(self.chosenImage, 1.0f);
//    self.createdCapsl.photo = [PFFile fileWithName:@"image.jpg" data:imageData];
//    
//    [self setTextViewToBottom];
//    [self setAddAudioToBottom];
//    
//}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    UpdateProfileInfoViewController *updateProfileInfoVC = segue.destinationViewController;

    if ([segue.identifier isEqual:@"editNameSegue"])
    {
        updateProfileInfoVC.nameString = self.currenCapslrInfo[0];
    }
    else if ([segue.identifier isEqual:@"editUsernameSegue"])
    {
        updateProfileInfoVC.usernameString = self.currenCapslrInfo[1];
    }
    else if ([segue.identifier isEqual:@"editEmailSegue"])
    {
        updateProfileInfoVC.emailString = self.currenCapslrInfo[2];
    }

}




@end
