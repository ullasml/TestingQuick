
#import "TimesheetValidationViewController.h"
#import "Constants.h"
#import "RepliconServiceManager.h"
#import "TimesheetService.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"
#import "ErrorBannerViewParentPresenterHelper.h"
#import "AppDelegate.h"


@interface TimesheetValidationViewController ()

@end

@implementation TimesheetValidationViewController
@synthesize dataArray;
@synthesize selectedSheet;
@synthesize scrollView;

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
    [Util setToolbarLabel: self withText:[NSString stringWithFormat:@"%@ %@",RPLocalizedString(ISSUES_ON_TEXT, @""), selectedSheet]];

    // Do any additional setup after loading the view.
    UIScrollView *tempScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, self.view.frame.size.height-44)];
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    
    if (version>=7.0)
    {
        tempScrollView.frame=CGRectMake(0,0 ,self.view.frame.size.width,self.view.frame.size.height-60);
    }

    self.scrollView=tempScrollView;
    [self.view addSubview:scrollView];
    [self createView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    //Check For Error Banner View
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    ErrorBannerViewParentPresenterHelper *errorBannerViewParentPresenterHelper = [appDelegate.injector getInstance:[ErrorBannerViewParentPresenterHelper class]];
    [errorBannerViewParentPresenterHelper setScrollViewInsetWithErrorBannerPresentation:self.scrollView];
}

