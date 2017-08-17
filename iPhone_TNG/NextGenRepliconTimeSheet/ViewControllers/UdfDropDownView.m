//
//  UdfDropDownView.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 25/01/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "UdfDropDownView.h"
#import "Constants.h"
#import "DropDownOption.h"
#import "SVPullToRefresh.h"
#import "AppProperties.h"
#import "DropDownOption.h"
#import "UdfObject.h"
#import "TimesheetListObject.h"
#define Yoffset 35
@interface UdfDropDownView ()
@property(nonatomic,strong)NSMutableArray *dropDownOptionList;
@property(nonatomic,strong)NSMutableArray *arrayOfCharacters;
@property(nonatomic,strong)NSMutableDictionary *objectsForCharacters;
@property(nonatomic,strong)UdfObject *UdfObject;
@property(nonatomic,strong)TimesheetListObject *timesheetListObject;
@end

@implementation UdfDropDownView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = RepliconStandardBackgroundColor;
        //self.separatorStyle=UITableViewCellSeparatorStyleNone; 
        [self setDelegate:self];
        [self setDataSource:self];
        [self _configureTableForPullToRefresh];
    }
    return self;
}

-(void)setUpDropDownViewWithDropdownArray:(NSMutableArray *)dropDownOptionList withArrayOfCharacters:(NSMutableArray *)arrayOfCharacters withObjectsForCharacters:(NSMutableDictionary *)objectsForCharacters withUdfObject:(UdfObject *)udfObject withTimesheetListObject:(TimesheetListObject *)timesheetListObject{
    [self setUdfObject:udfObject];
    [self setTimesheetListObject:timesheetListObject];
    [self setDropDownOptionList:dropDownOptionList];
    [self setArrayOfCharacters:arrayOfCharacters];
    [self setObjectsForCharacters:objectsForCharacters];
    [self reloadData];
    [self _checkToShowMoreButton];
}

#pragma mark Pull To Refresh/ More action
/************************************************************************************************************
 @Function Name   : configure_TableFor_PullToRefresh
 @Purpose         : To extend tableview to add pull to refresh and infinite scrolling capabilities
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

-(void)_configureTableForPullToRefresh
{
    UdfDropDownView *weakSelf = self;
    //setup pull to refresh widget
    [self addPullToRefreshWithActionHandler:^{
        
        int64_t delayInSeconds = 0.0;
        [weakSelf.pullToRefreshView startAnimating];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           [weakSelf _refreshAction];
                       });
    }];
    
    // setup infinite scrolling
    [self addInfiniteScrollingWithActionHandler:^{
        if ([weakSelf.arrayOfCharacters count]>0) {
            [weakSelf setBottomContentInsetValue: 60.0];
            NSUInteger sectionCount=[weakSelf.arrayOfCharacters count];
            NSUInteger rowCount=[[weakSelf.objectsForCharacters objectForKey:[weakSelf.arrayOfCharacters objectAtIndex:sectionCount-1]] count];
            NSIndexPath* ipath = [NSIndexPath indexPathForRow: rowCount-1 inSection: sectionCount-1];
            [weakSelf scrollToRowAtIndexPath: ipath atScrollPosition: UITableViewScrollPositionBottom animated: YES];
            int64_t delayInSeconds = 0.0;
            [weakSelf.infiniteScrollingView startAnimating];
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                           {
                               [weakSelf _moreAction];
                           });
        }
        else
            [weakSelf.infiniteScrollingView stopAnimating];
    }];
    
}



/************************************************************************************************************
 @Function Name   : more_Action
 @Purpose         : To fetch more records of timesheet when tableview is scrolled to bottom
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

- (void)_moreAction {
    if ([self.udfDropDownNavigationDelegate respondsToSelector:@selector(udfDropDownView:moreAction:)]) {
        [self.udfDropDownNavigationDelegate udfDropDownView:self moreAction:self];
    }
}

/************************************************************************************************************
 @Function Name   : refresh_Action
 @Purpose         : To fetch modified records of timesheet when tableview is pulled to refresh
 @param           : nil
 @return          : nil
 *************************************************************************************************************/

- (void)_refreshAction {
    if ([self.udfDropDownNavigationDelegate respondsToSelector:@selector(udfDropDownView:refreshAction:)]) {
        [self.udfDropDownNavigationDelegate udfDropDownView:self refreshAction:self];
    }
}

-(void)_checkToShowMoreButton
{
    NSNumber *count=[[NSUserDefaults standardUserDefaults]objectForKey:@"dropDownOptionDataDownloadCount"];
    NSNumber *fetchCount=[[AppProperties getInstance] getAppPropertyFor:@"dropDownOptionDownloadCount"];
    if (([count intValue]<[fetchCount intValue]))
        self.showsInfiniteScrolling=FALSE;
    else
        self.showsInfiniteScrolling=TRUE;
    
    if ([self.dropDownOptionList count]==0)
        self.showsInfiniteScrolling=FALSE;
    else
        self.showsPullToRefresh=TRUE;
    
}


