//
//  CaptureViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "CaptureViewController.h"
#import "SearchContactViewController.h"
#import "Capsl.h"
#import "Capslr.h"

@interface CaptureViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property Capsl *createdCapsl;
@property UIImage *chosenImage;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation CaptureViewController

#pragma mark View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.textView.delegate = self;
//    [self.view addSubview:self.textView];

    //Setting CPSL sender
    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error)
     {
         self.createdCapsl.sender = currentCapslr;
     }];

    //Initializing Capsl object and its type
    self.createdCapsl = [Capsl object];
    self.createdCapsl.type = @"multimedia";
    self.navigationItem.leftBarButtonItem = self.cancelButton;
}


//Setting textView to the center of the screen
- (void)setTextViewToCenter;
{
//    NSLog(@"Setting text to center!");
//
//    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
//
//    NSLayoutConstraint *constraint = [NSLayoutConstraint
//                                      constraintWithItem:self.textView
//                                      attribute:NSLayoutAttributeCenterX
//                                      relatedBy:NSLayoutRelationEqual
//                                      toItem:self.view
//                                      attribute:NSLayoutAttributeCenterX
//                                      multiplier:1.0f
//                                      constant:0.0f];
//
//    [self.view addConstraint:constraint];
//
//    constraint = [NSLayoutConstraint
//                  constraintWithItem:self.textView
//                  attribute:NSLayoutAttributeCenterY
//                  relatedBy:NSLayoutRelationEqual
//                  toItem:self.view
//                  attribute:NSLayoutAttributeCenterY
//                  multiplier:1.0f
//                  constant:0.0f];
//
//    [self.view addConstraint:constraint];
//
//    constraint = [NSLayoutConstraint constraintWithItem:self.textView
//                                              attribute:NSLayoutAttributeWidth
//                                              relatedBy:NSLayoutRelationEqual
//                                                 toItem:self.view
//                                              attribute:NSLayoutAttributeWidth
//                                             multiplier:1.0f
//                                               constant:0.0f];
//
//    [self.view addConstraint:constraint];
//
//    constraint = [NSLayoutConstraint constraintWithItem:self.textView
//                                              attribute:NSLayoutAttributeHeight
//                                              relatedBy:NSLayoutRelationEqual
//                                                 toItem:self.view
//                                              attribute:NSLayoutAttributeHeight
//                                             multiplier:0.3f
//                                               constant:0.0f];
//
//    [self.view addConstraint:constraint];

}


#pragma mark Image Picker Related Methods

- (IBAction)onImageTapped:(UITapGestureRecognizer *)sender
{

    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];

    }

    else
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;

        [self presentViewController:picker animated:YES completion:NULL];
    }
}

//TODO:CUSTOMIZE CAMERA OVERLAY
- (IBAction)selectPhotoButtonPressed:(UIButton *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.navigationItem.rightBarButtonItem = self.doneButton;

    //Accessing uncropped image from info dictionary
    self.chosenImage = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = self.chosenImage;

    [picker dismissViewControllerAnimated:YES completion:NULL];

    //Settign CPSL image to be sent
    NSData *imageData = UIImageJPEGRepresentation(self.chosenImage, 1.0f);
    self.createdCapsl.photo = [PFFile fileWithName:@"image.jpg" data:imageData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark Segue and Next Button

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //If sender is Use Photo Button, pass info to next VC
    if ([sender isEqual:self.doneButton])
    {
        SearchContactViewController *searchContactVC = segue.destinationViewController;

        searchContactVC.createdCapsl = self.createdCapsl;
    }
}

- (IBAction)onDoneButtonPressed:(UIBarButtonItem *)sender
{
    if (self.createdCapsl.photo != nil)
    {
        [self performSegueWithIdentifier:@"segueToContactSearch" sender:self.doneButton];
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"NO PHOTOS CHOSEN"
                                                                       message:@"take a photo or select image"
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

#pragma mark Text View Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
//    //TODO: not setting text view center
//    [self setTextViewToCenter];

    [self.navigationController setNavigationBarHidden:YES];

    if ([textView.text isEqualToString:@"Enter Text Here"])
    {
        textView.text = @"";
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.createdCapsl.text = self.textView.text;
    [self resignFirstResponder];
    [self.navigationController setNavigationBarHidden:NO];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];

    }
    return YES;
}



@end
