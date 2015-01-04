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
#import "EditProfilePicTableViewCell.h"
#import "RootViewController.h"
#import "CrossDissolveSegue.h"
#import "SVProgressHUD.h"

#define kNameLabel @"Name"
#define kUsernameLabel @"Username"
#define kEmailLabel @"Email"


@interface EditProfileViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *exitBarButtonItem;

@property NSArray *infoArray;
@property (nonatomic)  UIImage *chosenImage;

@end

@implementation EditProfileViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {

        self.currenCapslrInfo = @[currentCapslr.name, currentCapslr.username, currentCapslr.email];
        [self.tableView reloadData];
    }];

}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.infoArray = @[kNameLabel, kUsernameLabel, kEmailLabel];

    self.navigationItem.title = @"Profile";

    //TODO: fix top inset issue

    self.view.backgroundColor = [UIColor colorWithPatternImage:kEditProfileBackground];

}

-(void)setChosenImage:(UIImage *)chosenImage
{
    _chosenImage = chosenImage;
    [self.tableView reloadData];
}

-(void)setCurrentProfilePicture:(UIImage *)currentProfilePicture
{
    _currentProfilePicture = currentProfilePicture;
    [self.tableView reloadData];
}

- (void)setCurrenCapslrInfo:(NSArray *)currenCapslrInfo
{
    _currenCapslrInfo = currenCapslrInfo;
    [self.tableView reloadData];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (indexPath.section == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"profilePic" forIndexPath:indexPath];

        EditProfilePicTableViewCell *customCell = (EditProfilePicTableViewCell *)cell;
        customCell.profileImageView.image = self.currentProfilePicture;
//        customCell.editProfilePhotoLabel.text = @"Change Photo";
        cell = customCell;

    }
    else if (indexPath.section == 1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"dataCell" forIndexPath:indexPath];

        cell.textLabel.text = [self.infoArray[indexPath.row] uppercaseString];
        cell.detailTextLabel.text = self.currenCapslrInfo[indexPath.row];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    }else if (indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"buttonCell" forIndexPath:indexPath];
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

                [myAlertView setTintColor:kAlertControllerTintColor];
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

            [SVProgressHUD show];

            [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {

                NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"default"], 0.5f);
                PFFile *defaultPhoto = [PFFile fileWithData:imageData];
                currentCapslr.profilePhoto = defaultPhoto;

                self.currentProfilePicture = [UIImage imageNamed:@"default"];

                [currentCapslr save];
                [self.tableView reloadData];
                [SVProgressHUD dismiss];

                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
        }];

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:nil];

        [alert addAction:chooseFromLibrary];

        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            [alert addAction:takePhoto];
        }
        [alert addAction:delete];
        [alert addAction:cancel];

        [alert.view setTintColor:kAlertControllerTintColor];

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
        [self logOutAlert];
    }
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

//TODO: implement this later
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    //Accessing uncropped image from info dictionary

    [SVProgressHUD show];

    self.chosenImage = info[UIImagePickerControllerOriginalImage];

    NSData *imageData = UIImageJPEGRepresentation(self.chosenImage, 0.5f);
    PFFile *profilePhoto = [PFFile fileWithName:@"image.jpg" data:imageData];

    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {
        currentCapslr.profilePhoto = profilePhoto;
        self.currentProfilePicture = self.chosenImage;
        [currentCapslr save];
        [SVProgressHUD dismiss];
    }];

    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if (![segue.identifier isEqualToString:@"segueToRoot"])
    {
        UpdateProfileInfoViewController *updateProfileInfoVC = segue.destinationViewController;

        if ([segue.identifier isEqualToString:@"editNameSegue"])
        {
            if ([self.currenCapslrInfo[0] isEqualToString:@" "])
            {
                updateProfileInfoVC.nameString = @"";
            }
            else
            {
                updateProfileInfoVC.nameString = self.currenCapslrInfo[0];
            }
        }
        else if ([segue.identifier isEqualToString:@"editUsernameSegue"])
        {
            updateProfileInfoVC.usernameString = self.currenCapslrInfo[1];
        }
        else if ([segue.identifier isEqualToString:@"editEmailSegue"])
        {
            updateProfileInfoVC.emailString = self.currenCapslrInfo[2];
        }
    }

}

- (void)logOutAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Are you sure you want to logout?" message:nil preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *noButton = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [PFUser logOut];
        [self showRootViewController];
    }];

    [alert addAction:noButton];
    [alert addAction:yesButton];

    [alert.view setTintColor:kAlertControllerTintColor];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showRootViewController
{

//    [self performSegueWithIdentifier:@"segueToRoot" sender:self.updatedProfilePicture];

//    RootViewController *rootVC = [self.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([RootViewController class])];
//
//    [self presentViewController:rootVC animated:NO completion:nil];
//

    UINavigationController *rootNav = [self.storyboard instantiateInitialViewController];;

    [self.view.window setRootViewController:rootNav];

//    [self presentViewController:rootNav animated:NO completion:nil];

}

- (IBAction)onExitBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


//- (IBAction)onBackBarButtonItemPressed:(UIBarButtonItem *)sender
//{
//    [self performSegueWithIdentifier:@"toProfileVC" sender:self.updatedProfilePicture];
//}
//


@end
