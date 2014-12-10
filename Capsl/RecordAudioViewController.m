//
//  RecordAudioViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/29/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "RecordAudioViewController.h"
#import "CaptureViewController.h"
#import "Capsl.h"
#import "Capslr.h"
#define kMaxAudioDuration 60

@import AVFoundation;

@interface RecordAudioViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *endRecordingButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteRecordingButton;

@property AVAudioRecorder *recorder;
@property AVAudioPlayer *player;

@end

@implementation RecordAudioViewController

//code referenced from Appcoda http://www.appcoda.com/ios-avfoundation-framework-tutorial/

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.endRecordingButton setEnabled:NO];
    [self setUpAudioSessionAndRecorder];
    [self setButtonStateToReflectAudioAvailability];
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


#pragma mark Audio Control Button Methods

- (IBAction)onRecordButtonTapped:(UIButton *)sender
{
    // Stop the audio player before recording
    if (self.player.playing)
    {
        [self.player stop];
    }

    if (!self.recorder.recording)
    {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];

        [self.recorder recordForDuration:kMaxAudioDuration];
        [self.recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        //Code to record without max duration - [self.recorder record];
    }

    else
    {
        // Pause recording
        [self.recorder pause];
        [self.recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }

    [self.endRecordingButton setEnabled:YES];

    //When user is recording, they can't play the recording until recording ends
    [self.playButton setEnabled:NO];
}

//Whatever is recorded is saved only when the EndRecording Button is tapped
- (IBAction)onEndRecordingTapped:(UIButton *)sender
{
    [self.recorder stop];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];

    //TODO: Limit Audio Data File
    self.audioData = [[NSData alloc] initWithContentsOfURL:self.recorder.url];
    self.createdCapsl.audio = [PFFile fileWithName:@"audio.m4a" data:self.audioData];

}

- (IBAction)onPlayTapped:(UIButton *)sender
{
    if (!self.recorder.recording)
    {
        //Playing from document's directory self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
        self.player = [[AVAudioPlayer alloc] initWithData:self.audioData fileTypeHint:@"m4a" error:nil];
        [self.player setDelegate:self];
        [self.player play];
    }

}

- (IBAction)onDeleteRecordingButtonTapped:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DELETE?"
                                                                   message:@"Are you sure you want to delete current recording?"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:@"Yes"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action)
    {
        [self deleteRecordedAudio];
        [self setButtonStateToReflectAudioAvailability];
    }];

    UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action)
    {
         [alert dismissViewControllerAnimated:YES completion:nil];
    }];

    [alert addAction:yesButton];
    [alert addAction:cancelButton];
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

#pragma mark Helper Method

//Initial Audio Session and Recording set up
- (void)setUpAudioSessionAndRecorder
{
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudio.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];

    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];

    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];

    // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;

    [self.recorder prepareToRecord];
}

- (void)deleteRecordedAudio
{
    NSLog(@"Audio Deleted");
    self.audioData = nil;
    self.createdCapsl.audio = nil;

    [self.recorder deleteRecording];
}

- (void) setButtonStateToReflectAudioAvailability
{
    if (self.audioData)
    {
        [self.deleteRecordingButton setEnabled:YES];
        [self.playButton setEnabled:YES];
    }
    else
    {
        [self.deleteRecordingButton setEnabled:NO];
        [self.playButton setEnabled:NO];
    }
}


#pragma mark AVAudioRecorderDelegate

//Delegate method for handling interruption during recording
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag
{
    [self.recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [self.endRecordingButton setEnabled:NO];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];

    //TODO: Limit Audio Data File
    self.audioData = [[NSData alloc] initWithContentsOfURL:self.recorder.url];
    self.createdCapsl.audio = [PFFile fileWithName:@"audio.m4a" data:self.audioData];

    [self setButtonStateToReflectAudioAvailability];
}

#pragma mark AVAudioPlayerDelegate
//Delegate method for handling interreuption during playback
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark Next Button and Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    CaptureViewController *captureVC = segue.destinationViewController;
    captureVC.createdCapsl = self.createdCapsl;
    captureVC.audioData = self.audioData;
}



@end
