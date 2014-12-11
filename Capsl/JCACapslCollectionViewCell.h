//
//  JCACapslCollectionViewCell.h
//  Timeline Test 2
//
//  Created by Mobile Making on 11/24/14.
//  Copyright (c) 2014 Alex Hsu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Capsl;
@interface JCACapslCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicView;
@property (strong, nonatomic) IBOutlet UILabel *deliveryDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *countdownLabel;

- (void)updateLabelsForCapsl:(Capsl *)capsl;
- (void)drawCellforSentCapsl:(Capsl *)capsl withSentStatus:(BOOL)showSent;

@end