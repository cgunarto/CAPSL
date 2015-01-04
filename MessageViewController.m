//
//  CaptureViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/25/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "MessageViewController.h"
#import "SearchContactViewController.h"
#import "RecordAudioViewController.h"
#import "Capsl.h"
#import "Capslr.h"
#define kOFFSET_FOR_KEYBOARD 200
#define kImageResolution 0.2f
#define kTextViewDistanceFromBottom 100.0f
#define kCharacterLimit 120
#define kAddAudioButton @"audio_wave-50"

@import AVFoundation;

@interface MessageViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, AVAudioPlayerDelegate>

@property  RecordAudioViewController *recordAudioVC;
@property (strong, nonatomic) IBOutlet UIView *audioControlsContainerView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property UIImage *chosenImage;

@property UIImage *wallpaperImage;

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *audioControlsCenterYConstraint;

@property AVAudioPlayer *player;

@property CGSize kbSize;

#pragma mark NOT EDITING ONLY properties
@property (weak, nonatomic) IBOutlet UIButton *exitButton;

@end

@implementation MessageViewController

#pragma mark View Controller Life Cycle

//Check if there is audio data, and pass it to the embed segue on addAudioButton tapped
//On exitAudio button pressed, store the audioData from childVC into self.audio

- (void)viewDidLoad
{
    [super viewDidLoad];

    //CONDITION FOR NONEDITING AND EDITING
    self.audioControlsContainerView.hidden = YES;
    [self makeNavBarTransparent:YES];

    self.textView.delegate = self;

    //Initializing Capsl object and its type
    self.createdCapsl = [Capsl object];
    self.createdCapsl.type = @"multimedia";

    //Setting CPSL sender
    [Capslr returnCapslrFromPFUser:[PFUser currentUser] withCompletion:^(Capslr *currentCapslr, NSError *error)
     {
        
         self.createdCapsl.sender = currentCapslr;
     }];

    self.view.backgroundColor = [UIColor colorWithPatternImage:[self getBackgroundImage]];

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

    [self.textView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.textView layoutIfNeeded];
    [self verticalCenterText];

    //If VC isEditing, it is trying to create a Capsl message
    if (self.isEditing)
    {
        self.exitButton.hidden = YES;
        self.navigationItem.leftBarButtonItem = self.cancelButton;
        self.navigationItem.rightBarButtonItem = self.doneButton;

        self.imageView.userInteractionEnabled = YES;
        self.textView.userInteractionEnabled = YES;

        [self processButton:self.enterTextButton withImageName:@"lowercase-50"];
        [self processButton:self.addPhotoButton withImageName:@"camera-50"];
        if (!self.audioData)
        {
            [self processButton:self.addAudioButton withImageName:kAddAudioButton];
        }
    }

    //If VC isEditing is NO, it is trying to unwrap and display a CPSL message
    else
    {

        self.enterTextButton.hidden = YES;
        self.addPhotoButton.hidden = YES;
        self.addAudioButton.hidden = NO;
        self.audioControlsContainerView.hidden = YES;

        self.imageView.userInteractionEnabled = NO;
        [self.view addSubview:self.textView];
        self.textView.editable = NO;
        self.exitButton.hidden = NO;
        [self processExitButton];


        //Get the audio data early -- show addAudio button which should be play button
        [self.chosenCapsl.audio getDataInBackgroundWithBlock:^(NSData *data, NSError *error)
         {
             if (!error)
             {
                 self.audioData = data;
                 [self processButton:self.addAudioButton withImageName:kAddAudioButton];
                 //                 if (self.chosenCapsl.photo)
                 //                 {
                 //                     [self setAddAudioToBottom];
                 //                 }
             }
             else
             {
                 NSLog(@"error for getting audio: %@", error.localizedDescription);
             }
         }];

        //Show textview, automatically defaults to center if there is no image
        if (self.chosenCapsl.text)
        {

            //TODO: trouble shoot vertical alignment for viewing capsules
            self.textView.text = self.chosenCapsl.text;
            [self.textView layoutIfNeeded];

            //            CGSize contentSize = self.textView.contentSize;
            //            contentSize.height = ceilf([self.textView sizeThatFits:self.textView.frame.size].height);
            //            self.textView.contentSize = contentSize;

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

#pragma mark Lock Orientation

- (BOOL) shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
}

# pragma mark - keyboard behavior

- (void)keyboardWillShow:(NSNotification *)notification
{
    if (self.isEditing)
    {
        //move the keyboard up by Keyboard height

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
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select image source" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

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

                                           [myAlertView setTintColor:kAlertControllerTintColor];
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

    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        [alert addAction:cameraButton];
    }
    [alert addAction:libraryButton];
    [alert addAction:cancelButton];

    [alert.view setTintColor:kAlertControllerTintColor];
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

#pragma mark Add Audio Related Method

- (IBAction)onAddAudioButtonPressed:(UIButton *)sender
{
    if (self.isEditing)
    {

        self.audioControlsContainerView.hidden = NO;

        self.audioControlsContainerView.alpha = 0.0;
        self.addAudioButton.alpha = 1.0;

        [UIView animateWithDuration:0.2 animations:^{
            self.audioControlsContainerView.alpha = 1.0;
            self.addAudioButton.alpha = 0.0;
        } completion:nil];

        self.addAudioButton.hidden = YES;

        self.recordAudioVC.createdCapsl = self.createdCapsl;
        self.recordAudioVC.audioData = self.audioData;
        [self.navigationController setNavigationBarHidden:YES animated:YES];

        self.addPhotoButton.userInteractionEnabled = NO;
        self.enterTextButton.userInteractionEnabled = NO;
        self.textView.userInteractionEnabled = NO;

    }

    //If not editing, pass audio data from chosenCapsl
    //TODO: DELETE THIS bc it seems unecessary but need to double check
    else
    {
        self.player = [[AVAudioPlayer alloc] initWithData:self.audioData fileTypeHint:@"m4a" error:nil];
        [self.player setDelegate:self];
        [self.player setVolume: 1.0];
        [self.player play];
    }
}

#pragma mark Segue and Next Button

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //If sender is Use Photo Button, pass info to next VC
    if ([segue.identifier isEqualToString:@"segueToContactSearch"])
    {
        UINavigationController *navVC = segue.destinationViewController;
        SearchContactViewController *searchContactVC = navVC.childViewControllers.firstObject;
        searchContactVC.createdCapsl = self.createdCapsl;

        if (self.chosenImage)
        {
            searchContactVC.backgroundImage = self.chosenImage;
        }
        else
        {
            searchContactVC.backgroundImage = self.wallpaperImage;
        }

    }

    //Passing whatever created to RecordAudioVC so audioVC can add audio files
    //Accessing it through the NavVC
    if ([segue.identifier isEqualToString:@"segueToAudio"])
    {
        self.recordAudioVC = segue.destinationViewController;
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
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No capsule created"
                                                                       message:@"Add a photo, record audio, or write a message"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okButton];

        [alert.view setTintColor:kAlertControllerTintColor];

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
    [self updateCharacterLengthLabel];

    [self shouldMoveViewUpForKeyboard:YES];

    [self verticalCenterText];

    self.enterTextButton.hidden = YES;

    self.addPhotoButton.userInteractionEnabled = NO;
    

}

-(void)textViewDidChange:(UITextView *)textView
{

    [self verticalCenterText];

    [self updateCharacterLengthLabel];
}

//Not called when isEditing is NO
- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.characterCountLabel.hidden = YES;
    if (self.textView.text && ![self.textView.text isEqualToString:@""])
    {
        self.createdCapsl.text = self.textView.text;
    }
    else
    {
        self.createdCapsl.text = nil;
    }

    [self resignFirstResponder];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [self verticalCenterText];

    //If text is empty, show text edit button again after editing is done
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
    if (self.isEditing)
    {

        if ([self.addAudioButton isHidden])
        {
            [self.recordAudioVC onDeleteRecordingButtonTapped:nil];
        }

        [self.textView resignFirstResponder];

    }

}

#pragma mark Text View Observer for center vert align

- (void)verticalCenterText
{

    CGFloat topoffset = ([self.textView bounds].size.height - [self.textView contentSize].height * [self.textView zoomScale])/2.0;
    NSLog(@"height %f", self.textView.bounds.size.height);
    NSLog(@"width %f", self.textView.bounds.size.width);
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

    [self.view removeConstraint:self.audioControlsCenterYConstraint];

    self.audioControlsContainerView.translatesAutoresizingMaskIntoConstraints = NO;

    self.audioControlsCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.audioControlsContainerView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:-kTextViewDistanceFromBottom / 2];
    [self.view addConstraint:self.audioControlsCenterYConstraint];


}

