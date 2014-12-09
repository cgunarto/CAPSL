//
//  AllContactTableViewCell.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/29/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "AllContactTableViewCell.h"

@implementation AllContactTableViewCell


- (void)awakeFromNib
{
    [super awakeFromNib];
    self.photoImageView.backgroundColor = kProfilPicBackgroundColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse
{
//    self.photoImageView.backgroundColor = kProfilPicBackgroundColor;
}

@end
