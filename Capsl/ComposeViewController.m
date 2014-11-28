//
//  ComposeViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "ComposeViewController.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ComposeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = self.chosenImage;
}

//set Time Date
//set recipient - Capslr


//create Capsl object with file, time delivered, sender Capslr (PFUser CurrentUser)
//upload it to Parse






@end
