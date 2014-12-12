//
//  AddressContactViewController.m
//  Capsl
//
//  Created by CHRISTINA GUNARTO on 11/28/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "AddressContactViewController.h"
#import "Contact.h"
#import <MessageUI/MessageUI.h>
#import "SVProgressHUD.h"
#define kSMSInviteMessage @"Join CAPSL so I can send you a digital time capsule";

@interface AddressContactViewController () <UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property NSArray *contactsArray;

@end

@implementation AddressContactViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [Contact retrieveAllContactsWithBlock:^(NSArray *contacts)
     {
         self.contactsArray = [contacts mutableCopy];
         [self.tableView reloadData];
     }];
}

#pragma mark Table View Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contactsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

    Contact *c = self.contactsArray[indexPath.row];
    cell.textLabel.text = [c fullName];
    cell.detailTextLabel.text = c.number;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Contact *c = self.contactsArray[indexPath.row];
    [self showSMS:c];
}

#pragma mark Message Compose Methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            break;

        case MessageComposeResultFailed:
        {
            //Alert user if it fails
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Failed to send SMS!"
                                                                    preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:nil];
            [alert addAction:okButton];

            [alert.view setTintColor:kAlertControllerTintColor];

            [self presentViewController:alert
                               animated:YES
                             completion:nil];

            break;
        }

        case MessageComposeResultSent:
            break;

        default:
            break;
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showSMS:(Contact *)contact
{
    if(![MFMessageComposeViewController canSendText])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Your device doesn't support SMS!"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [alert addAction:okButton];

        [alert.view setTintColor:kAlertControllerTintColor];

        [self presentViewController:alert
                           animated:YES
                         completion:nil];

        return;
    }

    //Send invite message to friends who are not a CPSLR
    NSArray *recipents = @[contact.number];
    NSString *message = kSMSInviteMessage;

    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;

    [messageController setRecipients:recipents];
    [messageController setBody:message];

    // Present message view controller on screen
    [self presentViewController:messageController animated:YES completion:nil];
}


@end



