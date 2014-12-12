//
//  UpdateProfileInfoViewController.m
//  Capsl
//
//  Created by Jonathan Kim on 12/3/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "UpdateProfileInfoViewController.h"
#import "Capslr.h"
#import "SVProgressHUD.h"

@interface UpdateProfileInfoViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UILabel *wordCountLabel;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveBarButtonItem;

@end

@implementation UpdateProfileInfoViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

    [self.textField becomeFirstResponder];

    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = self.saveBarButtonItem;
    self.saveBarButtonItem.enabled = NO;

    if (self.nameString)
    {
        self.textField.text = self.nameString;
        self.navigationItem.title = @"Name";

        self.wordCountLabel.text = [NSString stringWithFormat:@"%lu/40", (unsigned long)self.nameString.length];
    }
    else if (self.usernameString)
    {
        self.textField.text = self.usernameString;
        self.navigationItem.title = @"Username";

        self.wordCountLabel.text = [NSString stringWithFormat:@"%lu/40", (unsigned long)self.usernameString.length];
    }
    else if (self.emailString)
    {
        self.textField.text = self.emailString;
        self.navigationItem.title = @"Email";

        self.wordCountLabel.text = [NSString stringWithFormat:@"%lu/40", (unsigned long)self.emailString.length];
    }

    self.view.backgroundColor = [UIColor colorWithPatternImage:kUpdateProfileBackground];

}

- (IBAction)onSaveBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [SVProgressHUD setBackgroundColor:[UIColor clearColor]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];

    [SVProgressHUD show];

    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {

        if (self.nameString)
        {
            currentCapslr.name = self.textField.text;

            [currentCapslr save];
            [SVProgressHUD dismiss];

            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (self.usernameString)
        {
            // check to see if the username exists already
            PFQuery *query = [PFUser query];
            [query whereKey:@"username" equalTo:self.textField.text];
            [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if ((!object))
                {
                    currentCapslr.username = self.textField.text;
                    [PFUser currentUser].username = self.textField.text;

                    [currentCapslr save];
                    [[PFUser currentUser] save];
                    [SVProgressHUD dismiss];

                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    [self usernameExistsAlert];
                    [SVProgressHUD dismiss];
                }
            }];
        }
        else if (self.emailString)
        {

            if ([self NSStringIsValidEmail:self.textField.text])
            {
                currentCapslr.email = self.textField.text;

                [currentCapslr save];
                [SVProgressHUD dismiss];

                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [self invalidEmailAlert];
                [SVProgressHUD dismiss];
            }
        }
    }];

    //TODO: ADD REFRESHING ANIMATION FOR SAVING
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger textLength = 0;
    textLength = [textField.text length] + [string length] - range.length;

    self.wordCountLabel.text = [NSString stringWithFormat:@"%ld/40", (long)textLength];

    if (textLength > 39)
    {
        return NO;
    }
    else if (textLength == 0)
    {
        self.saveBarButtonItem.enabled = NO;
    }
    else
    {
        //enable Save Button when textfield is used
        self.saveBarButtonItem.enabled = YES;
    }

    return YES;
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

#pragma mark - Alert if username already exists

- (void)usernameExistsAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"The username already exists" message:@"Please try a new username" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];

    [alert addAction:okButton];

    [alert.view setTintColor:kAlertControllerTintColor];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - check if email is valid

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - invalid email alert
- (void)invalidEmailAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Invalid email" message:@"Please try a new email" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];

    [alert addAction:okButton];

    [alert.view setTintColor:kAlertControllerTintColor];

    [self presentViewController:alert animated:YES completion:nil];
}


@end
