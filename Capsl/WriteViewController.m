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

    //Setting CPSL sender
    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error)
     {
         self.createdCapsl.sender = currentCapslr;
     }];

    //Initializing Capsl object and its type
    self.createdCapsl = [Capsl object];
    self.createdCapsl.type = @"text";
}

- (IBAction)onNextButtonPressed:(UIButton *)sender
{
    if (![self.textView.text isEqualToString:@""])
    {
        //TODO:ask for user confirmation before moving forward
        [self performSegueWithIdentifier:@"segueToContactSearch" sender:self.nextButton];
    }

    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"MESSAGE EMPTY"
                                                                       message:@"Please write a message"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okButton];
        [self presentViewController:alert
                           animated:YES
                         completion:nil];

    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isEqual:self.nextButton])
    {
        SearchContactViewController *searchContactVC = segue.destinationViewController;
        searchContactVC.createdCapsl = self.createdCapsl;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.createdCapsl.text = textView.text;
}



@end
