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

@interface CaptureViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
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
    if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        [myAlertView show];

    }

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

-(void)setImageView:(UIImageView *)imageView
{
    //if image view is set, move textview to bottom of screen
    
}

#pragma mark Image Picker Related Methods

- (IBAction)onImageTapped:(UITapGestureRecognizer *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self presentViewController:picker animated:YES completion:NULL];
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
    NSData *imageData = UIImageJPEGRepresentation(self.chosenImage, 0.05f);
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



@end
