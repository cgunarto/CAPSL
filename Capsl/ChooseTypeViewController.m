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

@interface ChooseTypeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ChooseTypeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.imageView.image = [UIImage imageNamed:@"mountain"];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mountain"]];
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
