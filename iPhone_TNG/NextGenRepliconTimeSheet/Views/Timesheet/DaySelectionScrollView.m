#import "DaySelectionScrollView.h"
#import "Util.h"
#import "Constants.h"
#import "TimesheetObject.h"
#import "TimesheetDayButton.h"
#import "TimesheetMainPageController.h"
#import "TimesheetModel.h"

@interface DaySelectionScrollView ()

@property (assign) CGFloat buttonWidth;

@end


#define DAY_SCROLL_HEADER_HEIGHT 50.0f
#define BUTTON_WIDTH SCREEN_WIDTH/7
@implementation DaySelectionScrollView

@synthesize scrollView;
@synthesize _dayButtons;
@synthesize parentDelegate;
@synthesize currentSelectedButtonTag;
@synthesize lastContentOffset;


- (id)initWithFrame:(CGRect)frame andWithTsDataArray:(NSMutableArray *)tsDataArray withCurrentlySelectedDay:(NSUInteger)currentDaySelected withDelegate:(id)delegate withTimesheetUri:(NSString *)timesheetUri approvalsModuleName:(NSString *)approvalsModuleName
{
    self = [super initWithFrame:frame];
    if (self) {        
        NSUInteger numberOfDayButtons=[tsDataArray count];
        NSUInteger numberOfEmptySpacesButton=0;
        if (numberOfDayButtons<7)
        {
            numberOfEmptySpacesButton=7-numberOfDayButtons;
        }
        NSString *timesheetFormat=@"";

        if (approvalsModuleName==nil||[approvalsModuleName isKindOfClass:[NSNull class]])
        {
            TimesheetModel *timesheetModel = [[TimesheetModel alloc] init];
            timesheetFormat = [timesheetModel getTimesheetFormatforTimesheetUri:timesheetUri];
        }
        else
        {
            ApprovalsModel *approvalsModel=[[ApprovalsModel alloc]init];

            if ([approvalsModuleName isEqualToString:APPROVALS_PENDING_TIMESHEETS_MODULE])
            {
                timesheetFormat = [approvalsModel getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:YES];
            }
            else
            {
                timesheetFormat = [approvalsModel getTimesheetFormatforTimesheetUri:timesheetUri andIsPending:NO];
            }
        }



        self.buttonWidth = BUTTON_WIDTH;
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,(numberOfDayButtons+numberOfEmptySpacesButton)*self.self.buttonWidth,DAY_SCROLL_HEADER_HEIGHT)];

        CGFloat contentSizeValue = 0.0;
        if (numberOfDayButtons > 7)
        {
            contentSizeValue = self.scrollView.frame.size.width + self.self.buttonWidth;
        }
        [scrollView setContentSize:CGSizeMake(contentSizeValue, DAY_SCROLL_HEADER_HEIGHT)];
        [scrollView setShowsHorizontalScrollIndicator:NO];
        [scrollView setDelegate:self];
        [scrollView setPagingEnabled:NO];
        [scrollView setScrollEnabled:YES];
        [scrollView setBackgroundColor:[UIColor clearColor]];
        NSMutableArray *tempdayButtons=[[NSMutableArray alloc]init];
        self._dayButtons=tempdayButtons;
       
        
        parentDelegate=delegate;
        for (int i=0; i<numberOfDayButtons; i++)
        {
            
            TimesheetObject *tsObj= (TimesheetObject *)[tsDataArray objectAtIndex:i];
            NSCalendar *cal = [NSCalendar currentCalendar];
            [cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];
            
            NSLocale *locale=[NSLocale currentLocale];
            [myDateFormatter setLocale:locale];
            [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";
            NSDate *tsDate=[myDateFormatter dateFromString:[tsObj entryDate]];
            [myDateFormatter setDateFormat:@"EEE"];
            NSDateComponents *components = [cal components:(NSCalendarUnitMonth |
                                                            NSCalendarUnitMinute |
                                                            NSCalendarUnitYear |
                                                            NSCalendarUnitDay |
                                                            NSCalendarUnitWeekday |
                                                            NSCalendarUnitHour |
                                                            NSCalendarUnitSecond)  fromDate:tsDate];
            
            NSInteger day = [components day];
            NSString *weekDay=[[myDateFormatter stringFromDate:tsDate] uppercaseString];
            
           
            
            BOOL isDayOff=NO;
            if ([tsObj isWeeklyDayOff])
            {
                isDayOff=YES;
            }
            BOOL isDayFilled=NO;
            if(timesheetFormat!=nil && timesheetFormat !=(id)[NSNull null])
            {
                if([timesheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET]) // NULL CHECK
                {
                    if ([[tsObj numberOfHours] newFloatValue]>0 ||[[tsObj numberOfHours] newFloatValue]< 0 || ([[tsObj numberOfHours] newFloatValue]== 0 && [tsObj hasEntry]))
                    {
                        isDayFilled=YES;
                    }
                }
                else
                {
                    if ([[tsObj numberOfHours] newFloatValue]>0 || [tsObj hasEntry])
                    {
                        isDayFilled=YES;
                    }
                }
            }
            TimesheetDayButton *dayBtn=[[TimesheetDayButton alloc]initWithDate:day andDay:weekDay  dayOff:isDayOff isTimesheetDayFilled:isDayFilled frame:CGRectMake(self.buttonWidth*i,0, self.buttonWidth, DAY_SCROLL_HEADER_HEIGHT) withTag:i withDelegate:self];
            [dayBtn markAsDayOff:tsObj.isDayOff];
            [scrollView addSubview:dayBtn];
            [_dayButtons addObject:dayBtn];
            
            
        }
        for (int k=0; k<numberOfEmptySpacesButton; k++)
        {
            UIImageView *imageview=[[UIImageView alloc]initWithFrame:CGRectMake(self.buttonWidth*(k+numberOfDayButtons),0, self.buttonWidth, DAY_SCROLL_HEADER_HEIGHT)];
            UIImage *emptyButtonSpaceImage = [Util thumbnailImage:EMPTY_DAY_BUTTON_IMAGE];
            [imageview setImage:emptyButtonSpaceImage];
            [scrollView addSubview:imageview];
           
        }
        
        
        [self addSubview:scrollView];
        
        if (_dayButtons.count>0)
        {
            [self timesheetDayBtnClicked:[_dayButtons objectAtIndex:currentDaySelected] isManualClick:NO];
        }

        
    }
    return self;
}

