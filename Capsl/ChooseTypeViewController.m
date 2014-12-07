//
//  ChooseTypeViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "ChooseTypeViewController.h"
#import "RecordAudioViewController.h"
#import "CaptureViewController.h"
#import "SVProgressHUD.h"

@interface ChooseTypeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UIButton *sendPhotoButton;
@property (strong, nonatomic) IBOutlet UIButton *sendVideoButton;

@end

@implementation ChooseTypeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

//    self.view.backgroundColor = [UIColor colorWithPatternImage:kChooseScreenWallpaper];

    self.sendPhotoButton.layer.cornerRadius = 44;
    self.sendPhotoButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.sendPhotoButton.layer.borderWidth = 1;

    self.sendVideoButton.layer.cornerRadius = 44;
    self.sendVideoButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.sendVideoButton.layer.borderWidth = 1;


}

#pragma mark Segue

- (IBAction)unWindSegue:(UIStoryboardSegue *)segue
{

    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToCapture"])
    {
        UINavigationController *navVC = segue.destinationViewController;
        CaptureViewController *captureVC = navVC.childViewControllers[0];
        captureVC.isEditing = YES;
    }
}

@end