#pragma mark - UITableView methods
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)tableViewcell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableViewcell setBackgroundColor:RepliconStandardBackgroundColor];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    NSUInteger count= [self.arrayOfCharacters count];
    if (count<1)
    {
        return 1;
    }
    return [self.arrayOfCharacters count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger count= [self.arrayOfCharacters count];
    if (count<1)
    {
        return 1;
    }
    return  [[self.objectsForCharacters objectForKey:[self.arrayOfCharacters objectAtIndex:section]] count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name=@"";
    NSUInteger count= [self.arrayOfCharacters count];
    
    if (count>0)
    {
        if([self.arrayOfCharacters count] > 0 && [self.arrayOfCharacters count] > indexPath.section){
            //within the array boundary
            NSString *key = [self.arrayOfCharacters objectAtIndex:indexPath.section];
            NSMutableArray *tempArray = [self.objectsForCharacters objectForKey:key];
            if([tempArray count] > 0 && [tempArray count] > indexPath.row){
                name=[[tempArray objectAtIndex:indexPath.row] dropDownOptionName];
            }
        }
    }
    else
        name=RPLocalizedString(NO_RESULTS_FOUND, NO_RESULTS_FOUND);
    
    
    if (name && ![name isEqualToString:@""])
    {
        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:name];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        CGSize mainSize = [attributedString boundingRectWithSize:CGSizeMake(250.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        if (mainSize.width==0 && mainSize.height ==0)
        {
            mainSize=CGSizeMake(11.0, 18.0);
        }
        
        return mainSize.height+20;
        
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    static NSString *CellIdentifier = @"Cell";
    cell  = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        UIView *selectedView = [[UIView alloc]init];
        selectedView.backgroundColor = RepliconStandardNavBarTintColor;
        cell.selectedBackgroundView =  selectedView;
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    NSString *name=@"";
    NSUInteger count= [self.arrayOfCharacters count];
    
    if (count>0)
    {
        
        if([self.arrayOfCharacters count] > 0 && [self.arrayOfCharacters count] > indexPath.section){
            //within the array boundary
            NSString *key = [self.arrayOfCharacters objectAtIndex:indexPath.section];
            NSMutableArray *tempArray = [self.objectsForCharacters objectForKey:key];
            if([tempArray count] > 0 && [tempArray count] > indexPath.row){
                name=[[tempArray objectAtIndex:indexPath.row] dropDownOptionName];
            }
        }
    }
    else
        name=RPLocalizedString(NO_RESULTS_FOUND, NO_RESULTS_FOUND);
    
    CGSize size =CGSizeMake(0, 0);
    if (name)
    {
        
        // Let's make an NSAttributedString first
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:name];
        //Add LineBreakMode
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
        // Add Font
        [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:RepliconFontSize_14]} range:NSMakeRange(0, attributedString.length)];
        
        //Now let's make the Bounding Rect
        //MOBi-802
        size = [attributedString boundingRectWithSize:CGSizeMake(250.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        
        if (size.width==0 && size.height ==0)
        {
            size=CGSizeMake(11.0, 18.0);
        }
    }
    
    UILabel *fieldName=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width-Yoffset, size.height)];
    if (count<1)
    {
        fieldName.textAlignment=NSTextAlignmentCenter;
    }
    [fieldName setBackgroundColor:[UIColor clearColor]];
    fieldName.font = [UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14];
    fieldName.numberOfLines=100;
    fieldName.text=name;
    fieldName.highlightedTextColor=[UIColor whiteColor];
    [cell.contentView addSubview:fieldName];
    if ([[self.timesheetListObject timesheetStatus] isEqualToString:APPROVED_STATUS ]||[[self.timesheetListObject timesheetStatus] isEqualToString:WAITING_FOR_APRROVAL_STATUS ])
    {
        [cell setUserInteractionEnabled:NO];
    }
    return cell;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if ([self.arrayOfCharacters count] == 0) {
        return @"";
    }
    
    if( section < [self.arrayOfCharacters count]) {
        return [NSString stringWithFormat:@"%@", [self.arrayOfCharacters objectAtIndex:section]];
    }
    else {
        return @"";
    }
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    
    NSArray *toBeReturned = [NSArray arrayWithArray:
                             [@"#|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z"
                              componentsSeparatedByString:@"|"]];
    
    return toBeReturned;
}


-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return [self.arrayOfCharacters indexOfObject:title] ;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DropDownOption *dropDownOption=(DropDownOption *)[[self.objectsForCharacters objectForKey:[self.arrayOfCharacters objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    [self.UdfObject setDefaultValue:[dropDownOption dropDownOptionName]];
    
    if([self.udfDropDownViewDelegate isKindOfClass:[MultiDayTimeOffViewController class]] && [[dropDownOption dropDownOptionUri] isEqual:[NSNull null]]){
        [self.UdfObject setDropDownOptionUri:nil];
    }else{
        [self.UdfObject setDropDownOptionUri:[dropDownOption dropDownOptionUri]];
    }
    if ([self.udfDropDownViewDelegate respondsToSelector:@selector(udfDropDownView:withUdfObject:)]) {
        [self.udfDropDownViewDelegate udfDropDownView:self withUdfObject:self.UdfObject];
    }
    
    if ([self.udfDropDownNavigationDelegate respondsToSelector:@selector(udfDropDownView:selectedIndexPath:)]) {
        [self.udfDropDownNavigationDelegate udfDropDownView:self selectedIndexPath:indexPath];
    }
}

-(void)dealloc
{
    self.delegate = nil;
    self.dataSource = nil;
}

@end
