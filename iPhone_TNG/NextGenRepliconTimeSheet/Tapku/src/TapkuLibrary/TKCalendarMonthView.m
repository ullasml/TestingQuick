//
//  TKCalendarMonthView.m
//  Created by Devin Ross on 6/10/10.
//
/*
 
 tapku.com || http://github.com/devinross/tapkulibrary
 
 Permission is hereby granted, free of charge, to any person
 obtaining a copy of this software and associated documentation
 files (the "Software"), to deal in the Software without
 restriction, including without limitation the rights to use,
 copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following
 conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "TKCalendarMonthView.h"
#import "NSDate+TKCategory.h"
#import "TKGlobal.h"
#import "UIImage+TKCategory.h"

#define SCREENWIDTH [[UIScreen mainScreen] bounds].size.width
#define CELLWIDTH ([[UIScreen mainScreen] bounds].size.width/7)
#define CELLHEIGHT 45
typedef NS_ENUM(NSInteger,MonthOfTheDay)
{
    Previous,
    Current,
    Next,
};

#pragma mark -
@interface NSDate (calendarcategory)

- (NSDate*) firstOfMonth;
- (NSDate*) nextMonth;
- (NSDate*) previousMonth;

- (NSDate*) lastOfMonthDate;
+ (NSDate*) lastofMonthDate;
+ (NSDate*) lastOfCurrentMonth;

@end


#pragma mark -

@implementation NSDate (calendarcategory)

- (NSDate*) firstOfMonth{
    NSDateComponents *info = [self dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    info.day = 1;
    info.minute = 0;
    info.second = 0;
    info.hour = 0;
    info.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    return [NSDate dateWithDateComponents:info];
}
- (NSDate*) nextMonth{
    
    
     NSDateComponents *info = [self dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    info.month++;
    if(info.month>12){
        info.month = 1;
        info.year++;
    }
    info.minute = 0;
    info.second = 0;
    info.hour = 0;
    
    info.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    return [NSDate dateWithDateComponents:info];
    
}
- (NSDate*) previousMonth{
    
    
    NSDateComponents *info = [self dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    info.month--;
    if(info.month<1){
        info.month = 12;
        info.year--;
    }
    
    info.minute = 0;
    info.second = 0;
    info.hour = 0;
    info.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    return [NSDate dateWithDateComponents:info];
    
}

- (NSDate*) lastOfMonthDate {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [gregorian setTimeZone:timeZone];
    NSDateComponents *comp = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:self];
    [comp setDay:0];
    [comp setMonth:comp.month+1];
    NSDate *date = [gregorian dateFromComponents:comp];
    return date;
}

+ (NSDate*) lastofMonthDate{
    NSDate *day = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [gregorian setTimeZone:timeZone];
    NSDateComponents *comp = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:day];
    [comp setDay:0];
    [comp setMonth:comp.month+1];
    return [gregorian dateFromComponents:comp];
}
+ (NSDate*) lastOfCurrentMonth{
    NSDate *day = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [gregorian setTimeZone:timeZone];
    NSDateComponents *comp = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth) fromDate:day];
    [comp setDay:0];
    [comp setMonth:comp.month+1];
    return [gregorian dateFromComponents:comp];
}

@end


#pragma mark -
@interface TKCalendarMonthTiles : UIView {
    
    id target;
    SEL action;
    
    NSInteger firstOfPrev,lastOfPrev;
    NSArray *marks;
    NSInteger today;
    BOOL markWasOnToday;
    
    NSInteger selectedDay,selectedPortion;
    
    NSInteger firstWeekday, daysInMonth;
    UILabel *dot;
    UILabel *currentDay;
    UIImageView *selectedImageView;
    BOOL startOnSunday;
    NSMutableArray *dotmarksArrayDefaults;
    int previousRowSelected;
    int previousColumnSelected;
    int previouslySelectedDay;
    int previousTemp;
    NSMutableArray *midDatesArray;
    NSDate *temporaryStartDate;
    NSDate *temporaryActiveDate;
    NSDate *temporaryDateOfGradedRegion;
    BOOL isTodayDayFromNextMonthDate;
    BOOL isForwardSwipe;
    BOOL isBackwardSwipe;
    BOOL isFirstTime;
    BOOL isTouchesEndReached;
    BOOL isTouchesBeganFromOtherMonthDate;
    NSMutableDictionary *WeekEndDictionary;
    BOOL showGridCalendar;
    NSDate *dateBeingDrawnOnTile;
}
@property (strong,nonatomic) NSDate *monthDate;
@property (strong,nonatomic) NSMutableArray *midDatesArray;
@property (nonatomic,strong)NSDate *temporaryStartDate;
@property (nonatomic,strong)NSDate *temporaryActiveDate;
@property (nonatomic,strong)NSDate *temporaryDateOfGradedRegion;

-(id) initWithMonth:(NSDate*)date marks:(NSArray*)marks startDayOnSunday:(BOOL)sunday approvedRejectedWaitingDatesDictionary:(NSMutableDictionary *)dictionary WithWeekends:(NSMutableDictionary *)dict withShowCompleteCalendarGrid:(BOOL)isCompleteGridCalendarBool;
+(NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday isCompleteGridCalendar:(BOOL)isCompleteGridCalendarBool;
-(NSDate *)changeDateToDay:(int)day forDate:(NSDate *)date;
-(NSDate*) dateSelected;
-(void)setTarget:(id)target action:(SEL)action;
-(void)selectDay:(NSInteger)day;
-(void)markDay:(NSInteger)day;
-(void)addColoredImageToTileForImageWithDay:(NSInteger)day forImageName:(NSString *)imageStr;
-(void)paint_Approved_Rejected_Dates:(NSMutableDictionary *)dictionary;
-(void)paint_Approved_Rejected_Dates_From_Array:(NSMutableArray *)valueArray withImage:(NSString *)imageStr;

-(void)markDayInPositionWithDay:(NSInteger)position :(NSInteger)day;
-(void)addApprovedOrRejectedImageToTileWithDayInPosition:(NSInteger)day inPosition:(NSInteger)position withImage:(NSString *)imageStr;

-(NSDate *)getDateForSelectedPortion:(int)portion withDay:(int)day;
- (void) selectDayInPositionWithDay:(NSInteger)position :(NSInteger)day;
- (void)markDayInPositionWithDayAndImage:(NSInteger)position :(NSInteger)day :(NSString *)imageStr;
-(void)addColoredImageToTileForSwipe:(int)startDay :(int)endDay :(NSString *)imageStr;
-(void)deleteColoredImageToTileForSwipeWithStartDay:(int)startDay andEndDay:(int)endDay withImage:(NSString *)imageStr;
-(NSInteger)getIntegerDayForDate:(NSDate *)date;
-(NSInteger)getIntegerMonthForDate:(NSDate *)date;
-(NSInteger)getIntegerYearForDate:(NSDate *)date;
-(BOOL)checkWhetherToShowDotOnDate;

@end

#pragma mark - TKCalendarMonthTiles
#define dotFontSize 30.0
#define dateFontSize 12.0
@interface TKCalendarMonthTiles (private)
@property (strong,nonatomic) UIImageView *selectedImageView;
@property (strong,nonatomic) UILabel *currentDay;
@property (strong,nonatomic) UILabel *dot;
@end

#pragma mark - TKCalendarMonthTiles

#define TIMEOFF_APPROVED @"DatesApproved"
#define TIMEOFF_REJECTED @"DatesRejected"
#define TIMEOFF_WAITING @"DatesWaiting"
#define TIMEOFF_HOLIDAY @"Holiday"
#define TIMEOFF_APPROVED_AND_REJECTED @"SameApprovedRejected"
#define TIMEOFF_APPROVED_AND_WAITING @"SameApprovedWaiting"
#define TIMEOFF_REJECTED_AND_WAITING @"SameRejectedWaiting"
#define TIMEOFF_APPROVED_IMAGE @"TapkuLibrary.bundle/Images/calendar/approved.png"
#define TIMEOFF_REJECTED_IMAGE @"TapkuLibrary.bundle/Images/calendar/overdue.png"
#define TIMEOFF_WAITING_IMAGE @"TapkuLibrary.bundle/Images/calendar/pending.png"
#define TIMEOFF_HOLIDAY_IMAGE @"TapkuLibrary.bundle/Images/calendar/calendarTile_timeOff_weekends.png"
#define TIMEOFF_APPROVED_AND_REJECTED_IMAGE @"TapkuLibrary.bundle/Images/calendar/calendarTile_splitGR.png"
#define TIMEOFF_APPROVED_AND_WAITING_IMAGE @"TapkuLibrary.bundle/Images/calendar/calendarTile_splitGY.png"
#define TIMEOFF_REJECTED_AND_WAITING_IMAGE @"TapkuLibrary.bundle/Images/calendar/calendarTile_splitRY.png"
@implementation TKCalendarMonthTiles
@synthesize monthDate;
@synthesize midDatesArray;
@synthesize temporaryStartDate;
@synthesize temporaryActiveDate;
@synthesize temporaryDateOfGradedRegion;


#pragma mark - Methods
+ (NSArray*) rangeOfDatesInMonthGrid:(NSDate*)date startOnSunday:(BOOL)sunday isCompleteGridCalendar:(BOOL)isCompleteGridCalendarBool{
    
    NSDate *firstDate, *lastDate;
    
    NSDateComponents *info = [date dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    info.day = 1;
    info.hour = 0;
    info.minute = 0;
    info.second = 0;
    info.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    
    NSDate *currentMonth = [NSDate dateWithDateComponents:info];
    info = [currentMonth dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    
    NSDate *previousMonth = [currentMonth previousMonth];
    NSDate *nextMonth = [currentMonth nextMonth];
    
    if(info.weekday > 1 && sunday){
        
        NSDateComponents *info2 = [previousMonth dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        NSInteger preDayCnt = [previousMonth daysBetweenDate:currentMonth];
        info2.day = preDayCnt - info.weekday + 2;
        firstDate = [NSDate dateWithDateComponents:info2];
        
        
    }else if(!sunday && info.weekday != 2){
        
        NSDateComponents *info2 = [previousMonth dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSInteger preDayCnt = [previousMonth daysBetweenDate:currentMonth];
        if(info.weekday==1){
            info2.day = preDayCnt - 5;
        }else{
            info2.day = preDayCnt - info.weekday + 3;
        }
        firstDate = [NSDate dateWithDateComponents:info2];
        
        
        
    }else{
        firstDate = currentMonth;
    }
    
    
    
    NSInteger daysInMonth = [currentMonth daysBetweenDate:nextMonth];
    info.day = daysInMonth;
    NSDate *lastInMonth = [NSDate dateWithDateComponents:info];
    NSDateComponents *lastDateInfo = [lastInMonth dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSInteger tempLastDateWeekday=lastDateInfo.weekday;
    
    
    BOOL showCompleteGridCalendar=isCompleteGridCalendarBool;
    
    
    if(lastDateInfo.weekday < 7 && sunday){
        
        if (showCompleteGridCalendar)
        {
            lastDateInfo.day = 14 - lastDateInfo.weekday;
            lastDateInfo.month++;
            lastDateInfo.weekday = 0;
            if(lastDateInfo.month>12){
                lastDateInfo.month = 1;
                lastDateInfo.year++;
            }
            lastDate = [NSDate dateWithDateComponents:lastDateInfo];
            NSInteger daysInTile = [firstDate daysBetweenDate:lastDate];
            
            if (daysInTile>41)
            {
                lastDateInfo.day = 7 - tempLastDateWeekday;
                lastDate = [NSDate dateWithDateComponents:lastDateInfo];
            }
            
        }
        else {
            lastDateInfo.day = 7 - lastDateInfo.weekday;
            lastDateInfo.month++;
            lastDateInfo.weekday = 0;
            if(lastDateInfo.month>12){
                lastDateInfo.month = 1;
                lastDateInfo.year++;
            }
            lastDate = [NSDate dateWithDateComponents:lastDateInfo];
        }
        
        
        
    }else if(!sunday && lastDateInfo.weekday != 1){
        
        
        lastDateInfo.day = 8 - lastDateInfo.weekday;
        lastDateInfo.month++;
        if(lastDateInfo.month>12){ lastDateInfo.month = 1; lastDateInfo.year++; }
        
        
        lastDate = [NSDate dateWithDateComponents:lastDateInfo];
        
    }else{
        
        if (showCompleteGridCalendar)
        {
            lastDateInfo.day = tempLastDateWeekday;
            lastDateInfo.month++;
            lastDateInfo.weekday = 0;
            if(lastDateInfo.month>12){
                lastDateInfo.month = 1;
                lastDateInfo.year++;
            }
            lastDate = [NSDate dateWithDateComponents:lastDateInfo];
            NSInteger daysInTile = [firstDate daysBetweenDate:lastDate];
            if (daysInTile<35) {
                lastDateInfo.day = tempLastDateWeekday+7;
            }
            lastDate = [NSDate dateWithDateComponents:lastDateInfo];
            
        }
        else {
            lastDate = lastInMonth;
        }
        
    }
    
    
    
    return [NSArray arrayWithObjects:firstDate,lastDate,nil];
}

- (id) initWithMonth:(NSDate*)date marks:(NSArray*)markArray startDayOnSunday:(BOOL)sunday approvedRejectedWaitingDatesDictionary:(NSMutableDictionary *)dictionary WithWeekends:(NSMutableDictionary *)dict withShowCompleteCalendarGrid:(BOOL)isCompleteGridCalendarBool{
    if(!(self=[super initWithFrame:CGRectZero])) return nil;
    
    firstOfPrev = -1;
    marks = markArray;
    monthDate = date;
    startOnSunday = sunday;
    midDatesArray=[NSMutableArray array];
    isFirstTime=YES;
    NSDateComponents *dateInfo = [monthDate dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    firstWeekday = dateInfo.weekday;
    WeekEndDictionary=dict;
    showGridCalendar=isCompleteGridCalendarBool;
    NSDate *prev = [monthDate previousMonth];
    daysInMonth = [[monthDate nextMonth] daysBetweenDate:monthDate];
    
    NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:date startOnSunday:sunday isCompleteGridCalendar:isCompleteGridCalendarBool];
    NSUInteger numberOfDaysBetween = [[dates objectAtIndex:0] daysBetweenDate:[dates lastObject]];
    NSUInteger scale = (numberOfDaysBetween / 7) + 1;
    CGFloat h = 44.0f * scale;
    
    
    NSDateComponents *todayInfo = [[NSDate date] dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    today = dateInfo.month == todayInfo.month && dateInfo.year == todayInfo.year ? todayInfo.day : -5;
    
    NSInteger preDayCnt = [prev daysBetweenDate:monthDate];
    if(firstWeekday>1 && sunday){
        firstOfPrev = preDayCnt - firstWeekday+2;
        lastOfPrev = preDayCnt;
    }else if(!sunday && firstWeekday != 2){
        
        if(firstWeekday ==1){
            firstOfPrev = preDayCnt - 5;
        }else{
            firstOfPrev = preDayCnt - firstWeekday+3;
        }
        lastOfPrev = preDayCnt;
    }
    
    
    self.frame = CGRectMake(0, 1.0, SCREENWIDTH, h+1);
    
    [self.selectedImageView addSubview:self.currentDay];
    [self.selectedImageView addSubview:self.dot];
    self.multipleTouchEnabled = YES;
    
    
    [self paint_Approved_Rejected_Dates:dictionary];
    [self setAccessibilityLabel:@"uia_timeoff_date_selection_grid_identifier"];
    
    
    return self;
}


-(void) paint_Approved_Rejected_Dates:(NSMutableDictionary *)dictionary
{
    //NSArray *keyArray=[dictionary allKeys];
    NSArray *keyArray = [[dictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    
    for (int i=0; i<[keyArray count]; i++)
    {
        
        if ([[keyArray objectAtIndex:i] isEqualToString:TIMEOFF_APPROVED])
        {
            
            [self paint_Approved_Rejected_Dates_From_Array:[dictionary objectForKey:TIMEOFF_APPROVED] withImage:TIMEOFF_APPROVED_IMAGE];
        }
        else if([[keyArray objectAtIndex:i] isEqualToString:TIMEOFF_REJECTED])
        {
            
            [self paint_Approved_Rejected_Dates_From_Array:[dictionary objectForKey:TIMEOFF_REJECTED] withImage:TIMEOFF_REJECTED_IMAGE];
        }
        else if ([[keyArray objectAtIndex:i] isEqualToString:TIMEOFF_WAITING])
        {
            [self paint_Approved_Rejected_Dates_From_Array:[dictionary objectForKey:TIMEOFF_WAITING] withImage:TIMEOFF_WAITING_IMAGE];
        }
        else if ([[keyArray objectAtIndex:i] isEqualToString:TIMEOFF_APPROVED_AND_REJECTED])
        {
            [self paint_Approved_Rejected_Dates_From_Array:[dictionary objectForKey:TIMEOFF_APPROVED_AND_REJECTED] withImage:TIMEOFF_APPROVED_AND_REJECTED_IMAGE];
            
        }
        else if ([[keyArray objectAtIndex:i] isEqualToString:TIMEOFF_APPROVED_AND_WAITING])
        {
            [self paint_Approved_Rejected_Dates_From_Array:[dictionary objectForKey:TIMEOFF_APPROVED_AND_WAITING] withImage:TIMEOFF_APPROVED_AND_WAITING_IMAGE];
        }
        else if ([[keyArray objectAtIndex:i] isEqualToString:TIMEOFF_REJECTED_AND_WAITING])
        {
            [self paint_Approved_Rejected_Dates_From_Array:[dictionary objectForKey:TIMEOFF_REJECTED_AND_WAITING] withImage:TIMEOFF_REJECTED_AND_WAITING_IMAGE];
        }
        else
        {
            [self paint_Approved_Rejected_Dates_From_Array:[dictionary objectForKey:TIMEOFF_HOLIDAY] withImage:TIMEOFF_HOLIDAY_IMAGE];
        }
        
        
        
    }
}
-(void)paint_Approved_Rejected_Dates_From_Array:(NSMutableArray *)valueArray withImage:(NSString *)imageStr
{
    for (int i=0; i<[valueArray count]; i++)
    {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        NSLocale *locale=[NSLocale currentLocale];
        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [gregorian setLocale:locale];
        [gregorian setTimeZone:timeZone];
        NSDateComponents *todayComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[valueArray objectAtIndex:i]];
        NSInteger theDay = [todayComponents day];
        NSInteger theMonth = [todayComponents month];
        NSInteger theYear = [todayComponents year];
        
        NSDateComponents *currentComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:monthDate];
        
        NSInteger currentMonth = [currentComponents month];
        NSInteger currentYear = [currentComponents year];
        
        
        if (currentYear==theYear && currentMonth==theMonth && today==theDay)
        {
            //            [self addApprovedOrRejectedImageToTileWithDayInPosition:theDay inPosition:theDay withImage:@"TapkuLibrary.bundle/Images/calendar/today.png"];
            //            [midDatesArray addObject:[NSString stringWithFormat:@"%d",theDay]];
            
        }
        
        else if (currentYear==theYear && currentMonth==theMonth)
        {
            [self addApprovedOrRejectedImageToTileWithDayInPosition:theDay inPosition:theDay withImage:imageStr];
            [midDatesArray addObject:[NSString stringWithFormat:@"%ld",(long)theDay]];
        }
        else  if (currentYear==theYear )
        {
            if (currentMonth==theMonth-1)
            {
                [self addApprovedOrRejectedImageToTileWithDayInPosition:theDay inPosition:daysInMonth + theDay withImage:imageStr];
                [midDatesArray addObject:[NSString stringWithFormat:@"%ld",(long)theDay]];
            }
            else
            {
                if (currentMonth==theMonth+1)
                {
                    int increment=0;
                    for (NSInteger k=lastOfPrev; k>=firstOfPrev; k--) {
                        if (theDay==k)
                        {
                            [self addApprovedOrRejectedImageToTileWithDayInPosition:theDay inPosition:increment withImage:imageStr];
                            [midDatesArray addObject:[NSString stringWithFormat:@"%ld",(long)theDay]];
                            break;
                        }
                        else
                        {
                            increment--;
                        }
                    }
                    
                }
            }
        }
        else
        {
            if (currentYear+1==theYear) {
                if (currentMonth==12)
                {
                    if (theMonth==1)
                    {
                        [self addApprovedOrRejectedImageToTileWithDayInPosition:theDay inPosition:theDay+daysInMonth withImage:imageStr];
                        [midDatesArray addObject:[NSString stringWithFormat:@"%ld",(long)theDay]];
                    }
                }
                
            }
            if (currentYear-1==theYear) {
                if (currentMonth==1)
                {
                    if (theMonth==12)
                    {
                        if (firstOfPrev<=theDay && theDay<=lastOfPrev)
                        {
                            [self addApprovedOrRejectedImageToTileWithDayInPosition:theDay inPosition:theDay-lastOfPrev withImage:imageStr];
                            [midDatesArray addObject:[NSString stringWithFormat:@"%ld",(long)theDay]];
                        }
                    }
                }
                
            }
            
        }
        
    }
    
}

- (void) setTarget:(id)t action:(SEL)a{
    target = t;
    action = a;
}


- (CGRect) rectForCellAtIndex:(NSInteger)index{
    
    NSInteger row = index / 7;
    NSInteger col = index % 7;
    
    return CGRectMake(col*CELLWIDTH, row*44+6, CELLWIDTH, CELLHEIGHT);
}
-(BOOL)checkWhetherWeekEndDateForIndex:(int)index
{
    int col = index % 7;
    NSString *key=@"";
    if (col==0) {
        key=@"SUN";
    }
    else if (col==1) {
        key=@"MON";
    }
    else if (col==2) {
        key=@"TUE";
    }
    else if (col==3) {
        key=@"WED";
    }
    else if (col==4) {
        key=@"THU";
    }
    else if (col==5) {
        key=@"FRI";
    }
    else if (col==6) {
        key=@"SAT";
    }
    if ([[WeekEndDictionary objectForKey:key]intValue]==1)
    {
        return YES;
    }
    return NO;
}
/*- (void) drawTileInRect:(CGRect)r day:(int)day mark:(BOOL)mark font:(UIFont*)f1 font2:(UIFont*)f2
 {
	
	NSString *str = [NSString stringWithFormat:@"%d",day];
	
	
	r.size.height -= 2;
	[str drawInRect: r
 withFont: f1
 lineBreakMode: NSLineBreakByWordWrapping
 alignment: NSTextAlignmentCenter];
	
	if(mark){
 r.size.height = 10;
 r.origin.y += 18;
 
 NSDate *startDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedStartDate"];
 NSDate *activeDate=[[NSUserDefaults standardUserDefaults] objectForKey:@"selectedEndDate"];
 NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
 NSLocale *locale =[[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
 NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
 [gregorian setLocale:locale];
 [gregorian setTimeZone:timeZone];
 NSDateComponents *startDateComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:startDate];
 NSDateComponents *activeDateComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:activeDate];
 NSDateComponents *thisMonthDateComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:monthDate];
 
 NSInteger theStartDate = [startDateComponents day];
 NSInteger theActiveDate = [activeDateComponents day];
 
 NSInteger theStartMonth = [startDateComponents month];
 NSInteger theActiveMonth = [activeDateComponents month];
 NSInteger thisMonthMonth=[thisMonthDateComponents month];
 
 NSInteger thisYearYear=[thisMonthDateComponents year];
 NSInteger theStartYear=[startDateComponents year];
 NSInteger theActiveYear=[activeDateComponents year];
 
 
 
 
 
 NSMutableArray *marksArrayDefaults=[[NSUserDefaults standardUserDefaults]objectForKey: @"marksArrayDefaults"];
 if ([marksArrayDefaults count]==2)
 {
 
 if (theStartMonth==theActiveMonth && theStartMonth==thisMonthMonth) {
 
 if (theStartYear==theActiveYear && theStartYear==thisYearYear) {
 [self markDay:theStartDate];
 [self selectDay:theActiveDate];
 }
 
 }
 else {
 if (theStartMonth==thisMonthMonth && theStartMonth!=theActiveMonth && theStartYear==thisYearYear) {
 [self markDay:theStartDate];
 
 }
 else {
 
 if (firstOfPrev<=theStartDate && theStartDate<=lastOfPrev) {
 
 int position=theStartDate-lastOfPrev;
 [self markDayInPositionWithDay:position:theStartDate];
 }
 else {
 int position=theStartDate+daysInMonth;
 [self markDayInPositionWithDay:position:theStartDate];
 }
 
 }
 if (theActiveMonth==thisMonthMonth && theStartMonth!=theActiveMonth && theActiveYear==thisYearYear) {
 [self selectDay:theActiveDate];
 
 }
 else {
 
 if (firstOfPrev<=theActiveDate && theActiveDate<=lastOfPrev) {
 
 theActiveDate=theActiveDate-lastOfPrev;
 [self selectDay:theActiveDate];
 
 }
 else {
 
 if (theActiveYear==thisYearYear && theActiveMonth==thisMonthMonth)
 {
 theActiveDate=theActiveDate+daysInMonth;
 [self selectDay:theActiveDate];
 }
 else {
 int position=theActiveDate+daysInMonth;
 [self selectDayInPositionWithDay:position :theActiveDate];
 }
 }
 
 }
 
 }
 
 
 
 
 }
 else if ([marksArrayDefaults count]==1)
 {
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 NSMutableArray *marksArrayDatesDefaults=[defaults objectForKey: @"marksArrayDatesDefaults"];
 NSDate *dateToMarkOnTile=[marksArrayDatesDefaults objectAtIndex:0];
 NSDate *startDate=[defaults objectForKey:@"selectedStartDate"];
 NSDate *activeDate=[defaults objectForKey:@"selectedEndDate"];
 
 
 if ([startDate compare:activeDate]==NSOrderedSame)
 {
 if (theActiveMonth==thisMonthMonth && theActiveYear==thisYearYear)
 {
 [self selectDay:theActiveDate];
 }
 else
 {
 if (firstOfPrev<=theActiveDate && theActiveDate<=lastOfPrev) {
 int position=theActiveDate-lastOfPrev;
 [self selectDayInPositionWithDay:position:theActiveDate];
 }
 else {
 int position=theActiveDate+daysInMonth;
 [self selectDayInPositionWithDay:position:theActiveDate];
 }
 
 }
 
 }
 if ([dateToMarkOnTile compare:startDate]==NSOrderedSame)
 {
 if (theStartMonth==thisMonthMonth && theStartYear==thisYearYear)
 {
 if (![startDate compare:activeDate]==NSOrderedSame) {
 if([defaults boolForKey:@"PREVIOUS_CLICKED"]||[defaults boolForKey:@"NEXT_CLICKED"])
 self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png")];
 }
 [self selectDay:theStartDate];
 }
 else
 {
 NSString *imageStr=nil;
 if ([startDate compare:activeDate]==NSOrderedSame) {
 imageStr= @"TapkuLibrary.bundle/Images/calendar/selected.png";
 }
 else{
 imageStr= @"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png";
 }
 if (firstOfPrev<=theStartDate && theStartDate<=lastOfPrev) {
 int position=theStartDate-lastOfPrev;
 [self markDayInPositionWithDayAndImage:position:theStartDate:imageStr];
 }
 else {
 int position=theStartDate+daysInMonth;
 [self markDayInPositionWithDayAndImage:position:theStartDate:imageStr];
 }
 
 
 }
 }
 else if ([dateToMarkOnTile compare:activeDate]==NSOrderedSame)
 {
 if (theActiveMonth==thisMonthMonth && theActiveYear==thisYearYear)
 {
 [self selectDay:theActiveDate];
 }
 else
 {
 if (firstOfPrev<=theActiveDate && theActiveDate<=lastOfPrev) {
 int position=theActiveDate-lastOfPrev;
 [self selectDayInPositionWithDay:position:theActiveDate];
 }
 else {
 int position=theActiveDate+daysInMonth;
 [self selectDayInPositionWithDay:position:theActiveDate];
 }
 
 }
 
 }
 
 }
 }
 
 }*/