-(void)timesheetDayBtnClicked:(id)sender isManualClick:(BOOL)isManualBtnClick
{
    self.currentSelectedButtonTag=[sender tag];
    TimesheetDayButton* btn;
    for (int i = 0; i<[_dayButtons count]; i++) {
        btn = (TimesheetDayButton*)[_dayButtons objectAtIndex:i];
        [btn highlightButton:NO forButton:btn];
    }
    btn = (TimesheetDayButton*)sender;
    [btn highlightButton:YES forButton:btn];
    
    if (parentDelegate != nil && ![parentDelegate isKindOfClass:[NSNull class]] &&
        [parentDelegate conformsToProtocol:@protocol(DayScrollButtonClickProtocol)])
    {
        if ([parentDelegate isKindOfClass:[TeamTimeViewController class]])
        {
            //do nothing
        }
        else
        {
            TimesheetMainPageController *ctrl=(TimesheetMainPageController *)parentDelegate;
            if (!isManualBtnClick)
            {
                ctrl.pageControl.currentPage=currentSelectedButtonTag;
            }
        }
        
        [parentDelegate timesheetDayBtnClickedWithTag:[sender tag]];
        
    }
    if ([sender tag]<3)
    {
        //One of the First three buttons is selected.Need not centre
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if ([sender tag]>=[_dayButtons count]-3)
    {
        //One of the last three buttons is selected.Need not centre
        [scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width-(7*self.buttonWidth), 0) animated:YES];
    }
    else
    {
        [scrollView setContentOffset:CGPointMake(([sender tag]-3)*self.buttonWidth, 0) animated:YES];
    }
    
}

