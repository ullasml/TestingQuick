//
//  AuditTrialUsersViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 08/07/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "AuditTrialUsersViewController.h"
#import "ImageNameConstants.h"
#import "Constants.h"
#import "RepliconServiceManager.h"
#import "FrameworkImport.h"
#import "UIView+Additions.h"

@interface AuditTrialUsersViewController ()

@end

@implementation AuditTrialUsersViewController
@synthesize auditTrialInfoTableView;
@synthesize listDataArray;
@synthesize dateString;
@synthesize dateDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:RepliconStandardBackgroundColor];
    [Util setToolbarLabel: self withText: RPLocalizedString(AuditTrialTitle, AuditTrialTitle)];
    UIBarButtonItem *tempLeftButtonOuterBtn = [[UIBarButtonItem alloc]initWithTitle:RPLocalizedString(CANCEL_STRING,@"")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(cancelAction:)];
    [self.navigationItem setLeftBarButtonItem:tempLeftButtonOuterBtn animated:NO];
    
    
    UITableView *tempAuditTrialTableView=[[UITableView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width, self.view.height) style:UITableViewStylePlain];
    
    self.auditTrialInfoTableView=tempAuditTrialTableView;
    self.auditTrialInfoTableView.separatorColor=[UIColor clearColor];
    self.auditTrialInfoTableView.backgroundColor = [UIColor clearColor];
    [self.auditTrialInfoTableView setDelegate:self];
    [self.auditTrialInfoTableView setDataSource:self];
    self.auditTrialInfoTableView.separatorColor=[Util colorWithHex:@"#cccccc" alpha:1];
    [self.view addSubview:self.auditTrialInfoTableView];
    UIView *bckView = [UIView new];
    [bckView setBackgroundColor:RepliconStandardBackgroundColor];
    [self.auditTrialInfoTableView setBackgroundView:bckView];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect frame =  self.view.frame;
    self.auditTrialInfoTableView.frame = frame;
}

-(void)cancelAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark TableView Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return  [self.listDataArray count];
	
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
	static NSString *CellIdentifier = @"Cell";
	cell  = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil)
    {
		cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil] ;
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.textLabel.text=[[self.listDataArray objectAtIndex:indexPath.row] objectForKey:@"punchUserName"];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strUserURI=[[self.listDataArray objectAtIndex:indexPath.row] objectForKey:@"punchUserUri"];
    NSString *userName=[[self.listDataArray objectAtIndex:indexPath.row] objectForKey:@"punchUserName"];
    
    if (![NetworkMonitor isNetworkAvailableForListener:self])
    {
        [Util showOfflineAlert];
        return;
    }
    
    [[[UIApplication sharedApplication] delegate] performSelector:@selector(showTransparentLoadingOverlay) withObject:nil];
   
    AuditTrialViewController *auditTrialVC=[[AuditTrialViewController alloc]init];
    auditTrialVC.headerDateString=dateString;
    auditTrialVC.userName=userName;
    auditTrialVC.isFromTeamTime=YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AUDIT_TRIAL_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:auditTrialVC selector:@selector(auditTrialDataReceivedAction:)
                                                 name:AUDIT_TRIAL_NOTIFICATION
                                               object:nil];
    [[RepliconServiceManager teamTimeService]sendRequestToGetAuditTrialDataForUserUri:strUserURI andDate:dateDict];
    [self.navigationController pushViewController:auditTrialVC animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)dealloc
{
    self.auditTrialInfoTableView.delegate = nil;
    self.auditTrialInfoTableView.dataSource = nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
