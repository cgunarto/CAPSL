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

@end

@implementation ChooseTypeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (IBAction)onSendButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"segueToCapture" sender:self];
}

- (IBAction)onRecordButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"segueToRecord" sender:self];
}

@end
