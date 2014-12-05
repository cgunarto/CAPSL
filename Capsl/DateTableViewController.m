//
//  DateTableViewController.m
//  DateCellTest
//
//  Created by CHRISTINA GUNARTO on 12/3/14.
//  Copyright (c) 2014 Christina Gunarto. All rights reserved.
//

#import "DateTableViewController.h"
#import "PickerTableViewCell.h"
#import "PromptDateTableViewCell.h"
#import "Capsl.h"

#define kPickerAnimationDuration    3   // duration for the animation to slide the date picker into view
#define kDatePickerTag              99     // view tag identifiying the date picker view

#define kTitleKey       @"title"   // key for obtaining the data source item's title
#define kDateKey        @"date"    // key for obtaining the data source item's date value
#define kTimeKey        @"time"   // key for obtaining the data source item's date value


// keep track of which rows have date cells
#define kDateRow   0
#define kTimeRow   1

static NSString *kDateCellID = @"dateCell";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker

@interface DateTableViewController ()

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;

@property (assign) NSInteger pickerCellRowHeight;

@property (nonatomic, strong) IBOutlet UIDatePicker *pickerView;

// this button appears only when the date picker is shown (iOS 6.1.x or earlier)
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end

@implementation DateTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // setup our data source - what gets populated in the table view cell array

    NSMutableDictionary *itemOne = [@{ kTitleKey : @"Send Date",
                                       kDateKey : [NSDate date] } mutableCopy];

    NSMutableDictionary *itemTwo = [@{ kTitleKey : @"Send Time",
                                         kTimeKey : [NSDate date] } mutableCopy];

    NSMutableDictionary *itemThree = [@{ kTitleKey : @""} mutableCopy];

    self.dataArray = @[itemOne, itemTwo, itemThree];

    self.dateFormatter = [[NSDateFormatter alloc] init];

    // obtain the picker view cell's height, works because the cell was pre-defined in our storyboard
    PickerTableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kDatePickerID]; //datePickerCell
    self.pickerCellRowHeight = CGRectGetHeight(pickerViewCellToCheck.frame);

    // if the local changes while in the background, we need to be notified so we can update the date
    // format in the table view cells
    //
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeChanged:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSCurrentLocaleDidChangeNotification
                                                  object:nil];
}

#pragma mark - Locale

/*! Responds to region format or locale changes.
 */
- (void)localeChanged:(NSNotification *)notif
{
    // the user changed the locale (region format) in Settings, so we are notified here to
    // update the date format in the table view cells
    //
    [self.tableView reloadData];
}


#pragma mark - Utilities

/*! Returns the major version of iOS, (i.e. for iOS 6.1.3 it returns 6)
 */
NSUInteger DeviceSystemMajorVersion()
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        _deviceSystemMajorVersion =
        [[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] integerValue];
    });

    return _deviceSystemMajorVersion;
}

#define EMBEDDED_DATE_PICKER (DeviceSystemMajorVersion() >= 7)

/*!

 @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
 */
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;

    NSInteger targetedRow = indexPath.row;
    targetedRow++;

    PromptDateTableViewCell *checkDatePickerCell =
    (PromptDateTableViewCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];

    UIDatePicker *checkDatePicker = (UIDatePicker *)[checkDatePickerCell viewWithTag:kDatePickerTag];

    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

/*! Updates the UIDatePicker's value to match with the date of the cell above it.
 */
- (void)updateDatePicker
{
    if (self.datePickerIndexPath != nil)
    {
        PickerTableViewCell *associatedDatePickerCell = (PickerTableViewCell *)[self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];

        UIDatePicker *targetedDatePicker = associatedDatePickerCell.datePicker;
        if (targetedDatePicker != nil)
        {
            // we found a UIDatePicker in this cell, so update it's date value
            //
            NSDictionary *itemData = self.dataArray[self.datePickerIndexPath.row - 1];

            //if it's kDateKey - change it to UIDatePickerModeDate
            if ([itemData valueForKey:kDateKey])
            {
                targetedDatePicker.datePickerMode = UIDatePickerModeDate;
                [targetedDatePicker setDate:[itemData valueForKey:kDateKey] animated:YES];
            }

            //if it's kTimeKey - change it to UIDatePickerModeTime
            if ([itemData valueForKey:kTimeKey])
            {
                targetedDatePicker.datePickerMode = UIDatePickerModeTime;
                [targetedDatePicker setDate:[itemData valueForKey:kTimeKey] animated:YES];
            }
        }
    }
}

