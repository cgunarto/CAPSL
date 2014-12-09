//
//  SendCapsuleTableViewCell.m
//  Capsl
//
//  Created by Mobile Making on 12/9/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "SendCapsuleTableViewCell.h"

@implementation SendCapsuleTableViewCell

- (void)awakeFromNib
{

    self.sendButton.layer.cornerRadius = 44;
    self.sendButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.sendButton.layer.borderWidth = 1;


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