- (void) drawTileInRect:(CGRect)r day:(NSInteger)day mark:(BOOL)mark font:(UIFont*)f1 font2:(UIFont*)f2 monthOfTheDay:(MonthOfTheDay)monthOfTheDay isWeekEnd:(BOOL)weekEnd
{
    CGRect y=r;
    y.origin.x=r.origin.x+6;
    y.origin.y=r.origin.y-4;
    if (weekEnd) {
        if (day!=today)
        {
            [[UIImage imageWithContentsOfFile:TKBUNDLE(TIMEOFF_HOLIDAY_IMAGE)] drawInRect:y];
        }
        else {
            if (isTodayDayFromNextMonthDate) {
                [[UIImage imageWithContentsOfFile:TKBUNDLE(TIMEOFF_HOLIDAY_IMAGE)] drawInRect:y];
            }
        }
        
        
    }
    else {
        
        if (day!=today) {
            [[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile.png")] drawInRect:y];
        }
        else {
            if (isTodayDayFromNextMonthDate) {
                [[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile.png")] drawInRect:y];
            }
        }
        
    }
    
    NSString *str = [NSString stringWithFormat:@"%ld",(long)day];

    
    r.size.height -= 2;
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [paragraphStyle setAlignment:NSTextAlignmentRight];

    
    [str drawInRect:r withAttributes:@{NSParagraphStyleAttributeName:paragraphStyle, NSFontAttributeName:f1}];

    
    if(mark){
        r.size.height = 10;
        r.origin.y += 18;
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        
        NSLocale *locale=[NSLocale currentLocale];
        NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [gregorian setLocale:locale];
        [gregorian setTimeZone:timeZone];
        NSDateComponents *thisMonthDateComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:monthDate];
        NSInteger thisMonthMonth=[thisMonthDateComponents month];
        NSInteger thisYearYear=[thisMonthDateComponents year];
        
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        BOOL temp=[defaults boolForKey:@"tempBool"];
        if (temp==NO)
        {
            
            NSMutableArray *marksArrayDefaults=[defaults objectForKey: @"marksArrayDefaults"];
            if ([marksArrayDefaults count]==2)
            {
                
                NSMutableArray *marksArrayDatesDefaults=[defaults objectForKey: @"marksArrayDatesDefaults"];
                NSDate *dateToMarkOnTile=nil;
                
                for (int i=0; i<[marksArrayDatesDefaults count]; i++)
                {
                    dateToMarkOnTile=[marksArrayDatesDefaults objectAtIndex:i];
                    dateBeingDrawnOnTile=dateToMarkOnTile;
                    NSDateComponents *thisDateComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:dateToMarkOnTile];
                    NSInteger thisDate  = [thisDateComponents day];
                    NSInteger thisMonth = [thisDateComponents month];
                    NSInteger thisYear  = [thisDateComponents year];
                    
                    if (thisMonth==thisMonthMonth && thisYear==thisYearYear)
                    {
                        
                        [self markDay:thisDate];
                        
                    }
                    else
                    {
                        NSString *imageStr=@"TapkuLibrary.bundle/Images/calendar/selected.png";
                        if (firstOfPrev<=thisDate && thisDate<=lastOfPrev) {
                            NSInteger position=thisDate-lastOfPrev;
                            [self markDayInPositionWithDayAndImage:position :thisDate :imageStr];
                        }
                        else {
                            NSInteger position=thisDate+daysInMonth;
                            [self selectDayInPositionWithDay:position:thisDate];
                        }
                        
                        
                        
                    }
                }
                [defaults setBool:TRUE forKey:@"tempBool"];
                [defaults synchronize];
                
                
            }
            else if ([marksArrayDefaults count]==1)
            {
                
                NSMutableArray *marksArrayDatesDefaults=[defaults objectForKey: @"marksArrayDatesDefaults"];
                NSDate *dateToMarkOnTile=[marksArrayDatesDefaults objectAtIndex:0];
                dateBeingDrawnOnTile=dateToMarkOnTile;
                NSDateComponents *thisDateComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:dateToMarkOnTile];
                
                NSInteger thisDate  = [thisDateComponents day];
                NSInteger thisMonth = [thisDateComponents month];
                NSInteger thisYear  = [thisDateComponents year];
                
                if (thisMonth==thisMonthMonth && thisYear==thisYearYear)
                {
                    [self selectDay:thisDate];
                    
                }
                else
                {
                    if (firstOfPrev<=thisDate && thisDate<=lastOfPrev) {
                        NSInteger position=thisDate-lastOfPrev;
                        [self selectDayInPositionWithDay:position:thisDate];
                    }
                    else {
                        NSInteger position=thisDate+daysInMonth;
                        [self selectDayInPositionWithDay:position:thisDate];
                    }
                    
                    
                    
                }
                [defaults setBool:TRUE forKey:@"tempBool"];
                [defaults synchronize];
                
            }
        }
    }

    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    NSLocale *locale=[NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [gregorian setLocale:locale];
    [gregorian setTimeZone:timeZone];
    NSDate *monthValueForDate = monthDate;
    if (monthOfTheDay == Next) {
        monthValueForDate = [gregorian dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:monthDate options:0];
    }
    else if (monthOfTheDay == Previous)
    {
        monthValueForDate = [gregorian dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:monthDate options:0];
    }

    NSDateComponents *monthComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:monthValueForDate];
    NSInteger month=[monthComponents month];
    NSInteger year=[monthComponents year];

    NSString *dateIdentifier = [NSString stringWithFormat:@"%ld-%ld-%ld",(long)day,(long)month,(long)year];

    UIView *view = [[UIView alloc]initWithFrame:y];
    [view setBackgroundColor:[UIColor clearColor]];
    [self addSubview:view];
    [view setAccessibilityLabel:[NSString stringWithFormat:@"uia_tile_view_identifier_%@",dateIdentifier]];
}

- (void) drawRect:(CGRect)rect
{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"tempBool"];
    [defaults synchronize];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIImage *tile = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile.png")];
    CGRect r = CGRectMake(0, 0, CELLWIDTH, 44);
    CGContextDrawTiledImage(context, r, tile.CGImage);
    
    if(today > 0){
        NSInteger pre = firstOfPrev > 0 ? lastOfPrev - firstOfPrev + 1 : 0;
        NSInteger index = today +  pre-1;
        CGRect r =[self rectForCellAtIndex:index];
        r.origin.y -= 7;
        [[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/today.png")] drawInRect:r];
    }
    
    int index = 0;
    
    NSDateComponents *info = [monthDate  dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    info.hour = 0;
    info.minute = 0;
    info.second = 0;
    NSDate *marksDate=nil;
    
    UIFont *font = [UIFont fontWithName:@"OpenSans" size:dateFontSize];//[UIFont boldSystemFontOfSize:dateFontSize];
    UIFont *font2 =[UIFont fontWithName:@"OpenSans" size:dotFontSize];//[UIFont boldSystemFontOfSize:dotFontSize];
    UIColor *color = [UIColor blackColor];
    NSMutableArray *marksArrayDefaults=[NSMutableArray array];
    NSMutableArray *marksArrayDatesDefaults=[NSMutableArray array];
    dotmarksArrayDefaults=[NSMutableArray array];
    if ([marks count] > 1)
    {
        for (int i=0; i<[marks count]; i++)
        {
            if ([[marks objectAtIndex:i]intValue]==1)
            {
                NSInteger count=0;
                if (i>=firstWeekday)
                {
                    if (firstWeekday-2>i)
                    {
                        count=(firstWeekday-2)-i;
                    }
                    else
                    {
                        count=i-(firstWeekday-2);
                    }
                    
                }
                else {
                    count=i-firstWeekday+2;
                }
                if ([marksArrayDefaults count]==0)
                {
                    info.day = count;
                    marksDate= [NSDate dateWithDateComponents:info];
                    [marksArrayDatesDefaults addObject:marksDate];
                    [marksArrayDefaults addObject:[NSNumber numberWithInteger:count]];
                }
                else  if ([marksArrayDefaults count]==1)
                {
                    info.day = count;
                    marksDate= [NSDate dateWithDateComponents:info];
                    [marksArrayDatesDefaults addObject:marksDate];
                    [marksArrayDefaults addObject:[NSNumber numberWithInteger:count]];
                }
                else
                {
                    info.day = count;
                    marksDate= [NSDate dateWithDateComponents:info];
                    [marksArrayDatesDefaults replaceObjectAtIndex:1 withObject:marksDate];
                    [marksArrayDefaults replaceObjectAtIndex:1 withObject:[NSNumber numberWithInteger:count]];
                }
            }
            else if ([[marks objectAtIndex:i]intValue]==-1)
            {
                
                NSInteger count=i-firstWeekday+2;
                [dotmarksArrayDefaults addObject:[NSNumber numberWithInteger: count]];
                [self addColoredImageToTileForImageWithDay:count forImageName:nil ];
            }
            
        }
    }
    
    
    
    
    [[NSUserDefaults standardUserDefaults]  removeObjectForKey:@"marksArrayDefaults"];
    [[NSUserDefaults standardUserDefaults]  removeObjectForKey:@"marksArrayDatesDefaults"];
    [[NSUserDefaults standardUserDefaults] setObject:marksArrayDatesDefaults forKey:@"marksArrayDatesDefaults"];
    [[NSUserDefaults standardUserDefaults] setObject:marksArrayDefaults forKey:@"marksArrayDefaults"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    if(firstOfPrev>0){
        [color set];
        for(NSInteger i = firstOfPrev;i<= lastOfPrev;i++){
            BOOL weekend=NO;
            weekend=[self checkWhetherWeekEndDateForIndex:index];
            r = [self rectForCellAtIndex:index];
            r.origin.x=r.origin.x-6;
            r.origin.y=r.origin.y-3;
            if ([marks count] > 0)
            {
                [self drawTileInRect:r day:i mark:[[marks objectAtIndex:index] boolValue] font:font font2:font2 monthOfTheDay:Previous isWeekEnd:weekend];
            }
            
            else
                [self drawTileInRect:r day:i mark:NO font:font font2:font2 monthOfTheDay:Previous isWeekEnd:weekend];
            index++;
        }
        
    }
    
    
    color = [UIColor blackColor];//[UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1];
    [color set];
    for(int i=1; i <= daysInMonth; i++){
        BOOL weekend=NO;
        weekend=[self checkWhetherWeekEndDateForIndex:index];
        r = [self rectForCellAtIndex:index];
        r.origin.x=r.origin.x-6;
        r.origin.y=r.origin.y-3;
        if(today == i) [[UIColor whiteColor] set];
        
        if ([marks count] > 0)
            [self drawTileInRect:r day:i mark:[[marks objectAtIndex:index] boolValue] font:font font2:font2 monthOfTheDay:Current isWeekEnd:weekend];
        else
            [self drawTileInRect:r day:i mark:NO font:font font2:font2 monthOfTheDay:Current isWeekEnd:weekend];
        if(today == i) [color set];
        index++;
    }
    
    
    [[UIColor grayColor] set];
    int i = 1;
    int tempDayDenominator;
    BOOL showCompleteGridCalendar=showGridCalendar;
    

    if (showCompleteGridCalendar)
        tempDayDenominator=42;
    else
        tempDayDenominator=7;
    
    while(index % tempDayDenominator != 0){
        BOOL weekend=NO;isTodayDayFromNextMonthDate=YES;
        weekend=[self checkWhetherWeekEndDateForIndex:index];
        r = [self rectForCellAtIndex:index] ;
        r.origin.x=r.origin.x-6;
        r.origin.y=r.origin.y-3;
        if ([marks count] > 0)
            [self drawTileInRect:r day:i mark:[[marks objectAtIndex:index] boolValue] font:font font2:font2 monthOfTheDay:Next isWeekEnd:weekend];
        else
            [self drawTileInRect:r day:i mark:NO font:font font2:font2 monthOfTheDay:Next isWeekEnd:weekend];
        i++;
        index++;
    }
    
    
    
    
    
    
}

-(NSDate *)changeDateToDay:(int)day forDate:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSLocale *locale=[NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [gregorian setLocale:locale];
    [gregorian setTimeZone:timeZone];
    NSDateComponents *todayComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    
    NSInteger theMonth = [todayComponents month];
    NSInteger theYear = [todayComponents year];
    
    // now build a NSDate object for yourDate using these components
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:day];
    [components setMonth:theMonth];
    [components setYear:theYear];
    NSDate *thisDate = [gregorian dateFromComponents:components];
    
    
    // now build a NSDate object for the next day
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:1];
    NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    
    
    return nextDate;
}

-(void)addColoredImageToTileForImageWithDay:(NSInteger)day forImageName:(NSString *)imageStr
{
    NSInteger pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
    NSInteger tot = day + pre;
    NSInteger row = tot / 7;
    NSInteger column = (tot % 7)-1;
    
    TKCalendarMonthTiles *deliveryTile = [[TKCalendarMonthTiles alloc] init];
    
    if (imageStr!=nil)
    {
        deliveryTile.selectedImageView.image =  [UIImage imageWithContentsOfFile:TKBUNDLE(imageStr)];
        
    }
    
    if(column < 0){
        column = 6;
        row--;
    }
    
    CGRect r = deliveryTile.selectedImageView.frame;
    r.origin.x = (column*CELLWIDTH);
    r.origin.y = (row*44)-1;
    deliveryTile.selectedImageView.frame = r;
    
    if (day>0)
        deliveryTile.selectedImageView.tag=day;
    else
        deliveryTile.selectedImageView.tag=day-1;
    
    [self addSubview:deliveryTile.selectedImageView];
    if (imageStr!=nil)
    {
        deliveryTile.selectedImageView.alpha=0.5;
    }
    else
    {
        deliveryTile.selectedImageView.alpha=0.2;
    }
    
    
    
    
    
}

-(void)addApprovedOrRejectedImageToTileWithDayInPosition:(NSInteger)day inPosition:(NSInteger)position withImage:(NSString *)imageStr
{
    NSInteger pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
    NSInteger tot = position + pre;
    NSInteger row = tot / 7;
    NSInteger column = (tot % 7)-1;
    
    TKCalendarMonthTiles *deliveryTile = [[TKCalendarMonthTiles alloc] init];
    
    if (imageStr!=nil)
    {
        deliveryTile.selectedImageView.image =  [UIImage imageWithContentsOfFile:TKBUNDLE(imageStr)];
        
    }
    deliveryTile.currentDay.text = [NSString stringWithFormat:@"%ld",(long)day];
    if(column < 0){
        column = 6;
        row--;
    }
    
    CGRect r = deliveryTile.selectedImageView.frame;
    r.origin.x = (column*CELLWIDTH);
    r.origin.y = (row*44)-1;//Changed To avoid Bottom coloring
    deliveryTile.selectedImageView.frame = r;
    deliveryTile.currentDay.backgroundColor=[UIColor clearColor];
    if ([imageStr isEqualToString:TIMEOFF_HOLIDAY_IMAGE]) {
        deliveryTile.currentDay.textColor=[UIColor colorWithRed:59/255. green:73/255. blue:88/255. alpha:1.0];
        deliveryTile.currentDay.shadowColor=[UIColor clearColor];
    }
    r.size.height=dateFontSize;
    r.size.width=r.size.width-6;
    r.origin.y=r.origin.y+6;
    deliveryTile.currentDay.frame = r;
    [self addSubview:deliveryTile.selectedImageView];
    [self addSubview:deliveryTile.currentDay];
    if (imageStr!=nil)
    {
        deliveryTile.selectedImageView.alpha=1.0;
    }
    else
    {
        deliveryTile.selectedImageView.alpha=0.2;
    }
    
    deliveryTile.selectedImageView.tag=100;
    deliveryTile.currentDay.tag=101;
    
    
    
    
}

- (void)markDayInPositionWithDay:(NSInteger)position :(NSInteger)day {
    
    // First, remove any old subviews
    
    [[self viewWithTag:42] removeFromSuperview];
    [[self viewWithTag:43] removeFromSuperview];
    
    NSInteger pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
    NSInteger tot = position + pre;
    NSInteger row = tot / 7;
    NSInteger column = (tot % 7)-1;
    
    TKCalendarMonthTiles *deliveryTile = [[TKCalendarMonthTiles alloc] init];
    
    NSDate *localMonthDate=[self changeDateToDay:28 forDate:monthDate];
    NSDateComponents *info = [localMonthDate dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    info.hour = 0;
    info.minute = 0;
    info.second = 0;
    info.day = 28;
    NSDate *currentMonthDate = [NSDate dateWithDateComponents:info];
    
    NSDate *prevMonthDate=[currentMonthDate previousMonth];
    
    NSInteger preDayCnt = [prevMonthDate daysBetweenDate:currentMonthDate];
    
    if (day<1)
    {
        day=preDayCnt+day;
    }
    
    deliveryTile.currentDay.text = [NSString stringWithFormat:@"%ld",(long)day];
    
    if(column < 0){
        column = 6;
        row--;
    }
    
    
    deliveryTile.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png")];
    
    CGRect r = deliveryTile.selectedImageView.frame;
    r.origin.x = (column*CELLWIDTH);
    r.origin.y = (row*44)-1;
    deliveryTile.selectedImageView.frame = r;
    deliveryTile.currentDay.backgroundColor=[UIColor clearColor];
    r.size.height=dateFontSize;
    r.size.width=r.size.width-6;
    r.origin.y=r.origin.y+6;
    deliveryTile.currentDay.frame = r;
    
    [[deliveryTile selectedImageView] setTag:42];
    [[deliveryTile currentDay] setTag:43];
    [deliveryTile setTag:day];
    [self addSubview:deliveryTile.selectedImageView];
    [self addSubview:deliveryTile.currentDay];
    BOOL showDotOnTile=[self checkWhetherToShowDotOnDate];
    if (showDotOnTile)
    {
        [deliveryTile.selectedImageView addSubview:deliveryTile.dot];
    }
    
    
}
- (void)markDayInPositionWithDayAndImage:(NSInteger)position :(NSInteger)day :(NSString *)imageStr{
    
    // First, remove any old subviews
    
    [[self viewWithTag:42] removeFromSuperview];
    [[self viewWithTag:43] removeFromSuperview];
    
    NSInteger pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
    NSInteger tot = position + pre;
    NSInteger row = tot / 7;
    NSInteger column = (tot % 7)-1;
    
    TKCalendarMonthTiles *deliveryTile = [[TKCalendarMonthTiles alloc] init];
    
    NSDate *localMonthDate=[self changeDateToDay:28 forDate:monthDate];
    NSDateComponents *info = [localMonthDate dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    info.hour = 0;
    info.minute = 0;
    info.second = 0;
    info.day = 28;
    NSDate *currentMonthDate = [NSDate dateWithDateComponents:info];
    
    NSDate *prevMonthDate=[currentMonthDate previousMonth];
    
    NSInteger preDayCnt = [prevMonthDate daysBetweenDate:currentMonthDate];
    
    if (day<1)
    {
        day=preDayCnt+day;
    }
    
    deliveryTile.currentDay.text = [NSString stringWithFormat:@"%ld",(long)day];
    
    if(column < 0){
        column = 6;
        row--;
    }
    
    
    deliveryTile.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(imageStr)];
    
    CGRect r = deliveryTile.selectedImageView.frame;
    r.origin.x = (column*CELLWIDTH);
    r.origin.y = (row*44)-1;
    deliveryTile.selectedImageView.frame = r;
    deliveryTile.currentDay.backgroundColor=[UIColor clearColor];
    r.size.height=dateFontSize;
    r.size.width=r.size.width-6;
    r.origin.y=r.origin.y+6;
    deliveryTile.currentDay.frame = r;
    
    [[deliveryTile selectedImageView] setTag:42];
    [[deliveryTile currentDay] setTag:43];
    [deliveryTile setTag:day];
    [self addSubview:deliveryTile.selectedImageView];
    [self addSubview:deliveryTile.currentDay];
    BOOL showDotOnTile=[self checkWhetherToShowDotOnDate];
    if (showDotOnTile)
    {
        [deliveryTile.selectedImageView addSubview:deliveryTile.dot];
    }
    
    
}


- (void)markDayWithImage:(NSInteger)day :(NSString *)imageStr{
    
    // First, remove any old subviews
    
    //[[self viewWithTag:42] removeFromSuperview];
    //[[self viewWithTag:43] removeFromSuperview];
    
    NSInteger pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
    NSInteger tot = day + pre;
    NSInteger row = tot / 7;
    NSInteger column = (tot % 7)-1;
    
    TKCalendarMonthTiles *deliveryTile = [[TKCalendarMonthTiles alloc] init];
    
    NSDate *localMonthDate=[self changeDateToDay:28 forDate:monthDate];
    NSDateComponents *info = [localMonthDate dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    info.hour = 0;
    info.minute = 0;
    info.second = 0;
    info.day = 28;
    NSDate *currentMonthDate = [NSDate dateWithDateComponents:info];
    
    NSDate *prevMonthDate=[currentMonthDate previousMonth];
    
    NSInteger preDayCnt = [prevMonthDate daysBetweenDate:currentMonthDate];
    
    if (day<1)
    {
        day=preDayCnt+day;
    }
    
    deliveryTile.currentDay.text = [NSString stringWithFormat:@"%ld",(long)day];
    
    if(column < 0){
        column = 6;
        row--;
    }
    
    
    deliveryTile.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(imageStr)];
    
    CGRect r = deliveryTile.selectedImageView.frame;
    r.origin.x = (column*CELLWIDTH);
    r.origin.y = (row*44)-1;
    deliveryTile.selectedImageView.frame = r;
    deliveryTile.currentDay.backgroundColor=[UIColor clearColor];
    r.size.height=dateFontSize;
    r.size.width=r.size.width-6;
    r.origin.y=r.origin.y+6;
    deliveryTile.currentDay.frame = r;
    
    [[deliveryTile selectedImageView] setTag:42];
    [[deliveryTile currentDay] setTag:43];
    [deliveryTile setTag:day];
    BOOL showDotOnTile=[self checkWhetherToShowDotOnDate];
    if (showDotOnTile)
    {
        [deliveryTile.selectedImageView addSubview:deliveryTile.dot];
    }
    [self addSubview:deliveryTile.selectedImageView];
    [self addSubview:deliveryTile.currentDay];
    
    
    
}

- (void)markDay:(NSInteger)day {
    
    // First, remove any old subviews
    //Ullas M L Changed
    //[[self viewWithTag:42] removeFromSuperview];
    //[[self viewWithTag:43] removeFromSuperview];
    
    NSInteger pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
    NSInteger tot = day + pre;
    NSInteger row = tot / 7;
    NSInteger column = (tot % 7)-1;
    
    TKCalendarMonthTiles *deliveryTile = [[TKCalendarMonthTiles alloc] init];
    
    NSDate *localMonthDate=[self changeDateToDay:28 forDate:monthDate];
    NSDateComponents *info = [localMonthDate dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    info.hour = 0;
    info.minute = 0;
    info.second = 0;
    info.day = 28;
    NSDate *currentMonthDate = [NSDate dateWithDateComponents:info];
    
    NSDate *prevMonthDate=[currentMonthDate previousMonth];
    
    NSInteger preDayCnt = [prevMonthDate daysBetweenDate:currentMonthDate];
    
    if (day<1)
    {
        day=preDayCnt+day;
    }
    
    deliveryTile.currentDay.text = [NSString stringWithFormat:@"%ld",(long)day];
    
    if(column < 0){
        column = 6;
        row--;
    }
    
    //Ullas M L Changed
    //deliveryTile.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png")];
    
    deliveryTile.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/selected.png")];
    
    CGRect r = deliveryTile.selectedImageView.frame;
    r.origin.x = (column*CELLWIDTH);
    r.origin.y = (row*44)-1;
    deliveryTile.selectedImageView.frame = r;
    deliveryTile.currentDay.backgroundColor=[UIColor clearColor];
    r.size.height=dateFontSize;
    r.size.width=r.size.width-6;
    r.origin.y=r.origin.y+6;
    deliveryTile.currentDay.frame = r;
    
    [[deliveryTile selectedImageView] setTag:42];
    [[deliveryTile currentDay] setTag:43];
    [deliveryTile setTag:day];
    BOOL showDotOnTile=[self checkWhetherToShowDotOnDate];
    if (showDotOnTile)
    {
        [deliveryTile.selectedImageView addSubview:deliveryTile.dot];
    }
    
    [self addSubview:deliveryTile.selectedImageView];
    [self addSubview:deliveryTile.currentDay];
    
    
    
}
- (void) selectDayInPositionWithDay:(NSInteger)position :(NSInteger)day
{
    NSInteger pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
    NSInteger tot = position + pre;
    NSInteger row = tot / 7;
    NSInteger column = (tot % 7)-1;
    
    selectedDay = day;
    selectedPortion = 1;
    
    
    
    
    if(day == today){
        self.currentDay.shadowOffset = CGSizeMake(0, 1);
        self.dot.shadowOffset = CGSizeMake(0, 1);
        self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/todaySelected.png")];
        markWasOnToday = YES;
    }else if(markWasOnToday){
        self.dot.shadowOffset = CGSizeMake(0, -1);
        self.currentDay.shadowOffset = CGSizeMake(0, -1);
        
        self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/selected.png")];
        markWasOnToday = NO;
    }
    
    [self addSubview:self.selectedImageView];
    
    
    NSDate *localMonthDate=[self changeDateToDay:28 forDate:monthDate];
    NSDateComponents *info = [localMonthDate dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    info.hour = 0;
    info.minute = 0;
    info.second = 0;
    info.day = 28;
    NSDate *currentMonthDate = [NSDate dateWithDateComponents:info];
    
    if ([dotmarksArrayDefaults count]>0 )
    {
        NSDate *prevMonthDate=nil;
        NSInteger preDayCnt =0;
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"PREVIOUS_CLICKED"])
        {
            prevMonthDate=[currentMonthDate nextMonth];
            preDayCnt = [currentMonthDate daysBetweenDate:prevMonthDate];
        }
        else
        {
            prevMonthDate=[currentMonthDate nextMonth];
            preDayCnt = [currentMonthDate daysBetweenDate:prevMonthDate];
        }
        
        
        if (day>preDayCnt)
        {
            day=day-preDayCnt;
        }
        else if (day==0)
        {
            day=lastOfPrev-day;
        }
        else if (day<0)
        {
            day=lastOfPrev+day;
        }
        
    }
    
    
    else
    {
        NSDate *prevMonthDate=[currentMonthDate previousMonth];
        
        NSInteger preDayCnt = [prevMonthDate daysBetweenDate:currentMonthDate];
        
        if (day<1)
        {
            day=preDayCnt+day;
        }
    }
    self.currentDay.text = [NSString stringWithFormat:@"%ld",(long)day];
    
    CGRect currentDayLblFrame=self.currentDay.frame;
    self.currentDay.backgroundColor=[UIColor clearColor];
    currentDayLblFrame.size.height=dateFontSize;
    //    currentDayLblFrame.size.width=currentDayLblFrame.size.width-17;
    currentDayLblFrame.size.width=CELLWIDTH-6;
    //    currentDayLblFrame.origin.y=currentDayLblFrame.origin.y+9;
    currentDayLblFrame.origin.y=6.0;
    self.currentDay.frame = currentDayLblFrame;
    
    if ([marks count] > 0)
    {
        BOOL showDotOnTile=[self checkWhetherToShowDotOnDate];
        if (showDotOnTile)
        {
            [self.selectedImageView addSubview:self.dot];
        }
        else {
            [self.dot removeFromSuperview];
        }
        
        
    }
    else
    {
        [self.dot removeFromSuperview];
    }
    
    
    if(column < 0){
        column = 6;
        row--;
    }
    
    CGRect r = self.selectedImageView.frame;
    r.origin.x = (column*CELLWIDTH);
    r.origin.y = (row*44)-1;
    
    self.selectedImageView.frame = r;
    
}
- (void) selectDay:(NSInteger)day{
    
    NSInteger pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
    NSInteger tot = day + pre;
    NSInteger row = tot / 7;
    NSInteger column = (tot % 7)-1;
    
    selectedDay = day;
    selectedPortion = 1;
    
    
    if(day == today){
        self.currentDay.shadowOffset = CGSizeMake(0, 1);
        self.dot.shadowOffset = CGSizeMake(0, 1);
        self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/todaySelected.png")];
        markWasOnToday = YES;
    }else if(markWasOnToday){
        self.dot.shadowOffset = CGSizeMake(0, -1);
        self.currentDay.shadowOffset = CGSizeMake(0, -1);
        
        self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/selected.png")];
        markWasOnToday = NO;
    }
    
    [self addSubview:self.selectedImageView];
    
    
    NSDate *localMonthDate=[self changeDateToDay:28 forDate:monthDate];
    NSDateComponents *info = [localMonthDate dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    info.hour = 0;
    info.minute = 0;
    info.second = 0;
    info.day = 28;
    NSDate *currentMonthDate = [NSDate dateWithDateComponents:info];
    
    if ([dotmarksArrayDefaults count]>0 )
    {
        NSDate *prevMonthDate=nil;
        NSInteger preDayCnt =0;
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"PREVIOUS_CLICKED"])
        {
            prevMonthDate=[currentMonthDate nextMonth];
            preDayCnt = [currentMonthDate daysBetweenDate:prevMonthDate];
        }
        else
        {
            prevMonthDate=[currentMonthDate nextMonth];
            preDayCnt = [currentMonthDate daysBetweenDate:prevMonthDate];
        }
        
        
        if (day>preDayCnt)
        {
            day=day-preDayCnt;
        }
        else if (day==0)
        {
            day=lastOfPrev-day;
        }
        else if (day<0)
        {
            day=lastOfPrev+day;
        }
        
    }
    
    
    else
    {
        NSDate *prevMonthDate=[currentMonthDate previousMonth];
        
        NSInteger preDayCnt = [prevMonthDate daysBetweenDate:currentMonthDate];
        
        if (day<1)
        {
            day=preDayCnt+day;
        }
    }
    self.currentDay.text = [NSString stringWithFormat:@"%ld",(long)day];
    
    CGRect currentDayLblFrame=self.currentDay.frame;
    self.currentDay.backgroundColor=[UIColor clearColor];
    currentDayLblFrame.size.height=dateFontSize;
    //    currentDayLblFrame.size.width=currentDayLblFrame.size.width-17;
    currentDayLblFrame.size.width=CELLWIDTH-6;
    //    currentDayLblFrame.origin.y=currentDayLblFrame.origin.y+9;
    currentDayLblFrame.origin.y=6.0;
    self.currentDay.frame = currentDayLblFrame;
    
    
    if ([marks count] > 0)
    {
        BOOL showDotOnTile=[self checkWhetherToShowDotOnDate];
        if (showDotOnTile)
        {
            [self.selectedImageView addSubview:self.dot];
        }
        else {
            [self.dot removeFromSuperview];
        }
        
    }
    else
    {
        [self.dot removeFromSuperview];
    }
    
    
    if(column < 0){
        column = 6;
        row--;
    }
    
    CGRect r = self.selectedImageView.frame;
    r.origin.x = (column*CELLWIDTH);
    r.origin.y = (row*44)-1;
    self.selectedImageView.frame = r;
    
    
}
- (NSDate*) dateSelected{
    if(selectedDay < 1 || selectedPortion != 1) return nil;
    
     NSDateComponents *info = [monthDate dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    info.hour = 0;
    info.minute = 0;
    info.second = 0;
    info.day = selectedDay;
    NSDate *d = [NSDate dateWithDateComponents:info];
    
    
    
    return d;
    
}

-(void)addColoredImageToTileForSwipe:(int)startDay :(int)endDay :(NSString *)imageStr
{
    
    for (int i=startDay; i<=endDay; i++)
    {
        
        NSInteger pre = firstOfPrev < 0 ?  0 : lastOfPrev - firstOfPrev + 1;
        NSInteger tot = i + pre;
        NSInteger row = tot / 7;
        NSInteger column = (tot % 7)-1;
        
        TKCalendarMonthTiles *deliveryTile = [[TKCalendarMonthTiles alloc] init];
        
        if (imageStr!=nil)
        {
            deliveryTile.selectedImageView.image =  [UIImage imageWithContentsOfFile:TKBUNDLE(imageStr)];
        }
        
        if(column < 0){
            column = 6;
            row--;
        }
        
        CGRect r = deliveryTile.selectedImageView.frame;
        r.origin.x = (column*CELLWIDTH);
        r.origin.y = (row*44)-1;
        deliveryTile.selectedImageView.frame = r;
        deliveryTile.selectedImageView.alpha=0.2;
        BOOL checkIsViewAlreadyPresent=NO;
        for (UIView *view in self.subviews) {
            if (view.tag==i)
                checkIsViewAlreadyPresent=YES;
        }
        if (i==0) {
            checkIsViewAlreadyPresent=NO;
        }
        if (checkIsViewAlreadyPresent==NO) {
            [self addSubview:deliveryTile.selectedImageView];
            deliveryTile.selectedImageView.tag=i;
        }
        
    }
    
    
}

-(void) deleteColoredImageToTileForSwipeWithStartDay:(int)startDay andEndDay:(int)endDay withImage:(NSString *)imageStr{
    
    if (startDay==endDay+1)
    {
        if (startDay-1!=0) {
            [[self viewWithTag:startDay]  removeFromSuperview];
            [[self viewWithTag:startDay-1]  removeFromSuperview];
        }
    }
    else
    {
        for (int i=startDay; i<=endDay; i++)
        {
            if (i!=0)
                [[self viewWithTag:i]  removeFromSuperview];
        }
        
    }
    
}

-(NSDate *)getDateForSelectedPortion:(int)portion withDay:(int)day
{
    NSDate *date=nil;
    if(portion==0)
    {
        
        NSDateComponents *info = [[monthDate previousMonth] dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        info.hour = 0;
        info.minute = 0;
        info.second = 0;
        info.day = day;
        date = [NSDate dateWithDateComponents:info];
        
    }
    else if (portion==1) {
        
        NSDateComponents *info = [monthDate dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        info.hour = 0;
        info.minute = 0;
        info.second = 0;
        info.day = day;
        date = [NSDate dateWithDateComponents:info];
        
    }
    else
    {
       ;
        NSDateComponents *info = [[monthDate nextMonth] dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        info.hour = 0;
        info.minute = 0;
        info.second = 0;
        info.day = day;
        date = [NSDate dateWithDateComponents:info];
        
    }
    return date;
    
}

-(NSInteger)getIntegerDayForDate:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSLocale *locale=[NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [gregorian setLocale:locale];
    [gregorian setTimeZone:timeZone];
    NSDateComponents *todayComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    
    NSInteger theDay = [todayComponents day];
    return theDay;
}
-(NSInteger)getIntegerMonthForDate:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSLocale *locale=[NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [gregorian setLocale:locale];
    [gregorian setTimeZone:timeZone];
    NSDateComponents *todayComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    
    NSInteger theMonth = [todayComponents month];
    return theMonth;
}
-(NSInteger)getIntegerYearForDate:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSLocale *locale=[NSLocale currentLocale];
    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    [gregorian setLocale:locale];
    [gregorian setTimeZone:timeZone];
    NSDateComponents *todayComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    
    NSInteger theYear = [todayComponents year];
    return theYear;
}



/*- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
 CGPoint p = [[touches anyObject] locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0) return;
	
	int column = p.x / 46, row = p.y / 44;
	int day = 1, portion = 0;
	
	if(row == (int) (self.bounds.size.height / 44)) row --;
	
	int fir = firstWeekday - 1;
	if(!startOnSunday && fir == 0) fir = 7;
	if(!startOnSunday) fir--;
	
	
	if(row==0 && column < fir){
 day = firstOfPrev + column;
	}else{
 portion = 1;
 day = row * 7 + column  - firstWeekday+2;
 if(!startOnSunday) day++;
 if(!startOnSunday && fir==6) day -= 7;
 
	}
	if(portion > 0 && day > daysInMonth){
 portion = 2;
 day = day - daysInMonth;
	}
	
	
	if(portion != 1){
 self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png")];
 markWasOnToday = YES;
	}else if(portion==1 && day == today){
 self.currentDay.shadowOffset = CGSizeMake(0, 1);
 self.dot.shadowOffset = CGSizeMake(0, 1);
 self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/todaySelected.png")];
 markWasOnToday = YES;
	}else if(markWasOnToday){
 self.dot.shadowOffset = CGSizeMake(0, -1);
 self.currentDay.shadowOffset = CGSizeMake(0, -1);
 self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/selected.png")];
 markWasOnToday = NO;
	}
 self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/selected.png")];
	[self addSubview:self.selectedImageView];
	self.currentDay.text = [NSString stringWithFormat:@"%d",day];
 CGRect r = self.selectedImageView.frame;
	r.origin.x = (column*46);
	r.origin.y = (row*44)-1;
	self.selectedImageView.frame = r;
 
 
 
 
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 NSDate *previouslyDateSelected=[defaults objectForKey:@"selectedStartDate"];
 NSDate *recentlyDateSelected=[self getDateForSelectedPortion:portion withDay:day];
 
 if (previouslyDateSelected==nil)
 {
 if (recentlyDateSelected!=nil) {
 self.temporaryStartDate=recentlyDateSelected;
 self.temporaryActiveDate=recentlyDateSelected;
 [defaults setObject:recentlyDateSelected forKey:@"selectedStartDate"];
 [defaults setObject:recentlyDateSelected forKey:@"selectedEndDate"];
 [defaults synchronize];
 [self markDay:day];
 [self selectDay:day];
 }
 }
 else
 {
 
 if ([previouslyDateSelected compare:recentlyDateSelected]==NSOrderedSame)
 {
 
 
 self.temporaryStartDate=[defaults objectForKey:@"selectedStartDate"];
 self.temporaryActiveDate=[defaults objectForKey:@"selectedEndDate"];
 NSDate *tempDate=self.temporaryStartDate;
 self.temporaryStartDate=self.temporaryActiveDate;
 self.temporaryActiveDate=tempDate;
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 
 
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 NSMutableArray *marksArrayDatesDefaults=[defaults objectForKey: @"marksArrayDatesDefaults"];
 
 if ([marksArrayDatesDefaults count]==2) {
 
 NSDate *tempStartDate=[marksArrayDatesDefaults objectAtIndex:0];
 NSDate *tempActiveDate=[marksArrayDatesDefaults objectAtIndex:1];
 NSDate *date=[self getDateForSelectedPortion:portion withDay:day];
 int presentMonth=[self getIntegerMonthForDate:monthDate];
 int presentYear=[self getIntegerYearForDate:monthDate];
 
 if ([date compare:tempStartDate]==NSOrderedSame)
 {
 
 int activeDay=[self getIntegerDayForDate:tempActiveDate];
 int activeMonth=[self getIntegerMonthForDate:tempActiveDate];
 int activeYear=[self getIntegerYearForDate:tempActiveDate];
 
 if (activeMonth==presentMonth && activeYear==presentYear) {
 [self markDay:activeDay];
 }
 else
 {
 if (firstOfPrev<=activeDay && activeDay<=lastOfPrev) {
 int position=activeDay-lastOfPrev;
 [self markDayInPositionWithDay:position:activeDay];
 }
 else {
 int position=activeDay+daysInMonth;
 [self markDayInPositionWithDay:position:activeDay];
 }
 }
 
 }
 else
 {
 
 int startDay=[self getIntegerDayForDate:tempStartDate];
 int startMonth=[self getIntegerMonthForDate:tempStartDate];
 int startYear=[self getIntegerYearForDate:tempStartDate];
 
 if (startMonth==presentMonth && startYear==presentYear) {
 [self markDay:startDay];
 }
 else
 {
 if (firstOfPrev<=startDay && startDay<=lastOfPrev) {
 int position=startDay-lastOfPrev;
 [self markDayInPositionWithDay:position:startDay];
 }
 else {
 int position=startDay+daysInMonth;
 [self markDayInPositionWithDay:position:startDay];
 }
 }
 }
 }
 
 
 
 }
 else
 {
 self.temporaryStartDate=[defaults objectForKey:@"selectedStartDate"];
 self.temporaryActiveDate=[defaults objectForKey:@"selectedEndDate"];
 
 }
 
 }
 
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 
 
 
 
 int tempSelectedDay=[self getIntegerDayForDate:self.temporaryActiveDate];
 int tempSelectedMonth=[self getIntegerMonthForDate:self.temporaryActiveDate];
 int thisMonth=[self getIntegerMonthForDate:monthDate];
 
 if (portion==1)
 {
 
 NSString *imageStr=@"TapkuLibrary.bundle/Images/calendar/selected.png";
 if ([self.temporaryStartDate compare:self.temporaryActiveDate]==NSOrderedDescending)
 {
 
 if ([recentlyDateSelected compare:self.temporaryStartDate]==NSOrderedDescending) {
 
 int tempStartDay=[self getIntegerDayForDate:recentlyDateSelected];
 [self markDayWithImage:tempStartDay:imageStr];
 
 }
 if (tempSelectedMonth==thisMonth){
 if (tempSelectedDay>day) {
 [self addColoredImageToTileForSwipe:day :tempSelectedDay  :imageStr];
 }
 else {
 [self deleteColoredImageToTileForSwipe:tempSelectedDay :day :nil];
 }
 }
 else{
 
 int start=[self getIntegerDayForDate:self.temporaryActiveDate];
 int end=[self getIntegerDayForDate:recentlyDateSelected];
 int startMonth=[self getIntegerMonthForDate:self.temporaryActiveDate];
 int endMonth=[self getIntegerMonthForDate:recentlyDateSelected];
 
 if (startMonth==endMonth) {
 if ([recentlyDateSelected compare:self.temporaryStartDate]==NSOrderedAscending)
 {
 [self deleteColoredImageToTileForSwipe:start-lastOfPrev :end :nil];
 }
 }
 else{
 
 if ([recentlyDateSelected compare:self.temporaryStartDate]==NSOrderedAscending)
 {
 if ([recentlyDateSelected compare:self.temporaryActiveDate]==NSOrderedAscending) {
 [self addColoredImageToTileForSwipe:day :daysInMonth+start  :imageStr];
 }
 else{
 //int startDay=[self getIntegerDayForDate:self.temporaryStartDate];
 //[self markDay:startDay];
 [self deleteColoredImageToTileForSwipe:firstOfPrev-lastOfPrev :end :nil];
 
 }
 }
 }
 
 
 
 }
 
 
 }
 else if ([self.temporaryStartDate compare:self.temporaryActiveDate]==NSOrderedAscending) {
 
 if ([recentlyDateSelected compare:self.temporaryStartDate]==NSOrderedAscending) {
 
 int tempStartDay=[self getIntegerDayForDate:recentlyDateSelected];
 [self markDayWithImage:tempStartDay:imageStr];
 
 }
 
 if (tempSelectedMonth==thisMonth)
 {
 if (tempSelectedDay<day) {
 [self addColoredImageToTileForSwipe:tempSelectedDay :day  :imageStr];
 }
 else {
 [self deleteColoredImageToTileForSwipe:day :tempSelectedDay :nil];
 }
 
 }
 else
 {
 int start=[self getIntegerDayForDate:self.temporaryActiveDate];
 int end=[self getIntegerDayForDate:recentlyDateSelected];
 int startMonth=[self getIntegerMonthForDate:self.temporaryActiveDate];
 int endMonth=[self getIntegerMonthForDate:recentlyDateSelected];
 
 if (startMonth==endMonth) {
 if ([recentlyDateSelected compare:self.temporaryActiveDate]==NSOrderedAscending)
 {
 [self deleteColoredImageToTileForSwipe:day :daysInMonth+start :nil];
 }
 }
 else{
 
 if ([recentlyDateSelected compare:self.temporaryStartDate]==NSOrderedDescending)
 {
 if ([recentlyDateSelected compare:self.temporaryActiveDate]==NSOrderedDescending) {
 [self addColoredImageToTileForSwipe:-firstOfPrev :end  :imageStr];
 }
 else{
 //int startDay=[self getIntegerDayForDate:self.temporaryStartDate];
 //[self markDay:startDay];
 [self deleteColoredImageToTileForSwipe:end :daysInMonth+start :nil];
 }
 }
 
 }
 
 }
 
 }
 else {
 
 if (tempSelectedMonth==thisMonth)
 {
 
 int startDay=[self getIntegerDayForDate:self.temporaryStartDate];
 [self markDay:startDay];
 if (tempSelectedDay>day) {
 [self addColoredImageToTileForSwipe:day :tempSelectedDay  :imageStr];
 }
 else if (tempSelectedDay<day) {
 [self addColoredImageToTileForSwipe:tempSelectedDay :day  :imageStr];
 }
 }
 else
 {
 
 int start=[self getIntegerDayForDate:self.temporaryStartDate];
 int end=[self getIntegerDayForDate:recentlyDateSelected];
 if ([recentlyDateSelected compare:self.temporaryStartDate]==NSOrderedDescending)
 {
 [self addColoredImageToTileForSwipe:start-lastOfPrev :end :nil];
 }
 else
 {
 [self addColoredImageToTileForSwipe:end :start+daysInMonth :nil];
 }
 }
 }
 
 
 }
 else
 {
 
 
 int activeDay=[self getIntegerDayForDate:self.temporaryActiveDate];
 int activeMonth=[self getIntegerMonthForDate:self.temporaryActiveDate];
 int activeYear=[self getIntegerYearForDate:self.temporaryActiveDate];
 int presentMonth=[self getIntegerMonthForDate:monthDate];
 int presentYear=[self getIntegerYearForDate:monthDate];
 
 if (activeMonth==presentMonth && activeYear==presentYear)
 {
 [self selectDay:activeDay];
 }
 else
 {
 if (firstOfPrev<=activeDay && activeDay<=lastOfPrev) {
 int position=activeDay-lastOfPrev;
 [self selectDayInPositionWithDay:position:activeDay];
 }
 else {
 int position=activeDay+daysInMonth;
 [self selectDayInPositionWithDay:position:activeDay];
 }
 }
 
 }
 
 
 if (portion!=1)
 {
 
 isTouchesBeganFromOtherMonthDate=YES;
 self.temporaryDateOfGradedRegion=[self getDateForSelectedPortion:portion withDay:day];
 //[target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil] withObject:[NSNumber numberWithBool:NO]];
 selectedDay=day;
 selectedPortion=portion;
 
 }
 
 
 selectedDay=day;
 previousRowSelected=row;
 previousColumnSelected=column;
 
 
 }
 
 - (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
 
 CGPoint p = [[touches anyObject] locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0) return;
 
 
 int column = p.x / 46, row = p.y / 44;
	int day = 1, portion = 0;
	
	if(row == (int) (self.bounds.size.height / 44)) row --;
	
	int fir = firstWeekday - 1;
	if(!startOnSunday && fir == 0) fir = 7;
	if(!startOnSunday) fir--;
	
	
	if(row==0 && column < fir){
 day = firstOfPrev + column;
	}else{
 portion = 1;
 day = row * 7 + column  - firstWeekday+2;
 if(!startOnSunday) day++;
 if(!startOnSunday && fir==6) day -= 7;
 
	}
	if(portion > 0 && day > daysInMonth){
 portion = 2;
 day = day - daysInMonth;
	}
	
	
	if(portion != 1){
 self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png")];
 markWasOnToday = YES;
	}else if(portion==1 && day == today){
 self.currentDay.shadowOffset = CGSizeMake(0, 1);
 self.dot.shadowOffset = CGSizeMake(0, 1);
 self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/todaySelected.png")];
 markWasOnToday = YES;
	}else if(markWasOnToday){
 self.dot.shadowOffset = CGSizeMake(0, -1);
 self.currentDay.shadowOffset = CGSizeMake(0, -1);
 self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/selected.png")];
 markWasOnToday = NO;
	}
	[self addSubview:self.selectedImageView];
	self.currentDay.text = [NSString stringWithFormat:@"%d",day];
 CGRect r = self.selectedImageView.frame;
	r.origin.x = (column*46);
	r.origin.y = (row*44)-1;
	self.selectedImageView.frame = r;
 
 NSDate *date=[self getDateForSelectedPortion:portion withDay:day];
 self.temporaryActiveDate=date;
 
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 NSDate *tempStart=[defaults objectForKey:@"selectedStartDate"];
 NSDate *tempActive=[defaults objectForKey:@"selectedEndDate"];
 
 if ([tempStart compare:tempActive]==NSOrderedSame)
 {
 int tempStartPosition=[self getIntegerDayForDate:tempActive];
 int tempStartMonth=[self getIntegerMonthForDate:tempActive];
 int thisMonth=[self getIntegerMonthForDate:monthDate];
 //NSString *imageStr=@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Selected.png";
 //[self addColoredImageToTileForSwipe:tempStartPosition :day :imageStr];
 if (thisMonth==tempStartMonth) {
 [self markDay:tempStartPosition];
 }
 else {
 
 if (firstOfPrev<=tempStartPosition && tempStartPosition<=lastOfPrev) {
 int position=tempStartPosition-lastOfPrev;
 [self markDayInPositionWithDay:position:tempStartPosition];
 }
 else {
 int position=tempStartPosition+daysInMonth;
 [self markDayInPositionWithDay:position:tempStartPosition];
 }
 }
 
 
 }
 
 
 
 if (portion==1)
 {
 if (row!=previousRowSelected || column!=previousColumnSelected)
 {
 if ([self.temporaryStartDate compare:self.temporaryActiveDate]==NSOrderedDescending)
 {
 
 isBackwardSwipe=YES;
 NSString *imageStr=@"TapkuLibrary.bundle/Images/calendar/selected.png";
 
 if (isBackwardSwipe && isForwardSwipe)
 {
 
 if ([target isKindOfClass:[TKCalendarMonthView class]])
 {
 
 self.temporaryStartDate=date;
 self.temporaryActiveDate=date;
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 
 TKCalendarMonthView *calView=(TKCalendarMonthView *)target;
 if([calView.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
 [calView.delegate calendarMonthView:calView didSelectDate:date];
 
 return;
 }
 
 }
 
 if (selectedDay>day)
 {
 
 if ( [tempStart compare:tempActive]==NSOrderedAscending)
 {
 
 self.temporaryStartDate=date;
 self.temporaryActiveDate=date;
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 
 [target performSelector:action withObject:[NSArray arrayWithObject:[NSNumber numberWithInt:day]]withObject:[NSNumber numberWithBool:NO]];
 return;
 }
 else {
 
 if (!isTouchesBeganFromOtherMonthDate && !isTouchesEndReached)
 {
 
 [self addColoredImageToTileForSwipe:day :selectedDay :imageStr];
 }
 else{
 
 NSDate *previouslySelectedDate=[self getDateForSelectedPortion:portion withDay:selectedDay];
 NSDate *recentlySelectedDate=date;
 if ([self.temporaryDateOfGradedRegion compare:self.temporaryActiveDate]==NSOrderedAscending)
 {
 
 if (isFirstTime)
 {
 isFirstTime=NO;
 if (selectedDay<day) {
 
 int start=[self getIntegerDayForDate:previouslySelectedDate];
 int end=[self getIntegerDayForDate:recentlySelectedDate];
 [self addColoredImageToTileForSwipe:start :end:imageStr];
 }
 else {
 
 int end=[self getIntegerDayForDate:recentlySelectedDate];
 int start=[self getIntegerDayForDate:previouslySelectedDate];
 [self deleteColoredImageToTileForSwipe:start-lastOfPrev :end :nil];//changed Ullas
 
 
 }
 
 }
 else {
 if (selectedDay>day) {
 
 int end=[self getIntegerDayForDate:previouslySelectedDate];
 int start=[self getIntegerDayForDate:recentlySelectedDate];
 [self addColoredImageToTileForSwipe:start :end:imageStr];
 }
 else {
 
 int end=[self getIntegerDayForDate:recentlySelectedDate];
 int start=[self getIntegerDayForDate:previouslySelectedDate];
 [self deleteColoredImageToTileForSwipe:start :end :nil];
 }
 }
 
 }
 else {
 
 int start=[self getIntegerDayForDate:self.temporaryDateOfGradedRegion];
 int end=[self getIntegerDayForDate:self.temporaryActiveDate];
 [self addColoredImageToTileForSwipe:end :start+daysInMonth :imageStr];
 }
 
 
 
 
 }
 
 
 }
 
 }
 else
 {
 if (!isTouchesBeganFromOtherMonthDate && !isTouchesEndReached)
 {
 [self deleteColoredImageToTileForSwipe:selectedDay :day :nil];
 }
 else
 {
 
 NSDate *previouslySelectedDate=[self getDateForSelectedPortion:portion withDay:selectedDay];
 NSDate *recentlySelectedDate=date;
 
 if (selectedPortion==2 && portion==1) {
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 NSDate *tempStart=[defaults objectForKey:@"selectedStartDate"];
 NSDate *tempActive=[defaults objectForKey:@"selectedEndDate"];
 
 if (![tempStart compare:tempActive]==NSOrderedSame)
 {
 if ([self.temporaryActiveDate compare:self.temporaryStartDate]==NSOrderedAscending) {
 
 self.temporaryStartDate=date;
 self.temporaryActiveDate=date;
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:tempStart forKey:@"selectedStartDate"];
 [defaults setObject:tempActive forKey:@"selectedEndDate"];
 [defaults synchronize];
 [target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:2],nil] withObject:[NSNumber numberWithBool:NO]];
 return;
 }
 }
 
 
 }
 
 if ([self.temporaryDateOfGradedRegion compare:self.temporaryActiveDate]==NSOrderedAscending) {
 
 if (selectedDay>day) {
 
 int end=[self getIntegerDayForDate:previouslySelectedDate];
 int start=[self getIntegerDayForDate:recentlySelectedDate];
 [self addColoredImageToTileForSwipe:start :end:imageStr];
 }
 else {
 
 int end=[self getIntegerDayForDate:recentlySelectedDate];
 int start=[self getIntegerDayForDate:previouslySelectedDate];
 [self deleteColoredImageToTileForSwipe:start :end :nil];
 }
 
 }
 else {
 
 int start=[self getIntegerDayForDate:self.temporaryDateOfGradedRegion];
 int end=[self getIntegerDayForDate:self.temporaryActiveDate];
 [self addColoredImageToTileForSwipe:end :start+daysInMonth :imageStr];
 [self deleteColoredImageToTileForSwipe:selectedDay :day :nil];
 }
 
 
 
 
 }
 
 }
 
 }
 else if ([self.temporaryStartDate compare:self.temporaryActiveDate]==NSOrderedAscending)
 {
 
 isForwardSwipe=YES;
 NSString *imageStr=@"TapkuLibrary.bundle/Images/calendar/selected.png";
 if (isBackwardSwipe && isForwardSwipe) {
 
 if ([target isKindOfClass:[TKCalendarMonthView class]])
 {
 self.temporaryStartDate=date;
 self.temporaryActiveDate=date;
 
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 
 TKCalendarMonthView *calView=(TKCalendarMonthView *)target;
 if([calView.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
 [calView.delegate calendarMonthView:calView didSelectDate:date];
 return;
 }
 
 }
 if (selectedDay<day)
 {
 
 if ([tempStart compare:tempActive]==NSOrderedDescending) {
 
 self.temporaryStartDate=date;
 self.temporaryActiveDate=date;
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 
 TKCalendarMonthView *calView=(TKCalendarMonthView *)target;
 if([calView.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
 [calView.delegate calendarMonthView:calView didSelectDate:date];
 
 return;
 }
 else {
 if (!isTouchesBeganFromOtherMonthDate && !isTouchesEndReached) {
 
 [self addColoredImageToTileForSwipe:selectedDay :day :imageStr];
 }
 else
 {
 NSDate *previouslySelectedDate=[self getDateForSelectedPortion:portion withDay:selectedDay];
 NSDate *recentlySelectedDate=date;
 
 
 if ([self.temporaryDateOfGradedRegion compare:self.temporaryActiveDate]==NSOrderedDescending)
 {
 if (isFirstTime)
 {
 isFirstTime=NO;
 if (selectedDay>day)
 {
 int start=[self getIntegerDayForDate:previouslySelectedDate];
 int end=[self getIntegerDayForDate:recentlySelectedDate];
 [self addColoredImageToTileForSwipe:start :end:imageStr];
 }
 else {
 int start=[self getIntegerDayForDate:recentlySelectedDate];
 int end=[self getIntegerDayForDate:previouslySelectedDate];
 [self deleteColoredImageToTileForSwipe:start :end :nil];
 }
 
 }
 else {
 if (selectedDay<day) {
 int start=[self getIntegerDayForDate:previouslySelectedDate];
 int end=[self getIntegerDayForDate:recentlySelectedDate];
 [self addColoredImageToTileForSwipe:start :end:imageStr];
 
 }
 else {
 int start=[self getIntegerDayForDate:recentlySelectedDate];
 int end=[self getIntegerDayForDate:previouslySelectedDate];
 [self deleteColoredImageToTileForSwipe:start :end :nil];
 }
 }
 
 
 int start=[self getIntegerDayForDate:recentlySelectedDate];
 int end=[self getIntegerDayForDate:previouslySelectedDate];
 [self deleteColoredImageToTileForSwipe:start :end+daysInMonth :nil];
 [self markDay:[self getIntegerDayForDate:self.temporaryStartDate]];
 
 }
 else {
 int start=[self getIntegerDayForDate:previouslySelectedDate];
 int end=[self getIntegerDayForDate:recentlySelectedDate];
 [self addColoredImageToTileForSwipe:start :end:imageStr];
 }
 
 
 }
 
 }
 
 
 }
 else
 {
 if (!isTouchesBeganFromOtherMonthDate && !isTouchesEndReached) {
 [self deleteColoredImageToTileForSwipe:day :selectedDay :nil];
 }
 else
 {
 NSDate *previouslySelectedDate=[self getDateForSelectedPortion:portion withDay:selectedDay];
 NSDate *recentlySelectedDate=date;
 
 
 if (selectedPortion==0 && portion==1)
 {
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 NSDate *tempStart=[defaults objectForKey:@"selectedStartDate"];
 NSDate *tempActive=[defaults objectForKey:@"selectedEndDate"];
 
 if (![tempStart compare:tempActive]==NSOrderedSame)
 {
 
 
 if ([self.temporaryActiveDate compare:self.temporaryStartDate]==NSOrderedDescending) {
 
 self.temporaryStartDate=date;
 self.temporaryActiveDate=date;
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:tempStart forKey:@"selectedStartDate"];
 [defaults setObject:tempActive forKey:@"selectedEndDate"];
 [defaults synchronize];
 [target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:0],nil] withObject:[NSNumber numberWithBool:NO]];
 return;
 }
 }
 
 
 }
 
 
 if ([self.temporaryDateOfGradedRegion compare:self.temporaryActiveDate]==NSOrderedDescending)
 {
 
 
 if (selectedDay<day) {
 
 int start=[self getIntegerDayForDate:previouslySelectedDate];
 int end=[self getIntegerDayForDate:recentlySelectedDate];
 [self addColoredImageToTileForSwipe:start :end:imageStr];
 }
 else {
 int start=[self getIntegerDayForDate:recentlySelectedDate];
 int end=[self getIntegerDayForDate:previouslySelectedDate];
 [self deleteColoredImageToTileForSwipe:start :end :nil];
 }
 
 
 
 }
 else {
 int start=[self getIntegerDayForDate:self.temporaryDateOfGradedRegion];
 int end=[self getIntegerDayForDate:self.temporaryActiveDate];
 if (isFirstTime)
 {
 [self addColoredImageToTileForSwipe:start-lastOfPrev :end:imageStr];//changed Ullas
 isFirstTime=NO;
 }
 
 [self deleteColoredImageToTileForSwipe:day :selectedDay :nil];
 }
 
 
 
 
 }
 }
 }
 else if([self.temporaryStartDate compare:self.temporaryActiveDate]==NSOrderedSame)
 {
 if ([date compare:self.temporaryStartDate]==NSOrderedSame)
 {
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 
 if ([target isKindOfClass:[TKCalendarMonthView class]])
 {
 TKCalendarMonthView *calView=(TKCalendarMonthView *)target;
 if([calView.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
 [calView.delegate calendarMonthView:calView didSelectDate:date];
 }
 return;
 }
 
 }
 
 }
 
 }
 else
 {
 
 
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 NSDate *tempStartDate=[defaults objectForKey:@"selectedStartDate"];
 NSDate *tempEnddate=[defaults objectForKey:@"selectedEndDate"];
 
 
 if (portion==0)
 {
 
 if ([tempStart compare:tempActive]==NSOrderedSame)
 {
 
 if (isForwardSwipe)
 {
 
 int startMonth=[self getIntegerMonthForDate:tempStart];
 int thisMonth=[self getIntegerMonthForDate:monthDate];
 if (startMonth==thisMonth)
 {
 
 self.temporaryStartDate=date;
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 [target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil] withObject:[NSNumber numberWithBool:NO]];
 return;
 
 }
 
 }
 }
 
 if ([tempStart compare:tempActive]==NSOrderedAscending )
 {
 
 int startMonth=[self getIntegerMonthForDate:tempStart];
 int thisMonth=[self getIntegerMonthForDate:monthDate];
 
 if (startMonth==thisMonth)
 {
 self.temporaryStartDate=date;
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 [target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil] withObject:[NSNumber numberWithBool:NO]];
 return;
 
 }
 }
 }
 else {
 
 if ([tempStart compare:tempActive]==NSOrderedSame)
 {
 
 if (isBackwardSwipe) {
 
 int startMonth=[self getIntegerMonthForDate:tempStart];
 int thisMonth=[self getIntegerMonthForDate:monthDate];
 
 if (startMonth==thisMonth)
 {
 self.temporaryStartDate=date;
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 [target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil] withObject:[NSNumber numberWithBool:NO]];
 return;
 
 }
 
 }
 }
 
 if ([tempStart compare:tempActive]==NSOrderedDescending )
 {
 
 int startMonth=[self getIntegerMonthForDate:tempStart];
 int thisMonth=[self getIntegerMonthForDate:monthDate];
 
 
 if (startMonth==thisMonth)
 {
 self.temporaryStartDate=date;
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 [target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil] withObject:[NSNumber numberWithBool:NO]];
 return;
 
 }
 
 }
 
 }
 
 
 
 
 //BOOL isForwardMonthChange=NO;
 //BOOL isBackwardMonthChange=NO;
 if (selectedDay<day)
 {
 if (portion!=2)
 {
 NSDate *date = [self getDateForSelectedPortion:portion withDay:day];
 self.temporaryActiveDate=date;
 //isBackwardMonthChange=YES;
 
 if ([tempStartDate compare:tempEnddate]==NSOrderedAscending)
 {
 if ([self.temporaryStartDate compare:temporaryActiveDate]==NSOrderedDescending)
 {
 self.temporaryStartDate=date;
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 [target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil] withObject:[NSNumber numberWithBool:NO]];
 return;
 }
 }
 
 
 }
 }
 else if (selectedDay>day ) {
 
 if (portion!=0) {
 NSDate *date = [self getDateForSelectedPortion:portion withDay:day];
 self.temporaryActiveDate=date;
 //isForwardMonthChange=YES;
 if ([tempStartDate compare:tempEnddate]==NSOrderedDescending)
 {
 if ([self.temporaryStartDate compare:temporaryActiveDate]==NSOrderedAscending)
 {
 self.temporaryStartDate=date;
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 [target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil] withObject:[NSNumber numberWithBool:NO]];
 return;
 }
 
 
 }
 }
 }
 else if(selectedDay==day)
 {
 if (isForwardSwipe) {
 
 NSDate *date = [self getDateForSelectedPortion:portion withDay:day];
 self.temporaryActiveDate=date;
 
 }
 else
 {
 NSDate *date = [self getDateForSelectedPortion:portion withDay:day];
 self.temporaryActiveDate=date;
 }
 }
 
 
 if ([target isKindOfClass:[TKCalendarMonthView class]])
 {
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 [target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil] withObject:[NSNumber numberWithBool:NO]];
 
 }
 
 
 
 
 
 
 }
 
 selectedDay=day;
 selectedPortion=portion;
 previousRowSelected=row;
 previousColumnSelected=column;
 }
 
 - (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
 
 isTouchesEndReached=YES;
 BOOL down=YES;
 
 CGPoint p = [[touches anyObject] locationInView:self];
	if(p.y > self.bounds.size.height || p.y < 0)
 {
 if ([target isKindOfClass:[TKCalendarMonthView class]])
 {
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 
 TKCalendarMonthView *calView=(TKCalendarMonthView *)target;
 if([calView.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
 [calView.delegate calendarMonthView:calView didSelectDate:self.temporaryActiveDate];
 
 }
 
 return;
 }
	
	int column = p.x / 46, row = p.y / 44;
	int day = 1, portion = 0;
	
	if(row == (int) (self.bounds.size.height / 44)) row --;
	
	int fir = firstWeekday - 1;
	if(!startOnSunday && fir == 0) fir = 7;
	if(!startOnSunday) fir--;
	
	
	if(row==0 && column < fir){
 day = firstOfPrev + column;
	}else{
 portion = 1;
 day = row * 7 + column  - firstWeekday+2;
 if(!startOnSunday) day++;
 if(!startOnSunday && fir==6) day -= 7;
 
	}
	if(portion > 0 && day > daysInMonth){
 portion = 2;
 day = day - daysInMonth;
	}
	
	
	if(portion != 1){
 self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png")];
 markWasOnToday = YES;
	}else if(portion==1 && day == today){
 self.currentDay.shadowOffset = CGSizeMake(0, 1);
 self.dot.shadowOffset = CGSizeMake(0, 1);
 self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/todaySelected.png")];
 markWasOnToday = YES;
	}else if(markWasOnToday){
 self.dot.shadowOffset = CGSizeMake(0, -1);
 self.currentDay.shadowOffset = CGSizeMake(0, -1);
 self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/selected.png")];
 markWasOnToday = NO;
	}
	
	[self addSubview:self.selectedImageView];
	self.currentDay.text = [NSString stringWithFormat:@"%d",day];
 CGRect r = self.selectedImageView.frame;
	r.origin.x = (column*46);
	r.origin.y = (row*44)-1;
 
	self.selectedImageView.frame = r;
 previousRowSelected=row;
 previousColumnSelected=column;
 
 
 
 
 NSUInteger numTaps = [[touches anyObject] tapCount];
 
 BOOL isDoubleTap=NO;
 
 if (numTaps < 2)
 
 isDoubleTap=NO;
 
 else if(numTaps == 2)
 
 isDoubleTap=YES;
 
 if(day == selectedDay && selectedPortion == portion)
 
 {
 
 if (isDoubleTap)
 
 {
 
 if ([target isKindOfClass:[TKCalendarMonthView class]])
 
 {
 
 self.temporaryStartDate=self.temporaryActiveDate;
 
 [[NSUserDefaults standardUserDefaults]
 setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 
 [[NSUserDefaults standardUserDefaults]
 setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 
 [[NSUserDefaults standardUserDefaults]synchronize];
 
 TKCalendarMonthView *calView=(TKCalendarMonthView *)target;
 
 if([calView.delegate
 respondsToSelector:@selector(calendarMonthView:didSelectDateForDoubleTap:)])
 
 [calView.delegate calendarMonthView:calView
 didSelectDateForDoubleTap:[self dateSelected]];
 
 }
 
 return;
 
 
 
 }
 
 
 
 
 
 }
 
 
 
 NSDate *date=[self getDateForSelectedPortion:portion withDay:day];
 
 if ([self.temporaryStartDate compare:self.temporaryActiveDate]==NSOrderedAscending)
 {
 
 if ([date compare:temporaryStartDate]==NSOrderedAscending) {
 
 
 if (![self.temporaryActiveDate compare:date]==NSOrderedSame) {
 
 
 
 self.temporaryStartDate=date;
 self.temporaryActiveDate=date;
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 
 if ([target isKindOfClass:[TKCalendarMonthView class]])
 {
 TKCalendarMonthView *calView=(TKCalendarMonthView *)target;
 if([calView.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
 [calView.delegate calendarMonthView:calView didSelectDate:date];
 
 }
 
 
 }
 
 
 }
 
 }
 else if ([self.temporaryStartDate compare:self.temporaryActiveDate]==NSOrderedDescending)
 {
 if ([date compare:temporaryStartDate]==NSOrderedDescending) {
 
 if (![self.temporaryActiveDate compare:date]==NSOrderedSame) {
 
 
 self.temporaryStartDate=date;
 self.temporaryActiveDate=date;
 
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 
 if ([target isKindOfClass:[TKCalendarMonthView class]])
 {
 TKCalendarMonthView *calView=(TKCalendarMonthView *)target;
 if([calView.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
 [calView.delegate calendarMonthView:calView didSelectDate:date];
 
 }
 
 }
 
 }
 
 }
 
 self.temporaryActiveDate=date;
 NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
 [defaults setObject:self.temporaryStartDate forKey:@"selectedStartDate"];
 [defaults setObject:self.temporaryActiveDate forKey:@"selectedEndDate"];
 [defaults synchronize];
 
 
 
 if(portion == 1){
 //Handles same month
 selectedDay = day;
 selectedPortion = portion;
 [target performSelector:action withObject:[NSArray arrayWithObject:[NSNumber numberWithInt:day]]withObject:[NSNumber numberWithBool:NO]];
 
 
 
 }
 else if(down){
 //Handles Month Change
 [target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:day],[NSNumber numberWithInt:portion],nil] withObject:[NSNumber numberWithBool:NO]];
 selectedDay = day;
 selectedPortion = portion;
 }
 
 }*/
- (void) reactToTouch:(UITouch*)touch down:(BOOL)down doubleTap:(BOOL)isDoubleTap{
    
    CGPoint p = [touch locationInView:self];
    if(p.y > self.bounds.size.height || p.y < 0) return;
    
    int column = p.x / CELLWIDTH, row = p.y / 44;
    NSInteger day = 1, portion = 0;
    
    if(row == (int) (self.bounds.size.height / 44)) row --;
    
    NSInteger fir = firstWeekday - 1;
    if(!startOnSunday && fir == 0) fir = 7;
    if(!startOnSunday) fir--;
    
    
    if(row==0 && column < fir){
        day = firstOfPrev + column;
    }else{
        portion = 1;
        day = row * 7 + column  - firstWeekday+2;
        if(!startOnSunday) day++;
        if(!startOnSunday && fir==6) day -= 7;
        
    }
    if(portion > 0 && day > daysInMonth){
        portion = 2;
        day = day - daysInMonth;
    }
    
    if(portion != 1){
        self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Date Tile Gray.png")];
        markWasOnToday = YES;
    }else if(portion==1 && day == today){
        self.currentDay.shadowOffset = CGSizeMake(0, 1);
        self.dot.shadowOffset = CGSizeMake(0, 1);
        self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/todaySelected.png")];
        markWasOnToday = YES;
    }else if(markWasOnToday){
        self.dot.shadowOffset = CGSizeMake(0, -1);
        self.currentDay.shadowOffset = CGSizeMake(0, -1);
        self.selectedImageView.image = [UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/selected.png.png")];
        markWasOnToday = NO;
    }
    
    [self addSubview:self.selectedImageView];
    self.currentDay.text = [NSString stringWithFormat:@"%ld",(long)day];
    
    if ([marks count] > 0) {
        if([[marks objectAtIndex: row * 7 + column] boolValue])
        {
            BOOL showDotOnTile=[self checkWhetherToShowDotOnDate];
            if (showDotOnTile)
            {
                [self.selectedImageView addSubview:self.dot];
            }
            else {
                [self.dot removeFromSuperview];
            }
        }
        
        else
            [self.dot removeFromSuperview];
    }else{
        [self.dot removeFromSuperview];
    }
    
    
    
    
    CGRect r = self.selectedImageView.frame;
    r.origin.x = (column*CELLWIDTH);
    r.origin.y = (row*44)-1;
    self.selectedImageView.frame = r;
    
    /*if(day == selectedDay && selectedPortion == portion)
     return;*/
    
    
	   
    
    
    
    if(portion == 1){
        selectedDay = day;
        selectedPortion = portion;
        [target performSelector:action withObject:[NSArray arrayWithObject:[NSNumber numberWithInteger:day]] withObject:[NSNumber numberWithBool:isDoubleTap]];
        
    }else if(down){
        [target performSelector:action withObject:[NSArray arrayWithObjects:[NSNumber numberWithInteger:day],[NSNumber numberWithInteger:portion],nil] withObject:[NSNumber numberWithBool:isDoubleTap]];
        selectedDay = day;
        selectedPortion = portion;
    }
    
    
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSUInteger numTaps = [[touches anyObject] tapCount];
    if (numTaps != 2)
        [self reactToTouch:[touches anyObject] down:YES doubleTap:FALSE];
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //[self reactToTouch:[touches anyObject] down:NO:FALSE];
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //[self reactToTouch:[touches anyObject] down:YES:FALSE];
    
    
    
    
}


- (UILabel *) currentDay{
    if(currentDay==nil){
        CGRect r = self.selectedImageView.bounds;
//        r.origin.x=r.origin.x+11.0;
        r.origin.y =r.origin.y-3.0;
        currentDay = [[UILabel alloc] initWithFrame:r];
        currentDay.text = @"1";
        currentDay.textColor = [UIColor whiteColor];
        currentDay.backgroundColor = [UIColor clearColor];
        currentDay.font = [UIFont boldSystemFontOfSize:dateFontSize];
        currentDay.textAlignment = NSTextAlignmentRight;
        currentDay.shadowColor = [UIColor darkGrayColor];
        currentDay.shadowOffset = CGSizeMake(0, -1);
    }
    return currentDay;
}
- (UILabel *) dot{
    if(dot==nil){
        CGRect r = self.selectedImageView.bounds;
        r.origin.y += 19;
        r.size.height -= 31;
        dot = [[UILabel alloc] initWithFrame:r];
        
        dot.text = @"•";
        dot.textColor = [UIColor whiteColor];
        dot.backgroundColor = [UIColor clearColor];
        dot.font = [UIFont boldSystemFontOfSize:dotFontSize];
        dot.textAlignment = NSTextAlignmentCenter;
        dot.shadowColor = [UIColor darkGrayColor];
        dot.shadowOffset = CGSizeMake(0, -1);
    }
    return dot;
}
- (UIImageView *) selectedImageView{
    if(selectedImageView==nil){
        selectedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedTK:@"TapkuLibrary.bundle/Images/calendar/selected"]];
        CGRect r = selectedImageView.frame;
        r.size.width = CELLWIDTH;
        r.size.height = CELLHEIGHT;
        selectedImageView.frame = r;
    }
    return selectedImageView;
}
-(BOOL)checkWhetherToShowDotOnDate
{
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    NSDate *tmpSelectedEndDate=[defaults objectForKey:@"selectedEndDate"];
    NSDate *tmpSelectedStartDate=[defaults objectForKey:@"selectedStartDate"];
    
    if ([[defaults objectForKey:@"ScreenMode"] isEqualToString:@"SelectStartDateScreen"])
    {
        
        if (tmpSelectedEndDate!=nil)
        {
            if (dateBeingDrawnOnTile!=nil)
            {
                if ([tmpSelectedEndDate compare:dateBeingDrawnOnTile]==NSOrderedSame)
                {
                    if (tmpSelectedStartDate!=nil)
                    {
                        if ([tmpSelectedStartDate compare:dateBeingDrawnOnTile]==NSOrderedSame)
                            return YES;
                        else
                            return NO;
                    }
                    else
                    {
                        return NO;
                    }
                    
                    
                }
            }
            else
            {
                return YES;
            }
            
        }
        
    }
    else if ([[defaults objectForKey:@"ScreenMode"] isEqualToString:@"SelectEndDateScreen"])
    {
        
        if (tmpSelectedStartDate!=nil)
        {
            if (dateBeingDrawnOnTile!=nil)
            {
                if ([tmpSelectedStartDate compare:dateBeingDrawnOnTile]==NSOrderedSame)
                {
                    
                    if (tmpSelectedEndDate!=nil)
                    {
                        if ([tmpSelectedEndDate compare:dateBeingDrawnOnTile]==NSOrderedSame)
                            return YES;
                        else
                            return NO;
                    }
                    else
                    {
                        return NO;
                    }
                    
                }
                
            }
            else
            {
                return YES;
            }
        }
        
    }
    
    return YES;
    
}

@end



#pragma mark - TKCalendarMonthView
@interface TKCalendarMonthView (private)
@property (strong,nonatomic) UIScrollView *tileBox;
@property (strong,nonatomic) UIImageView *topBackground;
@property (strong,nonatomic) UILabel *monthYear;
@property (strong,nonatomic) UIButton *leftArrow;
@property (strong,nonatomic) UIButton *rightArrow;
@property (strong,nonatomic) UIImageView *shadow;
@end

#pragma mark - TKCalendarMonthView
@implementation TKCalendarMonthView
@synthesize delegate,dataSource;
@synthesize approveRejectWaitDatesDictionary;
@synthesize weekendDict;
@synthesize isGridCalendarComplete;

- (id) init{
    self = [self initWithSundayAsFirst:YES forMonthDate:[NSDate date] showCompleteCalendar:NO];
    return self;
}
- (id) initWithSundayAsFirst:(BOOL)s forMonthDate:(NSDate *)selectedMonthDate showCompleteCalendar:(BOOL)showCompleteCalendarBool{
    if (!(self = [super initWithFrame:CGRectZero])) return nil;
    self.backgroundColor = [UIColor whiteColor];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setObject:nil forKey:@"selectedStartDate"];
    [defaults setObject:nil forKey:@"selectedEndDate"];
    [defaults setObject:nil forKey:@"ScreenMode"];
    [defaults synchronize];
    sunday = s;
    self.isGridCalendarComplete=showCompleteCalendarBool;
    currentTile = [[TKCalendarMonthTiles alloc] initWithMonth:[selectedMonthDate firstOfMonth] marks:nil startDayOnSunday:sunday approvedRejectedWaitingDatesDictionary:nil WithWeekends:nil withShowCompleteCalendarGrid:showCompleteCalendarBool];
    [currentTile setTarget:self action:@selector(tile:isDoubleTapNum:)];
    
    CGRect r = CGRectMake(0, 0, self.tileBox.bounds.size.width, self.tileBox.bounds.size.height + self.tileBox.frame.origin.y);
    self.frame = r;
    
    [self addSubview:self.topBackground];
    [self.tileBox addSubview:currentTile];
    [self addSubview:self.tileBox];
    
    NSDate *date = selectedMonthDate;
    self.monthYear.text = [NSString stringWithFormat:@"%@ %@",[date monthString],[date yearString]];
    UIView *monthYearView  = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tileBox.bounds.size.width, 46)];
    monthYearView.backgroundColor = [UIColor colorWithRed:238/255. green:238/255. blue:238/255. alpha:1];
    [monthYearView addSubview:self.monthYear];
    [self addSubview:monthYearView];
    
    
    [self addSubview:self.leftArrow];
    [self addSubview:self.rightArrow];
    [self addSubview:self.shadow];
    //	self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
    self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+3, self.shadow.frame.size.width, self.shadow.frame.size.height);
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    
    //localisation
    NSLocale *locale=[NSLocale currentLocale];
    [dateFormat setLocale:locale];
    [dateFormat setDateFormat:@"eee"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    
   // NSDateComponents *sund;
    NSDateComponents *sund = [[NSDateComponents alloc] init];

    sund.day = 5;
    sund.month = 12;
    sund.year = 2010;
    sund.hour = 0;
    sund.minute = 0;
    sund.second = 0;
    sund.weekday = 0;
    NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];
    sund.timeZone=tz;
    
    NSString * sun = [dateFormat stringFromDate:[NSDate dateWithDateComponents:sund]];
    
    sund.day = 6;
    NSString *mon = [dateFormat stringFromDate:[NSDate dateWithDateComponents:sund]];
    
    sund.day = 7;
    NSString *tue = [dateFormat stringFromDate:[NSDate dateWithDateComponents:sund]];
    
    sund.day = 8;
    NSString *wed = [dateFormat stringFromDate:[NSDate dateWithDateComponents:sund]];
    
    sund.day = 9;
    NSString *thu = [dateFormat stringFromDate:[NSDate dateWithDateComponents:sund]];
    
    sund.day = 10;
    NSString *fri = [dateFormat stringFromDate:[NSDate dateWithDateComponents:sund]];
    
    sund.day = 11;
    NSString *sat = [dateFormat stringFromDate:[NSDate dateWithDateComponents:sund]];
    
    NSArray *ar;
    if(sunday) ar = [NSArray arrayWithObjects:sun,mon,tue,wed,thu,fri,sat,nil];
    else ar = [NSArray arrayWithObjects:mon,tue,wed,thu,fri,sat,sun,nil];
    
    int i = 0;
    for(NSString *s in ar){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CELLWIDTH * i, 29, CELLWIDTH, 15)];
        [self addSubview:label];
        label.text = s;
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"OpenSans" size:11.0f];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        i++;
    }
    
    return self;
}