/*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
 */
- (BOOL)hasInlineDatePicker
{
    return (self.datePickerIndexPath != nil);
}

/*! Determines if the given indexPath points to a cell that contains the UIDatePicker.

 @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlineDatePicker] && self.datePickerIndexPath.row == indexPath.row);
}

/*! Determines if the given indexPath points to a cell that contains the start/end dates.

 @param indexPath The indexPath to check if it represents start/end date cell.
 */
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath
{
    BOOL hasDate = NO;

    if ((indexPath.row == kDateRow) ||
        (indexPath.row == kTimeRow || ([self hasInlineDatePicker] && (indexPath.row == kTimeRow + 1) ) ))
    {
        hasDate = YES;
    }

    return hasDate;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self indexPathHasPicker:indexPath])
    {
    #warning need to check
        return 216; //self.pickerCellRowHeight;
    }

    else
    {
        return 100;
    }

//    return ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self hasInlineDatePicker])
    {
        // we have a date picker, so allow for it in the number of rows in this section
        NSInteger numRows = self.dataArray.count;
        return ++numRows;
    }

    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PromptDateTableViewCell *cell = nil;

    NSString *cellID = kDateCellID;

    if ([self indexPathHasPicker:indexPath])
    {
        // the indexPath is the one containing the inline date picker
        cellID = kDatePickerID;     // the current/opened date picker cell
    }
    else if ([self indexPathHasDate:indexPath])
    {
        // the indexPath is one that contains the date information
        cellID = kDateCellID;       // the start/end date cells
    }

    cell = [tableView dequeueReusableCellWithIdentifier:cellID];

    if (indexPath.row == 0)
    {
        // we decide here that first cell in the table is not selectable (it's just an indicator)
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    // if we have a date picker open whose cell is above the cell we want to update,
    // then we have one more cell than the model allows
    //
    NSInteger modelRow = indexPath.row;
    if (self.datePickerIndexPath != nil && self.datePickerIndexPath.row <= indexPath.row)
    {
        modelRow--;
    }

    NSDictionary *itemData = self.dataArray[modelRow];

    // proceed to configure our cell
    if ([cellID isEqualToString:kDateCellID])
    {
        // we have either start or end date cells, populate their date field
        //TODO: CHANGE THIS LABEL VALUE
        cell.textLabel.text = [itemData valueForKey:kTitleKey];

        if ([itemData valueForKey:kDateKey])
        {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateStyle:NSDateFormatterLongStyle];
            cell.dateLabel.text = [dateFormat stringFromDate:[itemData valueForKey:kDateKey]];
        }

        if ([itemData valueForKey:kTimeKey])
        {
            NSDateFormatter *timeFormat = [[NSDateFormatter alloc] init];
            [timeFormat setTimeStyle:NSDateFormatterShortStyle];
            cell.dateLabel.text = [timeFormat stringFromDate:[itemData valueForKey:kTimeKey]];
        }


    }

    return cell;
}

/*! Adds or removes a UIDatePicker cell below the given indexPath.

 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];

    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];

    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath])
    {
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }

    [self.tableView endUpdates];
}

- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the date picker inline with the table content
    [self.tableView beginUpdates];

    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    if ([self hasInlineDatePicker])
    {
        before = self.datePickerIndexPath.row < indexPath.row;
    }

    BOOL sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);

    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker])
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
    }

    if (!sameCellClicked)
    {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];

        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
    }

    // always deselect the row containing the start or end date
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self.tableView endUpdates];

    // inform our date picker of the current date to match the current cell
    [self updateDatePicker];
}

/*! Reveals the UIDatePicker as an external slide-in view, iOS 6.1.x and earlier, called by "didSelectRowAtIndexPath".

 @param indexPath The indexPath used to display the UIDatePicker.
 */
