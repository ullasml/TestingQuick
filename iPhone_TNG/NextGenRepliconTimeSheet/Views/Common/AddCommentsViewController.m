//
//  AddCommentsViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 19/02/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "AddCommentsViewController.h"
#import "Constants.h"
#import "DayTimeEntryViewController.h"
#import "DayTimeEntryCustomCell.h"
#import "MultiDayInOutViewController.h"

@implementation AddCommentsViewController
@synthesize descTextView;
@synthesize delegate;
@synthesize tableDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)loadView
{
	[super loadView];
	if (descTextView == nil) {
		GCPlaceholderTextView *tempdescTextView = [[GCPlaceholderTextView alloc] init];
        self.descTextView=tempdescTextView;

	}
    self.descTextView.placeholderColor = [UIColor lightGrayColor];
    if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        DayTimeEntryViewController *currentTimesheetCtrl=(DayTimeEntryViewController *)delegate;
         TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[currentTimesheetCtrl.timesheetEntryObjectArray objectAtIndex:currentTimesheetCtrl.currentIndexpath.row];
        if (![currentTimesheetCtrl.standardTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ] && ![currentTimesheetCtrl.standardTimesheetStatus isEqualToString:APPROVED_STATUS ] && ![tsEntryObject.entryType isEqualToString:Time_Off_Key])
        {
            self.descTextView.placeholder = RPLocalizedString(@"Please enter your comments here.",);
        }
    }
    else if ([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)delegate;
        TimesheetEntryObject *tsEntryObject=(TimesheetEntryObject *)[currentTimesheetCtrl.timesheetEntryObjectArray objectAtIndex:currentTimesheetCtrl.currentIndexpath.row];
        if (![currentTimesheetCtrl.multiDayTimesheetStatus isEqualToString:WAITING_FOR_APRROVAL_STATUS ] && ![currentTimesheetCtrl.multiDayTimesheetStatus isEqualToString:APPROVED_STATUS ] && ![tsEntryObject.entryType isEqualToString:Time_Off_Key])
        {
            self.descTextView.placeholder = RPLocalizedString(@"Please enter your comments here.",);
        }
    }

    [self.descTextView setFrame:CGRectMake(0, 0, 295, self.view.frame.size.height)];
	self.descTextView.textColor = RepliconStandardBlackColor;
	self.descTextView.scrollEnabled = YES;
    self.descTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	[self.descTextView setShowsVerticalScrollIndicator:YES];
	[self.descTextView setShowsHorizontalScrollIndicator:NO];
    [self.descTextView setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
	self.descTextView.font = [UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15];
	self.descTextView.delegate = self;
	self.descTextView.returnKeyType = UIReturnKeyDefault;
	self.descTextView.keyboardType = UIKeyboardTypeASCIICapable;
	self.descTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.descTextView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview: self.descTextView];
    [self.view bringSubviewToFront:self.descTextView];

}
- (void)textViewDidBeginEditing:(UITextView *)textView
{

    if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        DayTimeEntryViewController *currentTimesheetCtrl=(DayTimeEntryViewController *)delegate;

        [currentTimesheetCtrl setIsTextFieldClicked:YES];
        [currentTimesheetCtrl setIsUDFieldClicked:NO];
        [currentTimesheetCtrl resetTableSize:YES];
        [[currentTimesheetCtrl timeEntryTableView] scrollToRowAtIndexPath:[currentTimesheetCtrl currentIndexpath] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        CGRect screenRect =[[UIScreen mainScreen] bounds];
        float aspectRatio=(screenRect.size.height/screenRect.size.width);

        if (aspectRatio<1.7)
        {
            CGPoint contentoffset=[currentTimesheetCtrl timeEntryTableView].contentOffset;
            contentoffset.y=contentoffset.y+30.0+28.0;
            [currentTimesheetCtrl timeEntryTableView].contentOffset=contentoffset;
        }

        [[currentTimesheetCtrl timeEntryTableView] setScrollEnabled:NO];


    }
    else if([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)delegate;

        [currentTimesheetCtrl handleButtonClick:[currentTimesheetCtrl selectedIndexPath]];
        [currentTimesheetCtrl setIsTextFieldClicked:YES];
        [currentTimesheetCtrl setIsUDFieldClicked:NO];
        [currentTimesheetCtrl resetTableSize:YES isTextFieldOrTextViewClicked:YES isUdfClicked:NO];
        [[currentTimesheetCtrl multiDayTimeEntryTableView] scrollToRowAtIndexPath:[currentTimesheetCtrl currentIndexpath] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        CGRect screenRect =[[UIScreen mainScreen] bounds];
        float aspectRatio=(screenRect.size.height/screenRect.size.width);

        if (aspectRatio<1.7)
        {
            CGPoint contentoffset=[currentTimesheetCtrl multiDayTimeEntryTableView].contentOffset;
            contentoffset.y=contentoffset.y+30.0+28.0;
            [currentTimesheetCtrl multiDayTimeEntryTableView].contentOffset=contentoffset;
        }

        [[currentTimesheetCtrl multiDayTimeEntryTableView] setScrollEnabled:NO];
    }

}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        NSRange range = NSMakeRange(0,1);
        [textView scrollRangeToVisible:range];
        DayTimeEntryViewController *currentTimesheetCtrl=(DayTimeEntryViewController *)delegate;
        //[currentTimesheetCtrl updateTimeEntryCommentsForIndex:textView.tag withValue:textView.text];
        [currentTimesheetCtrl doneAction:YES sender:nil];
    }
    else if([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        NSRange range = NSMakeRange(0,1);
        [textView scrollRangeToVisible:range];
        MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)delegate;
        [currentTimesheetCtrl updateTimeEntryCommentsForIndex:textView.tag withValue:textView.text];
        [currentTimesheetCtrl doneAction:YES sender:nil];
    }

}
- (void)textViewDidChange:(UITextView *)textView
{
    if([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
        MultiDayInOutViewController *currentTimesheetCtrl=(MultiDayInOutViewController *)delegate;
        [currentTimesheetCtrl updateTimeEntryCommentsForIndex:textView.tag withValue:textView.text];
    }
    else if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        //DayTimeEntryViewController *currentTimesheetCtrl=(DayTimeEntryViewController *)delegate;
        //[currentTimesheetCtrl updateTimeEntryCommentsForIndex:textView.tag withValue:textView.text];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}
-(BOOL)textViewShouldReturn:(UITextView *)textView
{

    [textView resignFirstResponder];
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([delegate isKindOfClass:[DayTimeEntryViewController class]])
    {
        [delegate setLastUsedTextField:textView];
    }
    else if([delegate isKindOfClass:[MultiDayInOutViewController class]])
    {
                [delegate setLastUsedTextField:textView];
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    self.descTextView=nil;
}




@end