- (NSDate*) dateForMonthChange:(UIView*)sender {
    BOOL isNext = (sender.tag == 1);
    NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonth] : [currentTile.monthDate previousMonth];
    
    NSDateComponents *nextInfo = [nextMonth dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *localNextMonth = [NSDate dateWithDateComponents:nextInfo];
    
    return localNextMonth;
}

- (void) changeMonthAnimation:(UIView*)sender{
    
    
    BOOL isNext = (sender.tag == 1);
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"NEXT_CLICKED"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PREVIOUS_CLICKED"];
    
    if (isNext)
    {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"NEXT_CLICKED"];
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:@"PREVIOUS_CLICKED"];
    }
    
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    NSDate *nextMonth = isNext ? [currentTile.monthDate nextMonth] : [currentTile.monthDate previousMonth];
    
    NSDateComponents *nextInfo = [nextMonth dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *localNextMonth = [NSDate dateWithDateComponents:nextInfo];
    
    
    NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:nextMonth startOnSunday:sunday isCompleteGridCalendar:self.isGridCalendarComplete];
    NSArray *ar = [self.dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:nextMonth marks:ar startDayOnSunday:sunday approvedRejectedWaitingDatesDictionary:self.approveRejectWaitDatesDictionary WithWeekends:self.weekendDict withShowCompleteCalendarGrid:self.isGridCalendarComplete];
    [newTile setTarget:self action:@selector(tile:isDoubleTapNum:)];
    
    
    
    
    int overlap =  0;
    
    if(isNext){
        overlap = [newTile.monthDate isEqualToDate:[dates objectAtIndex:0]] ? 0 : 44;
    }else{
        overlap = [currentTile.monthDate compare:[dates lastObject]] !=  NSOrderedDescending ? 44 : 0;
    }
    
    float y = isNext ? currentTile.bounds.size.height - overlap : newTile.bounds.size.height * -1 + overlap +2;
    
    newTile.frame = CGRectMake(0, y, newTile.frame.size.width, newTile.frame.size.height);
    newTile.alpha = 0;
    [self.tileBox addSubview:newTile];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    newTile.alpha = 1;
    
    [UIView commitAnimations];
    
    
    
    self.userInteractionEnabled = NO;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDidStopSelector:@selector(animationEnded)];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationDuration:0.4];
    
    
    
    if(isNext){
        
        currentTile.frame = CGRectMake(0, -1 * currentTile.bounds.size.height + overlap + 2, currentTile.frame.size.width, currentTile.frame.size.height);
        newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
        self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
        
        //		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
        
        self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+3, self.shadow.frame.size.width, self.shadow.frame.size.height);
        
    }else{
        
        newTile.frame = CGRectMake(0, 1, newTile.frame.size.width, newTile.frame.size.height);
        self.tileBox.frame = CGRectMake(self.tileBox.frame.origin.x, self.tileBox.frame.origin.y, self.tileBox.frame.size.width, newTile.frame.size.height);
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
        currentTile.frame = CGRectMake(0,  newTile.frame.size.height - overlap, currentTile.frame.size.width, currentTile.frame.size.height);
        
        //		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
        
        self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+3, self.shadow.frame.size.width, self.shadow.frame.size.height);
        
    }
    
    
    [UIView commitAnimations];
    
    oldTile = currentTile;
    currentTile = newTile;
    
    monthYear.text = [NSString stringWithFormat:@"%@ %@",[localNextMonth monthString],[localNextMonth yearString]];
    
    
    
}
- (void) changeMonth:(UIButton *)sender{
    
    NSDate *newDate = [self dateForMonthChange:sender];
    if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![self.delegate calendarMonthView:self monthShouldChange:newDate animated:YES] )
        return;
    
    
    if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] )
        [self.delegate calendarMonthView:self monthWillChange:newDate animated:YES];
    
    
    
    
    [self changeMonthAnimation:sender];
    if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:isNextPreviousBtn:animated:)])
        [self.delegate calendarMonthView:self monthDidChange:currentTile.monthDate isNextPreviousBtn:YES animated:YES];
    
}
- (void) animationEnded{
    self.userInteractionEnabled = YES;
    [oldTile removeFromSuperview];
    oldTile = nil;
    [self reload];
}

