//
//  CaptureViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "CaptureViewController.h"
#import "SearchContactViewController.h"
#import "RecordAudioViewController.h"
#import "Capsl.h"
#import "Capslr.h"
#define kOFFSET_FOR_KEYBOARD 200;

@interface CaptureViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property UIImage *chosenImage;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *addAudioButton;
@property (weak, nonatomic) IBOutlet UILabel *characterCountLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTextViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomAddAudioConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLabelConstraint;

@end

@implementation CaptureViewController

#pragma mark View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.characterCountLabel.hidden = YES;

    //If VC isEditing, it is trying to create a Capsl message
    if (self.isEditing)
    {
        self.textView.delegate = self;

        //Setting CPSL sender
        [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error)
         {
             self.createdCapsl.sender = currentCapslr;
         }];

        //Initializing Capsl object and its type
        self.createdCapsl = [Capsl object];
        self.createdCapsl.type = @"multimedia";
        self.navigationItem.leftBarButtonItem = self.cancelButton;
        self.navigationItem.rightBarButtonItem = self.doneButton;

        self.imageView.userInteractionEnabled = YES;
        self.textView.userInteractionEnabled = YES;

    }

    //If VC isEditing is NO, it is trying to unwrap and display a CPSL message
    else
    {
        self.imageView.userInteractionEnabled = NO;
        self.textView.userInteractionEnabled = NO;
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.isEditing)
    {
        // register for keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        if (self.createdCapsl.audio)
        {
            [self.addAudioButton setTitle:@"Audio added - tap to edit" forState:UIControlStateNormal];
        }
    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (self.isEditing)
    {
        // unregister for keyboard notifications while not visible.
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillShowNotification
                                                      object:nil];

        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIKeyboardWillHideNotification
                                                      object:nil];
    }
}

- (void)keyboardWillShow
{
    if (self.isEditing)
    {
        //If image is not nil, move the keyboard up by Keyboard height
        //If image is nil, don't do anything
        if (self.imageView.image)
        {
            CGRect rect = [[UIApplication sharedApplication] keyWindow].frame;
            rect.origin.y -= kOFFSET_FOR_KEYBOARD;
            rect.size.height += kOFFSET_FOR_KEYBOARD;
            [[UIApplication sharedApplication] keyWindow].frame = rect;

            // Animate the current view out of the way
            if ([[UIApplication sharedApplication] keyWindow].frame.origin.y >= 0)
            {
                [self setViewMovedUp:YES];
            }
            else if ([[UIApplication sharedApplication] keyWindow].frame.origin.y < 0)
            {
                [self setViewMovedUp:NO];
            }
        }
    }
}

- (void)keyboardWillHide
{
    if (self.isEditing)
    {
        //If image is not nil, move the keyboard down by Keyboard height
        //If image is nil, don't do anything
        if (self.imageView.image)
        {
            // Animate the current view out of the way
            if ([[UIApplication sharedApplication] keyWindow].frame.origin.y >= 0)
            {
                [self setViewMovedUp:YES];
            }
            else if ([[UIApplication sharedApplication] keyWindow].frame.origin.y < 0)
            {
                [self setViewMovedUp:NO];
            }
        }
    }
}

//method to move the view up/down whenever the keyboard is shown/dismissed
//is NOT called when isEditing is NO
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view

    //Move the whole application's frame instead of the view
    CGRect rect = [[UIApplication sharedApplication] keyWindow].frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height = [UIScreen mainScreen].bounds.size.height;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height = [UIScreen mainScreen].bounds.size.height;
    }
    [[UIApplication sharedApplication] keyWindow].frame = rect;

    [UIView commitAnimations];
}


#pragma mark Image Picker Related Methods

