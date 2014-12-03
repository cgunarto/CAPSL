//
//  CapslTableViewCell.h
//  Capsl
//
//  Created by Jonathan Kim on 11/27/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JKCountDownTimer.h"
#import "Capsl.h"
#import "Capslr.h"

@interface CapslTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *capslrLabel;
@property (strong, nonatomic) IBOutlet UILabel *deliveryDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;

@property NSString *timerString;

- (void)updateTimeLabelForCapsl:(Capsl *)capsl;

@end
