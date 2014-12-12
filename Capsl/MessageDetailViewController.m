//
//  MessageDetailViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "Capslr.h"
#import "JKCountDownTimer.h"
@import AVFoundation;

@interface MessageDetailViewController () <AVAudioPlayerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *senderLabel;
@property (strong, nonatomic) IBOutlet UILabel *deliveryDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UITextView *unavailableMessage;

//String for TIMER
@property NSString *timerString;

// ----TYPES OF MESSAGE---- //

//Text Message
@property (strong, nonatomic) IBOutlet UITextView *textMessage;

//Photo Message
@property (strong, nonatomic) IBOutlet UIImageView *photoMessage;

//Audio Message
@property AVAudioPlayer *player;
@property (strong, nonatomic) IBOutlet UIButton *audioPlayerButton;


@end

@implementation MessageDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // Customizing back button in Navbar
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                initWithTitle:@"Back"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem = backButton;

    // Passing Delivery Date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    NSDate *deliveryDate = self.chosenCapsl.deliveryTime;
    self.deliveryDateLabel.text = [dateFormatter stringFromDate:deliveryDate];

    //Sender
    PFQuery *query = [Capslr query];
    [query whereKey:@"objectId" equalTo: self.chosenCapsl.sender.objectId];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {

        self.senderLabel.text = [NSString stringWithFormat:@"From: %@", object[@"username"]];
    }];

    //Timer
//    JKCountDownTimer *timer = [[JKCountDownTimer alloc] initWithDeliveryDate:self.chosenCapsl.deliveryTime withDelegate:self];
//    [timer updateLabel];

    //Text Message
    [self displayTextMessage];

    //Photo Message
    [self displayPhotoMessage];

    //Audio Message
    if ([self.statusLabel.text containsString:@"Viewed"] && self.chosenCapsl.audio != nil)
    {
        // unhide the audio button
        self.audioPlayerButton.hidden = NO;
    }
}

#pragma mark - Displaying Text Message Capsl
- (void)displayTextMessage
{
    //Text Message
    if ([self.statusLabel.text isEqual:@"OPEN!"])
    {
        self.textMessage.text = self.chosenCapsl.text;

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd-yyyy HH:mm"];
        NSDate *viewedAt = self.chosenCapsl.viewedAt;
        self.statusLabel.text = [NSString stringWithFormat:@"Viewed At: %@", [dateFormatter stringFromDate:viewedAt]];
    }
    else
    {
        self.textMessage.hidden = YES;
        self.unavailableMessage.hidden = NO;
    }
}

#pragma mark - Displaying Photo Message Capsl
- (void)displayPhotoMessage
{
    //Photo Message
    if ([self.statusLabel.text isEqual:@"OPEN!"] || [self.statusLabel.text containsString:@"Viewed"])
    {
        [self.chosenCapsl.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            self.photoMessage.image = [UIImage imageWithData:data];

        }];
    }
    else
    {
        self.unavailableMessage.hidden = NO;
    }
}

#pragma mark - Display Audio Message
- (IBAction)onPlayAudioButtonPressed:(UIButton *)sender
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];

    PFFile *audioFile = self.chosenCapsl.audio;
    NSString *filePath = [audioFile url];
    NSURL *audioURL = [NSURL URLWithString:filePath];

    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
    [self.player setDelegate:self];
    [self.player play];
}


#pragma mark - JKTimer Delegate Method
//-(void)counterUpdated:(NSString *)dateString
//{
//    self.statusLabel.text = dateString;
//}


#pragma mark - Alert
-(void)notAvailableAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Capsl is not yet available" message:@"Please check again later" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];

    [alert addAction:okButton];

    [alert.view setTintColor:kAlertControllerTintColor];

    [self presentViewController:alert animated:YES completion:nil];
}


@end
