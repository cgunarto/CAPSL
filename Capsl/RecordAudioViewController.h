//
//  RecordAudioViewController.h
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/29/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Capsl;

@interface RecordAudioViewController : UIViewController
@property Capsl *createdCapsl;
@property Capsl *chosenCapsl;

@property NSData *audioData;

- (IBAction)onDeleteRecordingButtonTapped:(UIButton *)sender;

@end