-(void)createView
{
    float y_Offset = 0.0;
    float BGView_y_offset = 0.0;

    for (int index= 0; index<[self.dataArray count]; index++) {
        NSMutableArray *tempArr = [NSMutableArray array];
        tempArr = [self.dataArray objectAtIndex:index];
        NSString *colorCode= nil;
        y_Offset = 0;
        
        UIView *mainBGView = [[UIView alloc] initWithFrame:CGRectMake(10, BGView_y_offset+20, SCREEN_WIDTH-20, 100)];
        [mainBGView setBackgroundColor:[UIColor whiteColor]];
        [[mainBGView layer] setBorderColor:[[Util colorWithHex:@"#999999" alpha:1] CGColor]];
        [[mainBGView layer] setBorderWidth:0.5];
        [[mainBGView layer] setCornerRadius:1];
        [mainBGView setClipsToBounds: YES];

        y_Offset = y_Offset + 34;
        UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 34)];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH, 34)];
        [headerLabel setTextColor:[UIColor whiteColor]];
        [headerLabel setFont:[UIFont fontWithName:@"Helvetica Neue Medium" size:RepliconFontSize_15]];
        [headerLabel setTextAlignment:NSTextAlignmentLeft];
        if ([tempArr count] == 0) {
            continue;
        }
        else{
            if ([[[tempArr objectAtIndex:0] objectForKey:@"severity"] isEqualToString:GEN4_TIMESHEET_ERROR_URI]) {
                colorCode = @"#F26A51";
                headerLabel.text = RPLocalizedString(ERROR_TEXT, @"");
            }
            else if ([[[tempArr objectAtIndex:0] objectForKey:@"severity"] isEqualToString:GEN4_TIMESHEET_WARNING_URI])
            {
                colorCode = @"#FFD200";
                headerLabel.text = RPLocalizedString(WARNING_TEXT, @"");
                [headerLabel setTextColor:[UIColor blackColor]];
            }
            else{
                colorCode = @"#6891BE";
                headerLabel.text = RPLocalizedString(INFORMATION_TEXT, @"");
            }
            [labelView setBackgroundColor:[Util colorWithHex:colorCode alpha:1.0]];
            [headerLabel setBackgroundColor:[UIColor clearColor]];
            [labelView addSubview:headerLabel];
            [mainBGView addSubview:labelView];
            
            NSMutableArray *filterArray = [self getTimesheetLevelAndDateLevelErrors:tempArr];
          
            
            for (int i= 0; i<[filterArray count]; i++) {
                NSMutableArray *dataValueArray = [NSMutableArray array];
                NSMutableDictionary *levelDataDict = [NSMutableDictionary dictionary];
                levelDataDict =[filterArray objectAtIndex:i];
                NSString *keyName = nil;
                for (NSString *key in [levelDataDict allKeys]) {
                    keyName = key;
                }
                
                BOOL isTimesheetLevelError = false;

                if ([keyName isEqualToString:@"timesheetLevel"]) {
                    isTimesheetLevelError = true;
                }
                
                
                
                NSString *labelValue = @"Adsklj";
                
                if (isTimesheetLevelError) {
                    dataValueArray = [levelDataDict objectForKey:@"timesheetLevel"];
                    y_Offset = y_Offset + 12;
                    float stringHeight = [self getHeightForString:labelValue fontSize:RepliconFontSize_15 forWidth:(SCREEN_WIDTH-40)];
                    
                    UILabel *timesheetOrDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y_Offset, SCREEN_WIDTH, 34)];
                    [timesheetOrDateLabel setBackgroundColor:[UIColor clearColor]];
                    [timesheetOrDateLabel setTextColor:[UIColor blackColor]];
                    [timesheetOrDateLabel setFont:[UIFont fontWithName:@"Helvetica Neue Regular" size:RepliconFontSize_15]];
                    
                    y_Offset = y_Offset + stringHeight;
                    
                    [timesheetOrDateLabel setText:RPLocalizedString(TIMESHEET_LEVEL_ERROR_TEXT, @"")];
                    
                    y_Offset = y_Offset + 8;
                    
                    
                    
                    for (int j = 0; j<[dataValueArray count]; j++) {
                        float strHeight = [self getHeightForString:[NSString stringWithFormat:@"- %@",[[dataValueArray objectAtIndex:j] objectForKey:@"displayText"]] fontSize:RepliconFontSize_14 forWidth:(SCREEN_WIDTH-40)];
                        UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y_Offset, (SCREEN_WIDTH-40), strHeight)];
                        [msgLabel setBackgroundColor:[UIColor clearColor]];
                        [msgLabel setTextColor:[Util colorWithHex:@"#838383" alpha:1]];
                        [msgLabel setFont:[UIFont fontWithName:@"Helvetica Neue Regular" size:RepliconFontSize_14]];
                        [msgLabel setText:[NSString stringWithFormat:@"- %@",[[dataValueArray objectAtIndex:j] objectForKey:@"displayText"]]];
                        msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
                        msgLabel.numberOfLines = 0;
                        [msgLabel sizeToFit];
                        [mainBGView addSubview:timesheetOrDateLabel];
                        [mainBGView addSubview:msgLabel];
                        y_Offset = msgLabel.frame.origin.y + 6 + msgLabel.frame.size.height;
                    }
                    y_Offset = y_Offset + 12;
                    
                    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, y_Offset, SCREEN_WIDTH, 0.5)];
                    [bottomView setBackgroundColor:[Util colorWithHex:@"#999999" alpha:1]]; //your background color...
                    [mainBGView addSubview:bottomView];
                    y_Offset = y_Offset;
                }
                else{
                    dataValueArray = [levelDataDict objectForKey:@"dateLevel"];
                    for (int dateLevelIndex = 0; dateLevelIndex<[dataValueArray count]; dateLevelIndex++) {
                        NSMutableDictionary *dateLevelValuesDict = [NSMutableDictionary dictionary];
                        dateLevelValuesDict = [dataValueArray objectAtIndex:dateLevelIndex];
                        NSString *levelKey = nil;
                        for (NSString *key in [dateLevelValuesDict allKeys]) {
                            levelKey = key;
                        }
                        
                        
                        y_Offset = y_Offset + 12;
                        float stringHeight = [self getHeightForString:levelKey fontSize:RepliconFontSize_15 forWidth:(SCREEN_WIDTH-40)];
                        
                        UILabel *timesheetOrDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y_Offset, SCREEN_WIDTH, 34)];
                        [timesheetOrDateLabel setBackgroundColor:[UIColor clearColor]];
                        [timesheetOrDateLabel setTextColor:[UIColor blackColor]];
                        [timesheetOrDateLabel setFont:[UIFont fontWithName:@"Helvetica Neue Regular" size:RepliconFontSize_15]];
                        
                        y_Offset = y_Offset + stringHeight;
                        
                        
                        [timesheetOrDateLabel setText:levelKey];
                        
                        y_Offset = y_Offset + 8;
                        
                        NSMutableArray *keyLevelDataArray = [NSMutableArray array];
                        keyLevelDataArray = [dateLevelValuesDict objectForKey:levelKey];
                        
                        for (int j = 0; j<[keyLevelDataArray count]; j++) {
                            float strHeight = [self getHeightForString:[NSString stringWithFormat:@"- %@",[[keyLevelDataArray objectAtIndex:j] objectForKey:@"displayText"]] fontSize:RepliconFontSize_14 forWidth:(SCREEN_WIDTH-40)];
                            UILabel *msgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, y_Offset, (SCREEN_WIDTH-40), strHeight)];
                            [msgLabel setBackgroundColor:[UIColor clearColor]];
                            [msgLabel setTextColor:[Util colorWithHex:@"#838383" alpha:1]];
                            [msgLabel setFont:[UIFont fontWithName:@"Helvetica Neue Regular" size:RepliconFontSize_14]];
                            [msgLabel setText:[NSString stringWithFormat:@"- %@",[[keyLevelDataArray objectAtIndex:j] objectForKey:@"displayText"]]];
                            msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
                            msgLabel.numberOfLines = 0;
                            [msgLabel sizeToFit];
                            [mainBGView addSubview:timesheetOrDateLabel];
                            [mainBGView addSubview:msgLabel];
                            y_Offset = msgLabel.frame.origin.y + 6 + msgLabel.frame.size.height;
                        }
                        y_Offset = y_Offset + 12;
                        
                        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, y_Offset, SCREEN_WIDTH, 0.5)];
                        [bottomView setBackgroundColor:[Util colorWithHex:@"#999999" alpha:1]]; //your background color...
                        [mainBGView addSubview:bottomView];
                        y_Offset = y_Offset;

                    }

                }
                
                
            }
            
           
        }
        BGView_y_offset = BGView_y_offset +y_Offset+20;
        mainBGView.frame = CGRectMake(10, mainBGView.frame.origin.y, SCREEN_WIDTH-20, y_Offset);
        [self.scrollView addSubview:mainBGView];
    }
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width,BGView_y_offset+50);

}