- (NSDate*) dateSelected{
    return [currentTile dateSelected];
}
- (NSDate*) monthDate{
    return [currentTile monthDate];
}
- (void) selectDate:(NSDate*)date{
    
    NSDateComponents *info = [date dateComponentsWithTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDate *month = [date firstOfMonth];
    
    if([month isEqualToDate:[currentTile monthDate]]){
        [currentTile selectDay:info.day];
        return;
    }else {
        
        if ([delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![self.delegate calendarMonthView:self monthShouldChange:month animated:YES] )
            return;
        
        if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)] )
            [self.delegate calendarMonthView:self monthWillChange:month animated:YES];
        
        
        NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:month startOnSunday:sunday isCompleteGridCalendar:self.isGridCalendarComplete];
        NSArray *data = [self.dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
        TKCalendarMonthTiles *newTile = [[TKCalendarMonthTiles alloc] initWithMonth:month
                                                                              marks:data
                                                                   startDayOnSunday:sunday approvedRejectedWaitingDatesDictionary:self.approveRejectWaitDatesDictionary WithWeekends:self.weekendDict withShowCompleteCalendarGrid:self.isGridCalendarComplete];
        [newTile setTarget:self action:@selector(tile:isDoubleTapNum:)];
        [currentTile removeFromSuperview];
        currentTile = newTile;
        [self.tileBox addSubview:currentTile];
        self.tileBox.frame = CGRectMake(0, 44, newTile.frame.size.width, newTile.frame.size.height);
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width, self.tileBox.frame.size.height+self.tileBox.frame.origin.y);
        
        //		self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+21, self.shadow.frame.size.width, self.shadow.frame.size.height);
        self.shadow.frame = CGRectMake(0, self.frame.size.height-self.shadow.frame.size.height+3, self.shadow.frame.size.width, self.shadow.frame.size.height);
        
        self.monthYear.text = [NSString stringWithFormat:@"%@ %@",[date monthString],[date yearString]];
        [currentTile selectDay:info.day];
        
        if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:isNextPreviousBtn:animated:)])
            [self.delegate calendarMonthView:self monthDidChange:date isNextPreviousBtn:NO animated:NO];
        
        
    }
}
- (void) reload{
    NSArray *dates = [TKCalendarMonthTiles rangeOfDatesInMonthGrid:[currentTile monthDate] startOnSunday:sunday isCompleteGridCalendar:self.isGridCalendarComplete];
    NSArray *ar = [self.dataSource calendarMonthView:self marksFromDate:[dates objectAtIndex:0] toDate:[dates lastObject]];
    
    TKCalendarMonthTiles *refresh = [[TKCalendarMonthTiles alloc] initWithMonth:[currentTile monthDate] marks:ar startDayOnSunday:sunday approvedRejectedWaitingDatesDictionary:self.approveRejectWaitDatesDictionary WithWeekends:self.weekendDict withShowCompleteCalendarGrid:self.isGridCalendarComplete];
    [refresh setTarget:self action:@selector(tile:isDoubleTapNum:)];
    
    [self.tileBox addSubview:refresh];
    [currentTile removeFromSuperview];
    currentTile = refresh;
    
}

