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
@property (strong, nonatomic) MPMoviePlayerController *videoController;

//isEditing only property
@property (weak, nonatomic) IBOutlet UIButton *exitPlayVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *playVideoButton;
@property (strong, nonatomic) NSData *videoData;

@end

@implementation RecordVideoViewController

//When page is here, record button needs to go up

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = self.cancelButton;
    self.navigationItem.rightBarButtonItem = self.doneButton;

    [self showVideoRecorder];
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CAMERA NOT AVAILABLE"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okButton];
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


    self.videoController = [[MPMoviePlayerController alloc] init];
    [self.videoController setContentURL:self.videoURL];

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect frame = CGRectMake(0, 0, screenWidth, screenHeight);

    //TODO:change the width of video, constraint video format
    [self.videoController.view setFrame:frame];

    self.videoController.controlStyle = MPMovieControlStyleFullscreen;
    [self.view addSubview:self.videoController.view];

    //Adds notification after the video is finished playing
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoPlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:self.videoController];


    [self.videoController play];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self performSegueWithIdentifier:@"unwindToCapture" sender:self];
}

- (void)videoPlayBackDidFinish:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];

    // Stop the video player and remove it from view
//    [self.videoController stop];
//    [self.videoController.view removeFromSuperview];
//    self.videoController = nil;

    // Display a message
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Video Playback" message:@"Just finished the video playback. The video is now removed." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];

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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"NOTHING RECORDED"
                                                                       message:@"Please record a video"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okButton];
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

//Play for isEditing
- (IBAction)onPlaybuttonPressed:(UIButton *)sender
{

}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isEqual:self.doneButton])
    {
        UINavigationController *navVC = segue.destinationViewController;
        SearchContactViewController *searchContactVC = navVC.childViewControllers.firstObject;
        searchContactVC.createdCapsl = self.createdCapsl;
    }
}


@end