-(NSMutableArray*)getTimesheetLevelAndDateLevelErrors :(NSMutableArray*)array
{
    
    NSMutableArray *tempArray = [NSMutableArray array];
    NSMutableArray *temptimesheetLevelArray = [NSMutableArray array];
    NSMutableArray *tempDateLevelArray = [NSMutableArray array];
    NSMutableArray *dateStrArray = [NSMutableArray array];
    NSMutableArray *onlyDateArray = [NSMutableArray array];
    
    for (int i= 0; i<[array count]; i++) {
        
        NSArray *keyValuesArr=[[array objectAtIndex:i] objectForKey:@"keyValues"];
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
        if ([keyValuesArr count]>0)
        {
            tempDict = [[keyValuesArr objectAtIndex:0] objectForKey:@"value"];
        }
        
        
        
        if (![tempDict objectForKey:@"date"]) {
            [temptimesheetLevelArray addObject:[array objectAtIndex:i]];
        }
        else{
            NSDate *date = [Util convertApiDateDictToDateFormat:[tempDict objectForKey:@"date"]];
            NSTimeInterval timeInterval = [Util convertDateToTimestamp:date];
            NSInteger value = [[NSNumber numberWithDouble:timeInterval] doubleValue];
            NSMutableDictionary *dateDict = [NSMutableDictionary dictionary];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            NSLocale *locale=[NSLocale currentLocale];
            [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"EEEE, LLL d "];
            NSString *dateStr= [dateFormat stringFromDate:date];
            [dateDict setObject:[NSNumber numberWithInteger:value] forKey:@"timeInterval"];
            [dateDict setObject:dateStr forKey:@"dateStr"];
            [dateStrArray addObject:dateDict];
            [onlyDateArray addObject:[array objectAtIndex:i]];
        }
    }
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeInterval"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    sortedArray = [dateStrArray sortedArrayUsingDescriptors:sortDescriptors];
    
    for (int index = 0; index<[sortedArray count]; index++) {
        NSString *dateString = [[sortedArray objectAtIndex:index] objectForKey:@"dateStr"];
        NSMutableArray *sortedDateArray = [NSMutableArray array];
        for (int i = 0; i<[onlyDateArray count]; i++) {
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            dict = [[[[onlyDateArray objectAtIndex:i] objectForKey:@"keyValues"] objectAtIndex:0] objectForKey:@"value"];
            NSDate *date = [Util convertApiDateDictToDateFormat:[dict objectForKey:@"date"]];
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            
            NSLocale *locale=[NSLocale currentLocale];
            [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormat setLocale:locale];
            [dateFormat setDateFormat:@"EEEE, LLL d "];
            NSString *dateStr=[dateFormat stringFromDate:date];
            if ([dateString isEqualToString:dateStr]) {
                [sortedDateArray addObject:[onlyDateArray objectAtIndex:i]];
            }
        }
        [tempDateLevelArray addObject:[NSDictionary dictionaryWithObject:sortedDateArray forKey:dateString]];
    }
    
    if ([temptimesheetLevelArray count]> 0 ) {
        [tempArray addObject:[NSDictionary dictionaryWithObject:temptimesheetLevelArray forKey:@"timesheetLevel"]];
    }
    if ([tempDateLevelArray count]> 0) {
        [tempArray addObject:[NSDictionary dictionaryWithObject:tempDateLevelArray forKey:@"dateLevel"]];
    }

    
    return tempArray;
}




-(float)getHeightForString:(NSString *)string fontSize:(int)fontSize forWidth:(float)width
{
   
    
    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} range:NSMakeRange(0, attributedString.length)];
    
    //Now let's make the Bounding Rect
    CGSize mainSize  = [attributedString boundingRectWithSize:CGSizeMake(width, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }
    return mainSize.height;
}


@end