- (void)displayExternalDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // first update the date picker's date value according to our model
    NSDictionary *itemData = self.dataArray[indexPath.row];
    [self.pickerView setDate:[itemData valueForKey:kDateKey] animated:YES];

    // the date picker might already be showing, so don't add it to our view
    if (self.pickerView.superview == nil)
    {
        CGRect startFrame = self.pickerView.frame;
        CGRect endFrame = self.pickerView.frame;

        // the start position is below the bottom of the visible frame
        startFrame.origin.y = CGRectGetHeight(self.view.frame);

        // the end position is slid up by the height of the view
        endFrame.origin.y = startFrame.origin.y - CGRectGetHeight(endFrame);

        self.pickerView.frame = startFrame;

        [self.view addSubview:self.pickerView];

        // animate the date picker into view
        [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.pickerView.frame = endFrame; }
                         completion:^(BOOL finished) {
                             // add the "Done" button to the nav bar
                             self.navigationItem.rightBarButtonItem = self.doneButton;
                         }];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PromptDateTableViewCell *cell = (PromptDateTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == kDateCellID)
    {
        if (EMBEDDED_DATE_PICKER)
            [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        else
            [self displayExternalDatePickerForRowAtIndexPath:indexPath];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Actions

/*! User chose to change the date by changing the values inside the UIDatePicker.

 @param sender The sender for this action: UIDatePicker.
 */
- (IBAction)dateAction:(id)sender
{
    NSIndexPath *targetedCellIndexPath = nil;

    if ([self hasInlineDatePicker])
    {
        // inline date picker: update the cell's date "above" the date picker cell
        //
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    }
    else
    {
        // external date picker: update the current "selected" cell's date
        targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
    }

    PromptDateTableViewCell *cell = (PromptDateTableViewCell*)[self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    UIDatePicker *targetedDatePicker = sender;

    // update our data model
    NSMutableDictionary *itemData = self.dataArray[targetedCellIndexPath.row];

    // if it's the Date DatePicker, change the kTimeKey NSDate as well
    if ([itemData valueForKey:kDateKey])
    {
        [itemData setValue:targetedDatePicker.date forKey:kDateKey];
        NSMutableDictionary *timeItemData = self.dataArray[targetedCellIndexPath.row + 1];
        [timeItemData setValue:targetedDatePicker.date forKey:kTimeKey];

        NSLog(@"DATE %@ TIME %@", itemData[kDateKey], timeItemData[kTimeKey]);

        //TODO:SET CREATEDCPSL DATE HERE

        [self.tableView reloadData];
    }

    if ([itemData valueForKey:kTimeKey])
    {
        [itemData setValue:targetedDatePicker.date forKey:kTimeKey];
        NSMutableDictionary *dateItemData = self.dataArray[targetedCellIndexPath.row - 1];
        [dateItemData setValue:targetedDatePicker.date forKey:kDateKey];

        NSLog(@"DATE %@ TIME %@", dateItemData[kDateKey], itemData[kTimeKey]);
        [self.tableView reloadData];

        //TODO:SET CREATEDCPSL DATE HERE
    }

    // update the cell's date string
    cell.dateLabel.text = [self.dateFormatter stringFromDate:targetedDatePicker.date];
}

/*! User chose to finish using the UIDatePicker by pressing the "Done" button
 (used only for "non-inline" date picker, iOS 6.1.x or earlier)

 @param sender The sender for this action: The "Done" UIBarButtonItem
 */
- (IBAction)doneAction:(id)sender
{
    CGRect pickerFrame = self.pickerView.frame;
    pickerFrame.origin.y = CGRectGetHeight(self.view.frame);

    // animate the date picker out of view
    [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.pickerView.frame = pickerFrame; }
                     completion:^(BOOL finished) {
                         [self.pickerView removeFromSuperview];
                     }];

    // remove the "Done" button in the navigation bar
    self.navigationItem.rightBarButtonItem = nil;

    // deselect the current table cell
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
