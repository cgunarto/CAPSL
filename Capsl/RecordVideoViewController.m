//
//  RecordVideoViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 12/1/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "RecordVideoViewController.h"
#import "SearchContactViewController.h"
#import "Capslr.h"
#import "Capsl.h"
#define kMaxVideoSeconds 60
#define kVideoQuality UIImagePickerControllerQualityTypeMedium

@import MediaPlayer;
@import MobileCoreServices;

@interface RecordVideoViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recordVideo;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@property (strong, nonatomic) NSURL *videoURL;

@property (weak, nonatomic) IBOutlet UIButton *exitPlayVideoButton;
@property (strong, nonatomic) NSData *videoData;

@end

@implementation RecordVideoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.exitPlayVideoButton.hidden = YES;
    [self showVideoRecorder];
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    self.view.backgroundColor = [UIColor clearColor];
//    [self showVideoRecorder];
//}

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

#pragma mark Record button and methods

- (void)showVideoRecorder
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.mediaTypes = [[NSArray alloc]initWithObjects:(NSString *) kUTTypeMovie, nil];

        [picker setVideoMaximumDuration:kMaxVideoSeconds];
        [picker setVideoQuality:kVideoQuality];

        [self presentViewController:picker animated:YES completion:NULL];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Camera not available"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okButton];

        [alert.view setTintColor:kAlertControllerTintColor];

        [self presentViewController:alert
                           animated:YES
                         completion:nil];

    }
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.videoURL = info[UIImagePickerControllerMediaURL];

    [picker dismissViewControllerAnimated:YES completion:NULL];

    self.createdCapsl = [Capsl object];

    //Setting CPSL sender
    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error)
     {
         self.createdCapsl.sender = currentCapslr;
     }];
    //Initializing Capsl object and its type
    self.createdCapsl.type = @"video";

    //set created capsule video
    NSData *videoData = [[NSData alloc] initWithContentsOfURL:self.videoURL];
    self.createdCapsl.video = [PFFile fileWithName:@"video.mov" data:videoData];

    [self performSegueWithIdentifier:@"segueToSearchContact" sender:self];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Camera exited");
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self performSegueWithIdentifier:@"unwindToCapture" sender:self];
}


#pragma mark Next and Segue

- (IBAction)onDoneButtonPressed:(UIBarButtonItem *)sender
{
    if (self.createdCapsl.video)
    {
        [self performSegueWithIdentifier:@"segueToSearchContact" sender:self.doneButton];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Nothing recorded"
                                                                       message:@"Please record a video"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okButton];

        [alert.view setTintColor:kAlertControllerTintColor];

        [self presentViewController:alert
                           animated:YES
                         completion:nil];

    }
}

- (IBAction)onCancelButtonPressed:(UIBarButtonItem *)sender
{
}

- (IBAction)onExitRecordVideo:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segueToSearchContact"])
    {
        UINavigationController *navVC = segue.destinationViewController;
        SearchContactViewController *searchContactVC = navVC.childViewControllers.firstObject;
        searchContactVC.createdCapsl = self.createdCapsl;
    }
}


@end
