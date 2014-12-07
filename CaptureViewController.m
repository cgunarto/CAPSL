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
#define kOFFSET_FOR_KEYBOARD 200
#define kImageResolution 0.2f
#define kTextViewDistanceFromBottom 100.0f
#define kCharacterLimit 120

@interface CaptureViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property UIImage *chosenImage;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *addAudioButton;
@property (weak, nonatomic) IBOutlet UILabel *characterCountLabel;
@property (strong, nonatomic) IBOutlet UIButton *enterTextButton;
@property (strong, nonatomic) IBOutlet UIButton *addPhotoButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTextViewConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addAudioButtonCenterYConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *addAudioButtonWidthConstraint;

@property CGSize kbSize;

#pragma mark NOT EDITING ONLY properties
@property (weak, nonatomic) IBOutlet UIButton *exitButton;

@end

@implementation CaptureViewController

#pragma mark View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];


    //If VC isEditing, it is trying to create a Capsl message
    if (self.isEditing)
    {
        self.textView.delegate = self;
        self.exitButton.hidden = YES;

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

        [self processButton:self.enterTextButton withImageName:@"lowercase-50"];
        [self processButton:self.addPhotoButton withImageName:@"camera-50"];
        [self processButton:self.addAudioButton withImageName:@"audio_wave-50"];
        [self makeNavBarTransparent:YES];

    }

    //If VC isEditing is NO, it is trying to unwrap and display a CPSL message
    else
    {

        self.enterTextButton.hidden = YES;
        self.addPhotoButton.hidden = YES;
        self.addAudioButton.hidden = YES;

        self.imageView.userInteractionEnabled = NO;
        [self.view addSubview:self.textView];
        self.textView.userInteractionEnabled = NO;
        self.exitButton.hidden = NO;

        //Show textview, automatically defaults to center if there is no image
        if (self.textView.text)
        {

            self.textView.text = self.chosenCapsl.text;

            CGSize contentSize = self.textView.contentSize;
            contentSize.height = ceilf([self.textView sizeThatFits:self.textView.frame.size].height);
            self.textView.contentSize = contentSize;

            [self verticalCenterText];

        }

        //Display the Capsl photo if available
        if (self.chosenCapsl.photo)
        {
            [self.chosenCapsl.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
            {
                self.imageView.image = [UIImage imageWithData:data];
            }];

            //If there is text, move it to bottom
            if (self.chosenCapsl.text)
            {
                [self setTextViewToBottom];
            }

            //If there is no text, hide the textview
            else
            {
                self.textView.hidden = YES;
            }
        }

        //Show or Hide Audio Button depending if there is an audio message
        //TODO: if there is no text and no photo put audio button in center of screen with text view background
        self.addAudioButton.hidden = !self.chosenCapsl.audio;


    }


}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.isEditing)
    {
        // register for keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        if (self.createdCapsl.audio)
        {
            [self updateAudioButton];
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

# pragma mark - keyboard behavior

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (self.isEditing)
    {
        //If image is not nil, move the keyboard up by Keyboard height
        //If image is nil, don't do anything

        NSDictionary *userInfo = [notification userInfo];
        self.kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{

    NSDictionary *userInfo = [notification userInfo];
    self.kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

}

//method to move the view up/down whenever the keyboard is shown/dismissed
//is NOT called when isEditing is NO
-(void)shouldMoveViewUpForKeyboard:(BOOL)moveUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view

    //Move the whole application's frame instead of the view
    CGRect rect = [[UIApplication sharedApplication] keyWindow].frame;
    CGFloat textViewDistFromBottom = (rect.size.height - self.textView.frame.origin.y - self.textView.frame.size.height);

    if (moveUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= (self.kbSize.height - textViewDistFromBottom);
        rect.size.height = [UIScreen mainScreen].bounds.size.height;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += (self.kbSize.height - textViewDistFromBottom);
        rect.size.height = [UIScreen mainScreen].bounds.size.height;
    }
    [[UIApplication sharedApplication] keyWindow].frame = rect;

    [UIView commitAnimations];
}


#pragma mark Image Picker Related Methods

//ImageView does not have user interaction enabled so the method below will not be enabled when editing

- (IBAction)onAddPhotoButtonTapped:(UIButton *)sender
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
                                                           style:UIAlertActionStyleCancel
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
    NSData *imageData = UIImageJPEGRepresentation(self.chosenImage, kImageResolution);
    self.imageView.image = [UIImage imageWithData:imageData];


    [picker dismissViewControllerAnimated:YES completion:NULL];

    //Settign CPSL image to be sent
    //TODO: DECIDE APPROPRIATE FILE SIZE
    self.createdCapsl.photo = [PFFile fileWithName:@"image.jpg" data:imageData];

    // darken textview for better text visibility
    self.textView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];

    // add shadow to character counter label
    self.characterCountLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.characterCountLabel.layer.shadowOpacity = 0.3;
    self.characterCountLabel.layer.shadowRadius = 1;
    self.characterCountLabel.layer.shadowOffset = CGSizeMake(0, 1.5f);

    [self setTextViewToBottom];
    [self setAddAudioToBottom];
    [self makeNavBarTransparent:NO];

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

        //This is here so that if the user had already recorded and is going back to the page, they can replay audio data they had created
        recordVC.audioData = self.audioData;
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
                                                                       message:@"Add a photo, record audio, or write a message"
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

    self.characterCountLabel.hidden = NO;

//    [textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];

//    textView.contentOffset = (CGPoint){.x = 0, .y = -(self.textView.bounds.size.height / 2)};


    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.characterCountLabel.hidden = NO;

    [self shouldMoveViewUpForKeyboard:YES];

    [self verticalCenterText];

    self.enterTextButton.hidden = YES;

    self.addPhotoButton.userInteractionEnabled = NO;

}

