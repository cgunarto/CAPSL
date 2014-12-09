//
//  BackgroundGenerator.m
//  Capsl
//
//  Created by Mobile Making on 12/7/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "BackgroundGenerator.h"
#import "UIImage+ImageEffects.h"

@implementation BackgroundGenerator

+ (UIImage *)blurImage:(UIImage *)image
{

    [self imageResize:image];

    UIColor *tintColor = [UIColor colorWithWhite:0.3 alpha:0.1];
    UIImage *blurredImage = [image applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:0.8 maskImage:nil];

    return blurredImage;
    
}

+ (UIImage *)imageResize :(UIImage *)img
{
    CGFloat scale = [[UIScreen mainScreen]scale];

    CGSize newSize = [[UIScreen mainScreen] bounds].size;

    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)generateDefaultBackground
{

    int imageNumber;
    imageNumber = arc4random_uniform(4) + 1;
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"wallpaperTexture-%i", imageNumber]];

    return image;

}

@end