- (void) tile:(NSArray*)ar isDoubleTapNum:(NSNumber *)isDoubleTapNum{
    
    BOOL isDoubleTap=[isDoubleTapNum boolValue];
    if([ar count] < 2){
        
        if (isDoubleTap)
        {
            if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDateForDoubleTap:)])
                [self.delegate calendarMonthView:self didSelectDateForDoubleTap:[self dateSelected]];
        }
        else
        {
            if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
                [self.delegate calendarMonthView:self didSelectDate:[self dateSelected]];
        }
        
        
        
    }else{
        
        int direction = [[ar lastObject] intValue];
        UIButton *b = direction > 1 ? self.rightArrow : self.leftArrow;
        
        NSDate* newMonth = [self dateForMonthChange:b];
        if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthShouldChange:animated:)] && ![delegate calendarMonthView:self monthShouldChange:newMonth animated:YES])
            return;
        
        if ([self.delegate respondsToSelector:@selector(calendarMonthView:monthWillChange:animated:)])
            [self.delegate calendarMonthView:self monthWillChange:newMonth animated:YES];
        
        
        
        [self changeMonthAnimation:b];
        
        int day = [[ar objectAtIndex:0] intValue];
        
        
        // thanks rafael
        NSDateComponents *info = [[currentTile monthDate] dateComponentsWithTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        info.day = day;
        
        NSDate *dateForMonth = [NSDate dateWithDateComponents:info];
        [currentTile selectDay:day];
        
        //if([self.delegate respondsToSelector:@selector(calendarMonthView:didSelectDate:)])
        //[self.delegate calendarMonthView:self didSelectDate:dateForMonth];
        
        if([self.delegate respondsToSelector:@selector(calendarMonthView:monthDidChange:isNextPreviousBtn:animated:)])
            [self.delegate calendarMonthView:self monthDidChange:dateForMonth isNextPreviousBtn:NO animated:YES];
        
        
    }
    
}
-(void)paint_ApproveRejectedWaiting_Dates_To_Calendar:(NSMutableDictionary *)dict withWeekends:(NSMutableDictionary *)dict2
{
    self.approveRejectWaitDatesDictionary=dict;
    self.weekendDict=dict2;
    [self reload];
    
}