-(void)textViewDidChange:(UITextView *)textView
{

    [self verticalCenterText];

    NSInteger length = textView.text.length;
    self.characterCountLabel.text = [NSString stringWithFormat:@"%li / %i", kCharacterLimit - length, kCharacterLimit];
}

//Not called when isEditing is NO
- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.characterCountLabel.hidden = YES;
    if (self.textView.text && ![self.textView.text isEqualToString:@""])
    {
            self.createdCapsl.text = self.textView.text;
    }

    [self resignFirstResponder];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [self verticalCenterText];

    //If text is empty, enter text here shows up after editing is done
    if ([textView.text isEqualToString:@""])
    {
        self.enterTextButton.hidden = NO;
    }

    [self shouldMoveViewUpForKeyboard:NO];

    self.addPhotoButton.userInteractionEnabled = YES;


}

//Not called when isEditing is NO
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{


    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }

    if([[textView text] length] - range.length + text.length > kCharacterLimit)
    {
        return NO;
    }
    return YES;
}

#pragma mark actions

- (IBAction)onEditTextButtonPressed:(UIButton *)sender
{

    [self.textView becomeFirstResponder];
}

- (IBAction)onViewTapped:(UITapGestureRecognizer *)sender
{
    [self.textView resignFirstResponder];
}

#pragma mark Text View Observer for center vert align

- (void)verticalCenterText
{

    CGFloat topoffset = ([self.textView bounds].size.height - [self.textView contentSize].height * [self.textView zoomScale])/2.0;
    topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
    self.textView.contentOffset = (CGPoint){.x = 0, .y = -topoffset};

}

//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    UITextView *txtview = object;
//    CGFloat topoffset = ([txtview bounds].size.height - [txtview contentSize].height * [txtview zoomScale])/2.0;
//    topoffset = ( topoffset < 0.0 ? 0.0 : topoffset );
//    txtview.contentOffset = (CGPoint){.x = 0, .y = -topoffset};
//}

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
                                                                  constant:-kTextViewDistanceFromBottom];
    [self.view addConstraint:self.bottomTextViewConstraint];
    [self verticalCenterText];

}

- (void)setAddAudioToBottom
{

    [self.view removeConstraint:self.addAudioButtonCenterYConstraint];

    self.addAudioButton.translatesAutoresizingMaskIntoConstraints = NO;

    self.addAudioButtonCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.addAudioButton
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0f
                                                                  constant:-kTextViewDistanceFromBottom / 2];
    [self.view addConstraint:self.addAudioButtonCenterYConstraint];

}

- (IBAction)unWindToCaptureSegue:(UIStoryboardSegue *)segue
{
}

- (IBAction)onExitButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onCancelButtonPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - helper methods

- (void)processButton:(UIButton *)button withImageName:(NSString *)buttonName
{

    UIImage *image = [[UIImage imageNamed:buttonName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setImage:image forState:UIControlStateNormal];

    button.layer.borderWidth = 1.0;
    button.layer.borderColor = [[UIColor whiteColor] CGColor];
    button.layer.cornerRadius = 30;
    button.tintColor = [UIColor whiteColor];

    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOpacity = 0.3;
    button.layer.shadowRadius = 1;
    button.layer.shadowOffset = CGSizeMake(0, 1.5f);

}

- (void)makeNavBarTransparent:(BOOL)makeTransparent
{

    if (makeTransparent)
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage new];
        self.navigationController.navigationBar.translucent = YES;
    }
    else
    {
        [self.navigationController.navigationBar setBackgroundImage:nil forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = nil;
        self.navigationController.navigationBar.translucent = YES;

    }


}

- (void)updateAudioButton
{

    [self.addAudioButton setImage:nil forState:UIControlStateNormal];
    [self.addAudioButton setTitle:@"AUDIO ADDED" forState:UIControlStateNormal];

    NSString *stringForButton = @"AUDIO ADDED";
    CGSize stringsize = [stringForButton sizeWithAttributes:@{
                                                              NSFontAttributeName: [UIFont fontWithName:self.addAudioButton.titleLabel.font.fontName size:self.addAudioButton.titleLabel.font.pointSize]
                                                              }];

    self.addAudioButtonWidthConstraint.constant = stringsize.width + 40;

}

@end
