//
//  UpdateProfileInfoViewController.m
//  Capsl
//
//  Created by Jonathan Kim on 12/3/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "UpdateProfileInfoViewController.h"
#import "Capslr.h"

@interface UpdateProfileInfoViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
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
        self.descriptionLabel.text = @"Enter your username.";
        self.textField.text = self.usernameString;
        self.navigationItem.title = @"Username";

        self.wordCountLabel.text = [NSString stringWithFormat:@"%lu/40", (unsigned long)self.usernameString.length];
    }
    else if (self.emailString)
    {
        self.descriptionLabel.text = @"Enter your Email.";
        self.textField.text = self.emailString;
        self.navigationItem.title = @"Email";

        self.wordCountLabel.text = [NSString stringWithFormat:@"%lu/40", (unsigned long)self.emailString.length];
    }
}

- (IBAction)onSaveBarButtonItemPressed:(UIBarButtonItem *)sender
{
    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error) {

        if (self.nameString && self.nameString)
        {
            currentCapslr.name = self.textField.text;
            [currentCapslr save];
            [self.navigationController popToViewController:self.navigationController.childViewControllers[1] animated:YES];
        }
        else if (self.usernameString)
        {
            currentCapslr.username = self.textField.text;
            [currentCapslr save];
            [self.navigationController popToViewController:self.navigationController.childViewControllers[1] animated:YES];
        }
        else if (self.emailString)
        {
            currentCapslr.email = self.textField.text;
            [currentCapslr save];
            [self.navigationController popToViewController:self.navigationController.childViewControllers[1] animated:YES];
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



@end
