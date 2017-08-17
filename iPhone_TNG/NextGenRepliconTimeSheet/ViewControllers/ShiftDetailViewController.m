//
//  ShiftDetailViewController.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 27/02/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "ShiftDetailViewController.h"
#import "ImageNameConstants.h"
#import "Constants.h"
#import "ShiftsModel.h"
#import <Blindside/BSInjector.h>

#define Total_Hours_Footer_Height_28 28
#define DaySelectionScrollViewHeight 50
#define SectionHeaderHeight 20

@interface ShiftDetailViewController()

@property (nonatomic,strong) NSMutableArray <ShiftItemsSectionPresenter *> *shiftPresenters;


@end

@implementation ShiftDetailViewController
@synthesize headerDateString;
@synthesize obj_ShiftsModel;
@synthesize shiftDetailTableView;

-(instancetype)initWithPresenter:(ShiftDetailsPresenter *)shiftDetailsPresenter {
    self = [super init];
    if(self) {
        _shiftDetailsPresenter = shiftDetailsPresenter;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    UIView *datelabelView = [[UIView alloc]initWithFrame:CGRectMake(0, DaySelectionScrollViewHeight, self.view.frame.size.width, Total_Hours_Footer_Height_28)] ;
    datelabelView.backgroundColor = [Util colorWithHex:@"#EEEEEE" alpha:1.0f];

    UILabel *totalLabel=[[UILabel alloc]initWithFrame:CGRectMake(10.0, 4,self.view.frame.size.width ,20.0)];
    [totalLabel setText:headerDateString];
    [totalLabel setTextColor:[Util colorWithHex:@"#333333" alpha:1.0]];
    [totalLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_14]];
    [datelabelView addSubview:totalLabel];
    [self.view addSubview:datelabelView];

    CGFloat tableView_offset_y = datelabelView.frame.origin.y + Total_Hours_Footer_Height_28;
    self.shiftDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, tableView_offset_y, SCREEN_WIDTH, [self heightForTableView]) style:UITableViewStyleGrouped];
    self.shiftDetailTableView.backgroundColor = RepliconStandardBackgroundColor;
    self.shiftDetailTableView.delegate = self;
    self.shiftDetailTableView.dataSource = self;
    self.shiftDetailTableView.rowHeight = UITableViewAutomaticDimension;
    self.shiftDetailTableView.estimatedRowHeight = 80;
    self.shiftDetailTableView.sectionHeaderHeight = 0.0;
     self.shiftDetailTableView.sectionFooterHeight = 0.0;
    self.shiftDetailTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.shiftDetailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self registerCellsForTableView];
    
    self.shiftPresenters = [NSMutableArray array];

 

    [self.view addSubview: self.shiftDetailTableView];

    obj_ShiftsModel =  [[ ShiftsModel alloc] init];
}

- (void) registerCellsForTableView {
    [ShiftScheduleCell registerWithTableView:self.shiftDetailTableView];
    [ShiftDetailCell registerWithTableView:self.shiftDetailTableView];
    [ShiftScheduleTimeOffCell registerWithTableView:self.shiftDetailTableView];
    [ShiftScheduleHolidayCell registerWithTableView:self.shiftDetailTableView];
}


#pragma mark - Header sections

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.shiftPresenters.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SectionHeaderHeight;
}

- (UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *sectionView = [[UIView alloc] init];
    sectionView.backgroundColor = [UIColor clearColor];
    return sectionView;
    
}

#pragma mark - Table view cells
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < self.shiftPresenters.count ){
        ShiftItemsSectionPresenter *sectionPresenter = [self.shiftPresenters objectAtIndex:section];
        return sectionPresenter.shiftItemPresenters.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= self.shiftPresenters.count ) {
        return [[UITableViewCell alloc] init];
    }
    
    ShiftItemsSectionPresenter *sectionPresenter = [self.shiftPresenters objectAtIndex:indexPath.section];
    if( indexPath.row >= sectionPresenter.shiftItemPresenters.count){
        return [[UITableViewCell alloc] init];
    }
    
    ShiftItemPresenter *shiftItemPresenter = [sectionPresenter.shiftItemPresenters objectAtIndex:indexPath.row];
    
    NSString *cellIdentifier = shiftItemPresenter.cellReuseIdentifier;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    if([cell isKindOfClass: [BaseShiftCell class]]) {
        BaseShiftCell *shiftCell = (BaseShiftCell *)cell;
        [shiftCell updateWithShiftItemPresenter:shiftItemPresenter];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark -
#pragma mark - Other Methods

-(void)getDataFromDB :(double)timeStamp
{
   
    NSMutableArray *shiftDetailArray = [obj_ShiftsModel getShiftDetailsFromDBForDate:timeStamp];
    [self.shiftPresenters removeAllObjects];
    
    if (shiftDetailArray!= Nil) {
        for (int index= 0; index<[shiftDetailArray count]; index++) {
            if ([[shiftDetailArray objectAtIndex:index] isKindOfClass:[NSDictionary class]]) {
                NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
                tempDict = [shiftDetailArray objectAtIndex:index];
                if ([shiftDetailArray count] == 0)
                    [shiftDetailArray addObject:NO_SHIFT];


            }//Implemtation for Sched-114//ObjectExtensionField//JUHI
            if ([[shiftDetailArray objectAtIndex:index] isKindOfClass:[NSArray class]])
            {
                NSMutableArray *detailArray=[NSMutableArray arrayWithArray:[shiftDetailArray objectAtIndex:index]];
                NSString *shiftUri=[[detailArray objectAtIndex:0] objectForKey:@"shiftUri"];

                NSArray *udfArray=[obj_ShiftsModel getAllShiftObjectExtensionFieldsForShiftUri:shiftUri forTimeStamp:timeStamp forIndex:[[detailArray objectAtIndex:0] objectForKey:@"shiftIndex"]];
                if ([udfArray count]>0)
                {
                    for (int i=0; i<[udfArray count];i++)
                    {
                        NSMutableDictionary *dataDict=[NSMutableDictionary dictionaryWithDictionary:[udfArray objectAtIndex:i]];
                        [dataDict setObject:@"UDF" forKey:@"type"];
                        [detailArray addObject:dataDict];
                    }
                    [shiftDetailArray replaceObjectAtIndex:index withObject:detailArray];
                }
            }
        }

  
        if( self.shiftDetailsPresenter ) {
            NSArray *presenters = [self.shiftDetailsPresenter shiftSectionItemPresentersForShiftDetailsList: shiftDetailArray];
            self.shiftPresenters = [NSMutableArray arrayWithArray: presenters];
        }
        
        shiftDetailTableView.hidden = NO;
        [self.shiftDetailTableView reloadData];
    }
}

#pragma mark - Frame math

- (CGFloat)heightForTableView
{
    return CGRectGetHeight(self.view.bounds) -
    (CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]) +
     CGRectGetHeight(self.navigationController.navigationBar.frame) +
     CGRectGetHeight(self.tabBarController.tabBar.frame) +
     Total_Hours_Footer_Height_28 +
     DaySelectionScrollViewHeight + 92);
}

#pragma mark - NSObject

- (void)dealloc
{
    self.shiftDetailTableView.dataSource = nil;
    self.shiftDetailTableView.delegate = nil;
}

@end
