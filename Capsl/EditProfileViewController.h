//
//  EditProfileViewController.h
//  Capsl
//
//  Created by Jonathan Kim on 12/3/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"


@interface EditProfileViewController : UIViewController

@property (nonatomic) NSArray *currenCapslrInfo;
@property (nonatomic) UIImage *currentProfilePicture;

@property (nonatomic) UIImage *updatedProfilePicture;
@property BOOL doNotShowActivityIndicator;

@end
