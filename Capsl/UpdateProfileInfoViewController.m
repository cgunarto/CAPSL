//
//  UpdateProfileInfoViewController.m
//  Capsl
//
//  Created by Jonathan Kim on 12/3/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "UpdateProfileInfoViewController.h"

@interface UpdateProfileInfoViewController ()

@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UILabel *wordCountLabel;

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

    if (self.nameString)
    {
        self.textField.text = self.nameString;
    }
    else if (self.usernameString)
    {
        self.descriptionLabel.text = @"Enter your username.";
        self.textField.text = self.usernameString;
    }
    else if (self.emailString)
    {
        self.descriptionLabel.text = @"Enter your Email.";
        self.textField.text = self.emailString;
    }

}

@end
