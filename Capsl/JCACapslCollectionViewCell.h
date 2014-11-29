//
//  JCACapslCollectionViewCell.h
//  Timeline Test 2
//
//  Created by Mobile Making on 11/24/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JCACapslCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicView;
@property (strong, nonatomic) IBOutlet UIButton *countdownButton;
@property (strong, nonatomic) IBOutlet UILabel *deliveryDateLabel;

@end