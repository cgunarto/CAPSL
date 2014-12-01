//
//  WriteViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/30/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "WriteViewController.h"
#import "SearchContactViewController.h"
#import "Capslr.h"
#import "Capsl.h"


@interface WriteViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property NSString *messageToSend;

@property Capsl *createdCapsl;

@end

@implementation WriteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.textView.delegate = self;
}

- (IBAction)onNextButtonPressed:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"segueToContactSearch" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isEqual:self.nextButton])
    {
        SearchContactViewController *searchContactVC = segue.destinationViewController;
        searchContactVC.createdCapsl = self.createdCapsl;
    }
}



@end
