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
@property (strong, nonatomic) UIImage *chosenImage;
@property Capsl *createdCapsl;

//TODO:pass CAPSL object


@end

@implementation CaptureViewController

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

    self.createdCapsl = [Capsl object];
}


- (IBAction)takePhotoButtonPressed:(UIButton *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;

    [self presentViewController:picker animated:YES completion:NULL];
}

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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SearchContactViewController *searchContactVC = segue.destinationViewController;

    //TODO:delete chosenImage later
    searchContactVC.chosenImage = self.chosenImage;
    searchContactVC.createdCapsl = self.createdCapsl;
}

- (IBAction)onUsePhotoPressed:(UIButton *)sender
{
    if (self.imageView.image != nil)
    {
        [self performSegueWithIdentifier:@"segueToContactSearch" sender:self];
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
