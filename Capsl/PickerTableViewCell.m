//
//  PickerTableViewCell.m
//  DateCellTest
//
//  Created by CHRISTINA GUNARTO on 12/4/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "PickerTableViewCell.h"

@implementation PickerTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    [self.datePicker setMinimumDate:[NSDate date]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