-(void)timesheetDayBtnHighLightOnCrossOver:(int)page
{
    self.currentSelectedButtonTag=page;
    for (int i = 0; i<[_dayButtons count]; i++) {
        TimesheetDayButton* btn = (TimesheetDayButton*)[_dayButtons objectAtIndex:i];
        [btn highlightButton:NO forButton:btn];
    }
    TimesheetDayButton* btn = (TimesheetDayButton*)[_dayButtons objectAtIndex:page];
    [btn highlightButton:YES forButton:btn];
    
    if (parentDelegate != nil && ![parentDelegate isKindOfClass:[NSNull class]] &&
        [parentDelegate conformsToProtocol:@protocol(DayScrollButtonClickProtocol)])
    {
        TimesheetMainPageController *ctrl=(TimesheetMainPageController *)parentDelegate;
        ctrl.pageControl.currentPage=currentSelectedButtonTag;
        [parentDelegate timesheetDayBtnClickedWithTag:page];
        
    }
    if (page<3)
    {
        //One of the First three buttons is selected.Need not centre
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    else if (page>=[_dayButtons count]-3)
    {
        //One of the last three buttons is selected.Need not centre
        [scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width-(7*self.buttonWidth), 0) animated:YES];
    }
    else
    {
        [scrollView setContentOffset:CGPointMake((page-3)*self.buttonWidth, 0) animated:YES];
    }
    
}


#pragma mark - UIScrollView delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.lastContentOffset > self.scrollView.contentOffset.x)
    {
        scrollDirection = ScrollDirectionRight;
    }
    
    else if (self.lastContentOffset < self.scrollView.contentOffset.x)
    {
        scrollDirection = ScrollDirectionLeft;
    }
    else
    {
        scrollDirection=ScrollDirectionOther;
    }
    
    if (scrollDirection==ScrollDirectionLeft)
    {
        self.lastContentOffset = self.scrollView.contentOffset.x;
        CGFloat pageWidth = self.buttonWidth;
        int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        int currentButtonScrolled=page+7;
        if (currentButtonScrolled>[_dayButtons count])
        {
            //NSLog(@"Do not do anything");
        }
        else
        {
            float contentSizeValue=self.scrollView.frame.size.width+self.buttonWidth;
            if (currentButtonScrolled==[_dayButtons count])
            {
                contentSizeValue=self.scrollView.frame.size.width;
            }
            [self.scrollView setContentSize:CGSizeMake(page*self.buttonWidth+contentSizeValue, DAY_SCROLL_HEADER_HEIGHT)];
        }
    }
    
    
    
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    CGFloat pageWidth = self.buttonWidth;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    int currentButtonScrolled=page+7;
    if (currentButtonScrolled>[_dayButtons count])
    {
        //NSLog(@"Do not do anything");
    }
    else
    {
        [self.scrollView setContentOffset:CGPointMake(page*self.buttonWidth, 0) animated:YES];
    }
    
    
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
    {
        CGFloat pageWidth = self.buttonWidth;
        int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        [self.scrollView setContentOffset:CGPointMake(page*self.buttonWidth, 0) animated:YES];
    }
    
}

- (void)scrollViewDidFinishScrolling:(UIScrollView*)scrollView
{
    
}

-(void)resetDayScrollViewPositionToViewSelectedButton
{
    if ([_dayButtons count]>7)
    {
        if (currentSelectedButtonTag<3)
        {
            //One of the First three buttons is selected.Need not centre
            [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
        else if(currentSelectedButtonTag>=[_dayButtons count]-3)
        {
            //One of the last three buttons is selected.Need not centre
            [scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width-(7*self.buttonWidth), 0) animated:YES];
        }
        else
        {
            [scrollView setContentOffset:CGPointMake((currentSelectedButtonTag-3)*self.buttonWidth, 0) animated:YES];
        }
    }
    
    
}
-(void)updateFilledStatusOfSelectedButton:(BOOL)isFilledHours onPage:(NSInteger)page
{
    if (_dayButtons.count>0)
    {
        TimesheetDayButton* btn= (TimesheetDayButton*)[_dayButtons objectAtIndex:page];
        if (isFilledHours)
        {
            [btn set_dayFilled:YES];
        }
        else
        {
            [btn set_dayFilled:NO];
        }

        [btn highlightButton:NO forButton:btn];


        TimesheetDayButton* btnNew= (TimesheetDayButton*)[_dayButtons objectAtIndex:currentSelectedButtonTag];
        if (isFilledHours)
        {
            [btnNew set_dayFilled:YES];
        }
        else
        {
            [btnNew set_dayFilled:NO];
        }
        
        [btnNew highlightButton:YES forButton:btnNew];
    }
    

    
}


- (void)dealloc
{
    self.scrollView.delegate = nil;
}



@end