#pragma mark Properties
- (UIImageView *) topBackground{
    if(topBackground==nil){
        topBackground = [[UIImageView alloc] init];

    }
    topBackground.backgroundColor = [UIColor redColor];
    return topBackground;
}
- (UILabel *) monthYear{
    if(monthYear==nil){
        monthYear = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tileBox.frame.size.width, 36)];
        
        monthYear.textAlignment = NSTextAlignmentCenter;
        monthYear.backgroundColor = [UIColor colorWithRed:238/255. green:238/255. blue:238/255. alpha:1];
        monthYear.font = [UIFont fontWithName:@"OpenSans-Semibold" size:15.0f];
        monthYear.textColor =[UIColor blackColor];
        UIView *separtorView = [[UIView alloc]initWithFrame:CGRectMake(0, 46, self.tileBox.frame.size.width, 1)];
        [separtorView setBackgroundColor:[UIColor colorWithRed:204/255. green:204/255. blue:204/255. alpha:1]];
        [monthYear addSubview:separtorView];
    }
    return monthYear;
}
- (UIButton *) leftArrow{
    if(leftArrow==nil){
        leftArrow = [UIButton buttonWithType:UIButtonTypeCustom];
        leftArrow.tag = 0;
        [leftArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
        [leftArrow setImage:[UIImage imageNamed:@"calendar_Pointer_Left"] forState:0];
        leftArrow.frame = CGRectMake(0, 0, 48, 38);
    }
    return leftArrow;
}
- (UIButton *) rightArrow{
    if(rightArrow==nil){
        rightArrow = [UIButton buttonWithType:UIButtonTypeCustom];
        rightArrow.tag = 1;
        [rightArrow addTarget:self action:@selector(changeMonth:) forControlEvents:UIControlEventTouchUpInside];
        rightArrow.frame = CGRectMake(SCREENWIDTH-45, 0, 48, 38);
        [rightArrow setImage:[UIImage imageNamed:@"calendar_Pointer_Right"] forState:0];

    }
    return rightArrow;
}
- (UIScrollView *) tileBox{
    if(tileBox==nil){
        tileBox = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, SCREENWIDTH, currentTile.frame.size.height)];
    }
    return tileBox;
}
- (UIImageView *) shadow{
    if(shadow==nil){
        shadow = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:TKBUNDLE(@"TapkuLibrary.bundle/Images/calendar/Month Calendar Shadow.png")]];
        CGRect r = shadow.frame;
        r.size.width = SCREENWIDTH;
        shadow.frame = r;

    }
    return shadow;
}

@end
