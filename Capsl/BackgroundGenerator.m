//
//  BackgroundGenerator.m
//  Capsl
//
//  Created by Mobile Making on 12/7/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "BackgroundGenerator.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Resize.h"

@implementation BackgroundGenerator

+ (UIImage *)blurImage:(UIImage *)image
            withRadius:(float)radius
{

    UIImage *newImage = [self imageResize:image];

    UIColor *tintColor = [UIColor colorWithWhite:0.3 alpha:0.1];
    UIImage *blurredImage = [newImage applyBlurWithRadius:radius tintColor:tintColor saturationDeltaFactor:0.8 maskImage:nil];

    return blurredImage;

}

+ (UIImage *)imageResize :(UIImage *)img
{
//    CGFloat scale = [[UIScreen mainScreen]scale];

    CGSize newSize = [[UIScreen mainScreen] bounds].size;

    //UIGraphicsBeginImageContext(newSize);
//    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
//    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
//    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();

    UIImage *newImage = [img resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:newSize interpolationQuality:0.0];


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
