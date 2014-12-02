//
//  CapslTableViewCell.m
//  Capsl
//
//  Created by Jonathan Kim on 11/27/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "CapslTableViewCell.h"

@implementation CapslTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)counterUpdated:(NSString *)dateString
{
    self.timerLabel.text = dateString;
//    if ([self.timerLabel.text isEqual:@"OPEN!"])
//    {
//        self.timerLabel.textColor = [UIColor whiteColor];
//        self.timerLabel.backgroundColor = [UIColor blueColor];
//    }
}

@end