//ImageView does not have user interaction enabled so the method below will not be enabled when editing
- (IBAction)onImageTapped:(UITapGestureRecognizer *)sender
{
    //Trigger an action sheet, 1 goes to camera, 2 goes to photo folder
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"SELECT IMAGE SOURCE" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *cameraButton = [UIAlertAction actionWithTitle:@"Camera"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
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

                                       [alert dismissViewControllerAnimated:YES completion:nil];

                                   }];


    UIAlertAction *libraryButton = [UIAlertAction actionWithTitle:@"Photo Library"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action)
                                   {
                                       UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                       picker.delegate = self;
                                       picker.allowsEditing = YES;
                                       picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

                                       [self presentViewController:picker animated:YES completion:NULL];

                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];



    UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:nil];

                                   }];

    [alert addAction:cameraButton];
    [alert addAction:libraryButton];
    [alert addAction:cancelButton];

    [self presentViewController:alert
                       animated:YES
                     completion:nil];



}

//Not called when isEditing is NO
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Accessing uncropped image from info dictionary
    self.chosenImage = info[UIImagePickerControllerOriginalImage];
    self.imageView.image = self.chosenImage;

    [picker dismissViewControllerAnimated:YES completion:NULL];

    //Settign CPSL image to be sent
    NSData *imageData = UIImageJPEGRepresentation(self.chosenImage, 1.0f);
    self.createdCapsl.photo = [PFFile fileWithName:@"image.jpg" data:imageData];

    [self setTextViewToBottom];
    [self setAddAudioToBottom];

}

//Not called when isEditing is NO
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark Segue and Next Button

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //If sender is Use Photo Button, pass info to next VC
    if ([segue.identifier isEqualToString:@"segueToContactSearch"])
    {
        SearchContactViewController *searchContactVC = segue.destinationViewController;
        searchContactVC.createdCapsl = self.createdCapsl;
    }

    //Passig whatever created to RecordAudioVC so audioVC can add audio files
    //Accessing it through the NavVC
    if ([segue.identifier isEqualToString:@"segueToAudio"])
    {
        UINavigationController *navVC = segue.destinationViewController;
        RecordAudioViewController *recordVC = navVC.childViewControllers[0];
        recordVC.createdCapsl = self.createdCapsl;
    }
}

//Not available when isEditing is NO
- (IBAction)onDoneButtonPressed:(UIBarButtonItem *)sender
{
    if (self.createdCapsl.photo || self.createdCapsl.audio || self.createdCapsl.text)
    {
        [self performSegueWithIdentifier:@"segueToContactSearch" sender:self.doneButton];
    }

    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"NO CAPSL CREATED"
                                                                       message:@"Choose a photo, record audio, or write text"
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

//Not called when isEditing is NO
- (void)textViewDidBeginEditing:(UITextView *)textView
{
//    [self.navigationController setNavigationBarHidden:YES];
    self.characterCountLabel.hidden = NO;

    if ([textView.text isEqualToString:@"Enter Text Here"])
    {
        textView.text = @"";
    }

    if (self.imageView.image)
    {
        //move the main view, so that the keyboard does not hide it.
        if  (self.textView.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    NSInteger length = textView.text.length;
    self.characterCountLabel.text = [NSString stringWithFormat:@"Character left: %li",150-length];
}

//Not called when isEditing is NO
- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.characterCountLabel.hidden = YES;
    self.createdCapsl.text = self.textView.text;
    [self resignFirstResponder];
    [self.navigationController setNavigationBarHidden:NO];

    //If text is empty, enter text here shows up after editing is done
    if ([textView.text isEqualToString:@""])
    {
        textView.text = @"Enter Text Here";
    }
}

//Not called when isEditing is NO
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }

    if([[textView text] length] - range.length + text.length > 150)
    {
        return NO;
    }
    return YES;
}

#pragma mark Text View Placement
- (void)setTextViewToBottom
{
    [self.view removeConstraint:self.bottomTextViewConstraint];

    self.textView.translatesAutoresizingMaskIntoConstraints = NO;

    self.bottomTextViewConstraint = [NSLayoutConstraint constraintWithItem:self.textView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0f
                                                                  constant:0.0f];
    [self.view addConstraint:self.bottomTextViewConstraint];

}

- (void)setAddAudioToBottom
{
    self.bottomAddAudioConstraint.constant = 0;
}

- (IBAction)unWindToCaptureSegue:(UIStoryboardSegue *)segue
{
}



@end