- (IBAction)unWindToCaptureSegue:(UIStoryboardSegue *)segue
{

    self.addAudioButton.hidden = NO;

    self.addAudioButton.alpha = 0.0;
    self.audioControlsContainerView.alpha = 1.0;

    [UIView animateWithDuration:0.2 animations:^{
        self.addAudioButton.alpha = 1.0;
        self.audioControlsContainerView.alpha = 0.0;
    } completion:nil];

    self.audioControlsContainerView.hidden = YES;

//    self.createdCapsl = self.recordAudioVC.createdCapsl;
    self.audioData = self.recordAudioVC.audioData;

    [self.navigationController setNavigationBarHidden:NO animated:YES];

    self.addPhotoButton.userInteractionEnabled = YES;
    self.enterTextButton.userInteractionEnabled = YES;
    self.textView.userInteractionEnabled = YES;

    [self updateAudioButton];

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

- (void)processExitButton
{

    UIImage *image = [[UIImage imageNamed:@"cancel-50"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.exitButton setImage:image forState:UIControlStateNormal];

    self.exitButton.tintColor = [UIColor whiteColor];
    self.exitButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.exitButton.layer.shadowOpacity = 0.3;
    self.exitButton.layer.shadowRadius = 1;
    self.exitButton.layer.shadowOffset = CGSizeMake(0, 1.5f);

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
    if (self.audioData)
    {
        [self.addAudioButton setImage:nil forState:UIControlStateNormal];
        [self.addAudioButton setTitle:@"AUDIO ADDED" forState:UIControlStateNormal];

        NSString *stringForButton = @"AUDIO ADDED";
        CGSize stringsize = [stringForButton sizeWithAttributes:@{
                                                                  NSFontAttributeName: [UIFont fontWithName:self.addAudioButton.titleLabel.font.fontName size:self.addAudioButton.titleLabel.font.pointSize]
                                                                  }];

        self.addAudioButtonWidthConstraint.constant = stringsize.width + 40;
    }

    if (self.audioData == nil)
    {
        //TODO:Button needs to change back for NO AUDIO
        [self.addAudioButton setTitle:@"" forState:UIControlStateNormal];
        [self processButton:self.addAudioButton withImageName:kAddAudioButton];

        self.addAudioButtonWidthConstraint.constant = 60;

    }

}

- (UIImage *)getBackgroundImage
{

    int imageNumber;

    if (self.isEditing)
    {
        imageNumber = arc4random_uniform(4) + 1;
        self.createdCapsl.wallpaperIndex = [NSNumber numberWithInt:imageNumber];

    }
    else
    {
        imageNumber = [self.chosenCapsl.wallpaperIndex intValue];
    }

    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"wallpaperTexture-%i", imageNumber]];
    self.wallpaperImage = image;

    return image;

}

- (void)updateCharacterLengthLabel
{
    NSInteger length = self.textView.text.length;
    self.characterCountLabel.text = [NSString stringWithFormat:@"%li / %i", kCharacterLimit - length, kCharacterLimit];
}


@end
