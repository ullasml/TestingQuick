//
//  ErrorDetailsViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 6/1/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "ErrorDetailsViewController.h"
#import "ErrorDetailsTableViewCell.h"
#import "Theme.h"
#import "ErrorDetailsDeserializer.h"
#import "ErrorDetailsStorage.h"
#import "Constants.h"
#import "ErrorDetails.h"
#import "Util.h"
#import "ErrorBannerViewController.h"
#import "SVPullToRefresh.h"
#import <KSDeferred/KSPromise.h>
#import "ErrorDetailsRepository.h"
#import "Constants.h"

#define ERROR_DETAILS_TABLEVIEW_SECTION_HEIGHT 32.0
static NSString *simpleTableIdentifier = @"ErrorDetailsTableViewCell";

@interface ErrorDetailsViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) NSNotificationCenter *notificationCenter;
@property (nonatomic) ErrorDetailsDeserializer *errorDetailsDeserializer;
@property (nonatomic) ErrorDetailsStorage *errorDetailsStorage;
@property (nonatomic) NSArray *tableRows;
@property (nonatomic) ErrorBannerViewController *errorBannerViewController;
@property (nonatomic) ErrorDetailsRepository *errorDetailsRepository;
@property (nonatomic) UILabel *msgLabel;
@end

@implementation ErrorDetailsViewController

- (instancetype)initWithTheme:(id <Theme>)theme
           notificationCenter:(NSNotificationCenter *)notificationCenter
     errorDetailsDeserializer:(ErrorDetailsDeserializer *)errorDetailsDeserializer
          errorDetailsStorage:(ErrorDetailsStorage *)errorDetailsStorage
    errorBannerViewController:(ErrorBannerViewController *)errorBannerViewController
       errorDetailsRepository:(ErrorDetailsRepository *)errorDetailsRepository
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.theme = theme;
        self.notificationCenter = notificationCenter;
        self.errorDetailsDeserializer = errorDetailsDeserializer;
        self.errorDetailsStorage = errorDetailsStorage;
        self.errorBannerViewController = errorBannerViewController;
        self.errorDetailsRepository = errorDetailsRepository;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = RPLocalizedString(@"Errors", @"");

    [self.tableView registerClass:[ErrorDetailsTableViewCell class] forCellReuseIdentifier:simpleTableIdentifier];
    UINib *inboxCellNib = [UINib nibWithNibName:@"ErrorDetailsTableViewCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:inboxCellNib forCellReuseIdentifier:simpleTableIdentifier];

    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    [self setupDataForTableView];


    self.view.backgroundColor = [self.theme errorDetailsBackgroundColor];
    self.tableView.backgroundColor = [self.theme errorDetailsBackgroundColor];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.errorBannerViewController hideErrorBanner];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.errorBannerViewController updateErrorBannerData];
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)setupDataForTableView
{
    self.tableRows = [self.errorDetailsStorage getAllErrorDetailsForModuleName:TIMESHEETS_TAB_MODULE_NAME];
    [self showMessageLabel];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableRows count]*2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row % 2 == 1)
    {
        ErrorDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[ErrorDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        }


        ErrorDetails *errorDetails = (ErrorDetails *)self.tableRows[indexPath.row / 2];

        cell.value.text = errorDetails.errorMessage;
        cell.value.backgroundColor = [UIColor clearColor];
        cell.value.textColor = [self.theme errorDetailsTextColor];
        cell.value.font = [self.theme errorDetailsFont];

        cell.layer.shadowColor = [[self.theme errorDetailsCellShadowColor] CGColor];
        cell.layer.shadowOffset = CGSizeMake(3, 3);
        cell.layer.shadowOpacity = 0.8;
        cell.layer.shadowRadius = 1.0;
        cell.layer.masksToBounds = NO;

        return cell;

    }

    else
    {
        static NSString *CellIdentifier2 = @"cellID2";
        UITableViewCell *cell2 = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell2 == nil) {
            cell2 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:CellIdentifier2];
        }
        cell2.backgroundColor = [UIColor clearColor];
        cell2.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell2;
    }


}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 1)
    {
      return YES;
    }
    else
    {
        return NO;
    }

}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [self deleteEntry:indexPath];
    }
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 1)
    {
        return UITableViewAutomaticDimension;
    }
    else
    {
        return 8.0;
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ERROR_DETAILS_TABLEVIEW_SECTION_HEIGHT;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(self.tableRows.count>0)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), ERROR_DETAILS_TABLEVIEW_SECTION_HEIGHT)];
        headerView.backgroundColor = [self.theme errorDetailsBackgroundColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(10, 4, CGRectGetWidth(self.tableView.bounds)-20.0, ERROR_DETAILS_TABLEVIEW_SECTION_HEIGHT)];
        if (self.tableRows.count==1)
        {
            label.text = RPLocalizedString(@"Timesheet Error", @"");
        }
        else
        {
            label.text = RPLocalizedString(@"Timesheet Errors", @"");
        }

        label.backgroundColor = [UIColor clearColor];
        label.textColor = [self.theme errorDetailsHeaderTextColor];
        label.font = [self.theme errorDetailsHeaderFont];
        [headerView addSubview:label];
        return headerView;
    }

    else
    {
        return nil;
    }

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellDeleteButtonText;
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:cellDeleteButtonText handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        [self deleteEntry:indexPath];
                                    }];
    button.backgroundColor = [self.theme errorBannerBackgroundColor];
    return @[button];
}


- (void)deleteEntry:(NSIndexPath*)indexPath
{
    ErrorDetails *errorDetails = (ErrorDetails *)self.tableRows[indexPath.row / 2];
    [self.errorDetailsStorage deleteErrorDetails:errorDetails.uri];
    [self setupDataForTableView];
}

-(void)showMessageLabel
{

    if ([self.tableRows count]>0)
    {
        [self.msgLabel removeFromSuperview];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:RPLocalizedString(dismissAllText, @"")
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(deleteAllErrors:)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
        [self.msgLabel removeFromSuperview];
        self.msgLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 120, CGRectGetWidth([[UIScreen mainScreen] bounds]), 80.0)];
        self.msgLabel.text=RPLocalizedString(noErrorsDisplayMsg, @"");
        self.msgLabel.backgroundColor=[UIColor clearColor];
        self.msgLabel.numberOfLines=3;
        self.msgLabel.textAlignment=NSTextAlignmentCenter;
        self.msgLabel.font=[UIFont fontWithName:RepliconFontFamily size:16];
        [self.view addSubview:self.msgLabel];
    }
}

-(IBAction)deleteAllErrors:(id)sender
{
    [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"No", @"No")
                                   otherButtonTitle:RPLocalizedString(@"Yes", @"Yes")
                                           delegate:self
                                            message:RPLocalizedString(DeleteAllErrorsMessage,nil)
                                              title:nil
                                                tag:LONG_MIN];


}

#pragma mark - <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self.errorDetailsStorage deleteAllErrorDetails];
        [self setupDataForTableView];
    }
}


@end
