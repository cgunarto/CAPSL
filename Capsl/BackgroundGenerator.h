//
//  BackgroundGenerator.h
//  Capsl
//
//  Created by Mobile Making on 12/7/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BackgroundGenerator : NSObject

+ (UIImage *)blurImage:(UIImage *)image withRadius:(float)radius;
+ (UIImage *)generateDefaultBackground;

@end
