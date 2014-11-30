//
//  RecordAudioViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/29/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "RecordAudioViewController.h"
@import AVFoundation;

@interface RecordAudioViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property AVAudioRecorder *recorder;
@property AVAudioPlayer *player;

@end

@implementation RecordAudioViewController

//code from Appcoda http://www.appcoda.com/ios-avfoundation-framework-tutorial/
//TODO:need to create CPSL and perform segueToCompose

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Disable Stop/Play button when application launches
    [self.stopButton setEnabled:NO];
    [self.playButton setEnabled:NO];

    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
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

- (IBAction)onRecordButtonTapped:(UIButton *)sender
{
    // Stop the audio player before recording
    if (self.player.playing) {
        [self.player stop];
    }

    if (!self.recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];

        // Start recording
        [self.recorder record];
        [self.recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];

    } else {

        // Pause recording
        [self.recorder pause];
        [self.recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }

    [self.stopButton setEnabled:YES];
    [self.playButton setEnabled:NO];
}

- (IBAction)onStopTapped:(UIButton *)sender
{
    [self.recorder stop];

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (IBAction)onPlayTapped:(UIButton *)sender
{
    if (!self.recorder.recording){
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
        [self.player setDelegate:self];
        [self.player play];
    }
}

#pragma mark AVAudioRecorderDelegate
//Delegate method for handling interruption during recording
- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [self.recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];

    [self.stopButton setEnabled:NO];
    [self.playButton setEnabled:YES];
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




@end
