//
//  EditProfilePicTableViewCell.m
//  Capsl
//
//  Created by Jonathan Kim on 12/3/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "EditProfilePicTableViewCell.h"

@implementation EditProfilePicTableViewCell

- (void)awakeFromNib
{

    self.profileImageView.layer.cornerRadius = 60;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
