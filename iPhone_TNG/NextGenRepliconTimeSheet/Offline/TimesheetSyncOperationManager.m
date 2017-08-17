//
//  TimesheetSyncOperationManager.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 2/24/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimesheetSyncOperationManager.h"

#import "TimesheetModel.h"
#import "LoginModel.h"
#import "SupportDataModel.h"
#import "TimesheetEntryObject.h"
#import "TimesheetObject.h"
#import "NSString+Double_Float.h"
#import "AFNetworking.h"
#import "RepliconServiceManager.h"
#import "EntryCellDetails.h"
#import <repliconkit/ReachabilityMonitor.h>
#import <KSDeferred/KSDeferred.h>
#import "RequestPromiseClient.h"
#import "OEFObject.h"
#import "FrameworkImport.h"

@interface TimesheetSyncOperationManager ()

@property(nonatomic)ReachabilityMonitor* reachabilityMonitor;
@property(nonatomic)TimesheetModel* timesheetModel;
@property(nonatomic)TimesheetService* timesheetService;
@property (nonatomic) id <RequestPromiseClient> client;
@property (nonatomic) NSNotificationCenter *notificationCenter;

@end

@implementation TimesheetSyncOperationManager

- (instancetype)initWithReachabilityMonitor:(ReachabilityMonitor *)reachabilityMonitor
                             timeSheetModel:(TimesheetModel *)timeSheetModel
                           timesheetService:(TimesheetService *)timesheetService
                                     client:(id <RequestPromiseClient>)client
                         notificationCenter:(NSNotificationCenter *)notificationCenter
{
    self = [super init];
    if (self)
    {
        self.reachabilityMonitor = reachabilityMonitor;
        self.timesheetModel = timeSheetModel;
        self.timesheetService = timesheetService;
        self.client = client;
        self.notificationCenter = notificationCenter;
    }

    return self;
}

#pragma mark - BaseSyncOperationManager Delegates

- (void)startPendingQueueSync:(BaseSyncOperationManager *)baseSyncOperationManager
{
    
    if (!self.isTimesheetSyncInProcess)
    {
         if ([NetworkMonitor isNetworkAvailableForListener:self] == YES)
        {

            self.isTimesheetSyncInProcess=YES;

            [self methodAWithCompletion:^(BOOL success) {
                if (success) {
                    self.isTimesheetSyncInProcess=NO;
                }
            }];
            
        }

    }


}


- (void)methodAWithCompletion:(void (^) (BOOL success))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, kNilOptions), ^{

        NSMutableArray *dbTimesheetsArray = [self.timesheetModel getAllTimesheetsFromDB];

        for (NSDictionary *timeSheetDict in dbTimesheetsArray)
        {
            NSString *timesheetURI = [timeSheetDict objectForKey:@"timesheetUri"];
            NSString *operationData=[timeSheetDict objectForKey:@"operations"];

            NSMutableArray *operationArr=nil;


            if (operationData ==nil || [operationData isKindOfClass:[NSNull class]])
            {
                operationArr=[NSMutableArray array];
            }
            else
            {
                operationArr=[NSMutableArray arrayWithArray:[operationData componentsSeparatedByString:@"|"]];
            }

            //                NSLog([NSString stringWithFormat:@"---PENDING OPERATIONS FOR TIMESHEET:%@\n%@",timesheetURI,operationArr]);


            for (NSString *operationName in operationArr)
            {
                NSLog(@"operationArr=%@ fot timesheeturi=%@",operationArr,timesheetURI);
                if ([operationName isEqualToString:TIMESHEET_SAVE_OPERATION])
                {
                    [self callServiceWithName:WIDGET_TIMESHEET_SAVE_SERVICE andTimeSheetURI:timesheetURI];
                    break;
                }
                else if ([operationName isEqualToString:TIMESHEET_SUBMIT_OPERATION])
                {
                    [self callServiceWithName:WIDGET_TIMESHEET_SUBMIT_SERVICE andTimeSheetURI:timesheetURI];
                    break;
                }
                else if ([operationName isEqualToString:TIMESHEET_REOPEN_OPERATION])
                {
                    [self callServiceWithName:WIDGET_TIMESHEET_REOPEN_SERVICE andTimeSheetURI:timesheetURI];
                    break;
                }
                else if ([operationName isEqualToString:TIMESHEET_RESUBMIT_OPERATION])
                {
                    [self callServiceWithName:WIDGET_TIMESHEET_RESUBMIT_SERVICE andTimeSheetURI:timesheetURI];
                    break;
                }

            }

            //                NSLog([NSString stringWithFormat:@"---AFTER EXECUTING PENDING OPERATIONS FOR TIMESHEET:%@\n%@",timesheetURI,operationArr]);

        }

        dispatch_async(dispatch_get_main_queue(), ^{

            completion(YES);
            
        });
    });
}

#pragma mark - Service Requests Method
-(void)callServiceWithName:(ServiceName)_serviceName andTimeSheetURI:(NSString *)timeSheetURI
{
    if(_serviceName==WIDGET_TIMESHEET_SAVE_SERVICE)
    {

        // The save is recorded to be in flight mode (in progress)
        [self.timesheetModel updateTimesheetWithOperationName:TIMESHEET_SAVE_INFLIGHT andTimesheetURI:timeSheetURI];

        NSMutableDictionary *attestationDict=nil;

        attestationDict=[self.timesheetModel getAttestationDetailsFromDBForTimesheetUri:timeSheetURI];
        if (attestationDict)
        {
            [self.timesheetService sendRequestUpdateTimesheetAttestationStatusForTimesheetURI:timeSheetURI forAttestationStatusUri:ATTESTATION_STATUS_UNATTESTED];
        }



        NSString *timeSheetFormat=[self.timesheetModel getTimesheetFormatforTimesheetUri:timeSheetURI];
        NSMutableArray *hybridEntries=nil;
        NSMutableArray *enableWidgetsArr=[self.timesheetModel getAllEnabledWidgetsUriDetailsFromDBForTimesheetUri:timeSheetURI];
        BOOL isHybridTimesheet=NO;
        BOOL hasStandardWidget=NO;
        BOOL hasInOutWidget=NO;
        BOOL hasPunchWidget=NO;
        BOOL hasDailyFieldWidget=NO;

        for(NSDictionary *widgetUriDict in enableWidgetsArr)
        {

            if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:STANDARD_WIDGET_URI])
            {
                hasStandardWidget=YES;
            }
            else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:INOUT_WIDGET_URI])
            {
                hasInOutWidget=YES;

            }
            else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:PUNCH_WIDGET_URI])
            {
                hasPunchWidget=YES;

            }
            else if ([[widgetUriDict objectForKey:@"widgetUri"] isEqualToString:DAILY_FIELDS_WIDGET_URI])
            {
                hasDailyFieldWidget=YES;

            }
        }

        if (hasInOutWidget && hasStandardWidget)
        {
            isHybridTimesheet=YES;
        }

        if (hasPunchWidget && hasStandardWidget)
        {
            isHybridTimesheet=YES;
        }

        if (isHybridTimesheet)
        {
            if([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
            {
                hybridEntries=[self createTimesheetDataArray:timeSheetURI forTimeSheetFormat:GEN4_INOUT_TIMESHEET];
            }
            if([timeSheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timeSheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
            {
                hybridEntries=[self createTimesheetDataArray:timeSheetURI forTimeSheetFormat:GEN4_STANDARD_TIMESHEET];
            }
        }



        NSMutableArray *timesheetSyncOperationManagerDataArray=[self createTimesheetDataArray:timeSheetURI forTimeSheetFormat:GEN4_INOUT_TIMESHEET];

        NSString *urlString = [self urlStringWithEndpointName:@"SaveWidgetTimesheetData"];


        NSMutableDictionary *bodyDictionary=[[RepliconServiceManager timesheetRequest]widgetTimesheetSaveRequestProvider:timesheetSyncOperationManagerDataArray andHybridWidgetTimeSheetData:hybridEntries andTimesheetUri:timeSheetURI andTimesheetFormat:timeSheetFormat];



        if (hasDailyFieldWidget)
        {
            NSMutableArray *dailyFieldWidgetTimesheetDataArray = [self createTimesheetDataArray:timeSheetURI forTimeSheetFormat:GEN4_DAILY_WIDGET_TIMESHEET];
            NSMutableArray *dailyWidgetTimeEntriesArr = [self saveDailyWidgetTimeSheetData:dailyFieldWidgetTimesheetDataArray andTimesheetUri:timeSheetURI];

            NSMutableArray *queryDictTimeEntries = bodyDictionary[@"timeEntries"];
            if (!queryDictTimeEntries)
            {
                queryDictTimeEntries=[NSMutableArray array];
            }
            [queryDictTimeEntries addObjectsFromArray:dailyWidgetTimeEntriesArr];
            [bodyDictionary setObject:queryDictTimeEntries forKey:@"timeEntries"];
        }

        NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:nil];


        NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
        NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                              @"PayLoadStr": requestBodyString};

        NSMutableURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];

        [request setValue:RequestMadeWhilePendingQueueSyncHeaderValue forHTTPHeaderField:RequestMadeWhilePendingQueueSyncHeaderKey];

        KSPromise *promise = [self.client promiseWithRequest:request];
         [promise then:^id(NSDictionary *json) {
             NSDictionary *error = [json objectForKey:@"error"];
             if (error == nil) {

                 dispatch_async(dispatch_get_main_queue(), ^{


                     if (![self.timesheetModel checkIfTimeEntriesModifiedOrDeleted:timeSheetURI timesheetFormat:GEN4_INOUT_TIMESHEET])
                     {
                         [self.timesheetService handleTimesheetsSummaryFetchData:[NSMutableDictionary dictionaryWithObject:json forKey:@"response"] isFromSave:YES];
                     }
                     else
                     {
                         [self.timesheetModel updateTimeEntriesModifiedOrDeleted:timeSheetURI timesheetFormat:GEN4_INOUT_TIMESHEET];
                     }

        

                     [self.notificationCenter postNotificationName:REFRESH_TIMEENTRIES_DB_DATA object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];

                     [self.notificationCenter postNotificationName:successNotification object:nil userInfo:@{@"uri": timeSheetURI, @"module": TIMESHEETS_TAB_MODULE_NAME}];

                     NSArray *timesheetsArr=[self.timesheetModel getTimeSheetInfoSheetIdentity:timeSheetURI];
                     if (timesheetsArr.count>0)
                     {
                         [self.timesheetModel deleteOperationName:TIMESHEET_SAVE_INFLIGHT andTimesheetURI:timeSheetURI];
                     }


                     [self executeRemainingActionsOnTimeSheetURI:timeSheetURI];


                 });
             }
             else
             {
                 NSArray *timesheetsArr=[self.timesheetModel getTimeSheetInfoSheetIdentity:timeSheetURI];
                 if (timesheetsArr.count>0)
                 {
                     // if save fails revert the inflight mode to save operation
                     [self.timesheetModel updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:timeSheetURI];
                 }

                 [self.notificationCenter postNotificationName:errorNotification object:nil userInfo:@{@"uri": timeSheetURI, @"error_msg": error, @"module": TIMESHEETS_TAB_MODULE_NAME}];

                 [self businessLogicErrorHandlingFortimesheetUri:timeSheetURI];
             }
            return nil;
        } error:^id(NSError *error) {
            NSArray *timesheetsArr=[self.timesheetModel getTimeSheetInfoSheetIdentity:timeSheetURI];
            if (timesheetsArr.count>0)
            {
                // if save fails revert the inflight mode to save operation
                [self.timesheetModel updateTimesheetWithOperationName:TIMESHEET_SAVE_OPERATION andTimesheetURI:timeSheetURI];
            }
            return  nil;
        }];

    }

    else if (_serviceName==WIDGET_TIMESHEET_SUBMIT_SERVICE || _serviceName==WIDGET_TIMESHEET_RESUBMIT_SERVICE)
    {



        id tempComment=[NSNull null];
        NSArray *timeSheetArray=[self.timesheetModel getTimeSheetInfoSheetIdentity:timeSheetURI];
        if (timeSheetArray.count>0)
        {
            NSString *submitComment = timeSheetArray[0][@"lastResubmitComments"];
            if (submitComment!=nil && ![submitComment isKindOfClass:[NSNull class]])
            {
               if(![submitComment isEqualToString:@""])
               {
                 tempComment=submitComment;
               }

            }
        }


        NSMutableDictionary *bodyDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          timeSheetURI ,@"timesheetUri",
                                          [Util getRandomGUID],@"unitOfWorkId",
                                          tempComment,@"comments",
                                          [NSNull null],@"changeReason",
                                          @"true",@"attestationStatus",
                                          nil];




        NSString *urlString = [self urlStringWithEndpointName:@"Gen4SubmitTimesheetData"];
        NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:bodyDictionary options:0 error:nil];


        NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
        NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                              @"PayLoadStr": requestBodyString};

        NSMutableURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];

        [request setValue:RequestMadeWhilePendingQueueSyncHeaderValue forHTTPHeaderField:RequestMadeWhilePendingQueueSyncHeaderKey];
        NSMutableDictionary *timesheetDict=nil;
        NSArray *timesheetsArr=[self.timesheetModel getTimeSheetInfoSheetIdentity:timeSheetURI];
        if (timesheetsArr.count>0)
        {
            timesheetDict=[timesheetsArr[0] mutableCopy];
            [timesheetDict setObject:TIMESHEET_SUBMITTED forKey:@"approvalStatus"];
            [self.timesheetModel updateTimesheetDataForTimesheetUri:timeSheetURI withDataDict:timesheetDict];
        }

        KSPromise *promise = [self.client promiseWithRequest:request];
        [promise then:^id(NSDictionary *json) {
            id error = [json objectForKey:@"error"];
            if (error == nil) {

                dispatch_async(dispatch_get_main_queue(), ^{

                    if (timesheetsArr.count>0)
                    {
                        if (_serviceName == WIDGET_TIMESHEET_SUBMIT_SERVICE)
                        {
                           [self.timesheetModel deleteOperationName:TIMESHEET_SUBMIT_OPERATION andTimesheetURI:timeSheetURI];
                        }
                        else if (_serviceName == WIDGET_TIMESHEET_RESUBMIT_SERVICE)
                        {
                            [self.timesheetModel deleteOperationName:TIMESHEET_RESUBMIT_OPERATION andTimesheetURI:timeSheetURI];
                        }

                    }



                    [self.timesheetService handleTimesheetsSummaryFetchData:[NSMutableDictionary dictionaryWithObject:json forKey:@"response"] isFromSave:YES];



                    [self.notificationCenter postNotificationName:REFRESH_TIMEENTRIES_DB_DATA object:nil userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"isDataCache"]];

                    [self.notificationCenter postNotificationName:successNotification object:nil userInfo:@{@"uri": timeSheetURI, @"module": TIMESHEETS_TAB_MODULE_NAME}];


                    [self executeRemainingActionsOnTimeSheetURI:timeSheetURI];


                });
            }

            else
            {
                [self.notificationCenter postNotificationName:errorNotification object:nil userInfo:@{@"uri": timeSheetURI, @"error_msg": error, @"module": TIMESHEETS_TAB_MODULE_NAME}];

                 [self businessLogicErrorHandlingFortimesheetUri:timeSheetURI];
            }

            return nil;
        } error:^id(NSError *error) {

            NSArray *timesheetsArr=[self.timesheetModel getTimeSheetInfoSheetIdentity:timeSheetURI];
            NSMutableDictionary *timesheetDict=nil;
            if (timesheetsArr.count>0)
            {
                timesheetDict=[timesheetsArr[0] mutableCopy];
                [timesheetDict setObject:TIMESHEET_PENDING_SUBMISSION forKey:@"approvalStatus" ];
                [self.timesheetModel updateTimesheetDataForTimesheetUri:timeSheetURI withDataDict:timesheetDict];
            }

            return  nil;
        }];

    }
    else if (_serviceName==WIDGET_TIMESHEET_REOPEN_SERVICE)
    {}
}

-(void)executeRemainingActionsOnTimeSheetURI:(NSString *)timesheetURI
{

    NSArray *timesheetsArr = [self.timesheetModel getTimeSheetInfoSheetIdentity:timesheetURI];
    if ([timesheetsArr count]>0)
    {
        NSString *operationData=[[timesheetsArr objectAtIndex:0]objectForKey:@"operations"];

        NSMutableArray *operationArr=nil;

        if (operationData ==nil || [operationData isKindOfClass:[NSNull class]])
        {
            operationArr=[NSMutableArray array];
        }
        else
        {
            operationArr=[NSMutableArray arrayWithArray:[operationData componentsSeparatedByString:@"|"]];
        }

        for (NSString *operationName in operationArr)
        {
            NSLog(@"operationArr=%@ fot timesheeturi=%@",operationArr,timesheetURI);
            if ([operationName isEqualToString:TIMESHEET_SAVE_OPERATION])
            {
                [self callServiceWithName:WIDGET_TIMESHEET_SAVE_SERVICE andTimeSheetURI:timesheetURI];
                break;
            }
            else if ([operationName isEqualToString:TIMESHEET_SUBMIT_OPERATION])
            {
                [self callServiceWithName:WIDGET_TIMESHEET_SUBMIT_SERVICE andTimeSheetURI:timesheetURI];
                break;
            }
            else if ([operationName isEqualToString:TIMESHEET_REOPEN_OPERATION])
            {
                [self callServiceWithName:WIDGET_TIMESHEET_REOPEN_SERVICE andTimeSheetURI:timesheetURI];
                break;
            }
            else if ([operationName isEqualToString:TIMESHEET_RESUBMIT_OPERATION])
            {
                [self callServiceWithName:WIDGET_TIMESHEET_RESUBMIT_SERVICE andTimeSheetURI:timesheetURI];
                break;
            }

        }

    }
}


#pragma mark - Utility Method

-(NSMutableArray *)createTimesheetDataArray:(NSString *)timesheetURI forTimeSheetFormat:(NSString *)timeSheetFormat
{

    NSMutableArray *timesheetDataArray=[[NSMutableArray alloc]init];

    if ([timeSheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timeSheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
    {

        NSMutableArray *availableEntryDatesArray=[NSMutableArray array];
        NSMutableArray *tsEntryDataArray=[self createCurrentTimesheetEntryList:timesheetURI forTimeSheetFormat:timeSheetFormat];

        NSMutableArray *dbTimeEntriesArray=[NSMutableArray arrayWithArray:[self.timesheetModel getTimeEntriesForExtendedInOutSheetFromDB:timesheetURI andTimeSheetFormat:timeSheetFormat]];

        for (int i=0; i<[dbTimeEntriesArray count]; i++)
        {

            NSMutableArray *arrayOfEntries=[dbTimeEntriesArray objectAtIndex:i];
            if ([arrayOfEntries count]>0)
            {
                NSDate *tmpDate = [Util convertTimestampFromDBToDate:[[[arrayOfEntries objectAtIndex:0] objectForKey:@"timesheetEntryDate"] stringValue]];

                NSCalendar *gregorian=[NSCalendar currentCalendar];
                [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                NSUInteger flags = ( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay );
                NSDate * date = [gregorian dateFromComponents:[gregorian components:flags fromDate:tmpDate]];
                [availableEntryDatesArray addObject:date];
            }

        }

        for (int i=0; i<[tsEntryDataArray count]; i++)
        {
            NSMutableArray *temptimesheetEntryDataArray=[[NSMutableArray alloc]init];
            NSString *dateString = [[tsEntryDataArray objectAtIndex:i] entryDate];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

            NSLocale *locale=[NSLocale currentLocale];
            [dateFormatter setLocale:locale];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
            [dateFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
            NSDate *date = [dateFormatter dateFromString:dateString];

            if ([availableEntryDatesArray containsObject:date ])
            {
                BOOL isAtleastOneTimeInOutPresent=NO;
                NSUInteger index=[availableEntryDatesArray indexOfObject:date];
                NSArray *array=[dbTimeEntriesArray objectAtIndex:index];
                for (int m=0; m<[array count]; m++)
                {
                    NSMutableDictionary *dict=[array objectAtIndex:m];
                    NSString *timesheetEntryDate=[dict objectForKey:@"timesheetEntryDate"];
                    NSString *timePunchesUri=[dict objectForKey:@"timePunchesUri"];
                    NSString *timeAllocationUri=[dict objectForKey:@"timeAllocationUri"];
                    NSString *activityName=[dict objectForKey:@"activityName"];
                    NSString *activityUri=[dict objectForKey:@"activityUri"];
                    NSString *billingName=[dict objectForKey:@"billingName"];
                    NSString *billingUri=[dict objectForKey:@"billingUri"];
                    NSString *projectName=[dict objectForKey:@"projectName"];
                    NSString *projectUri=[dict objectForKey:@"projectUri"];
                    NSString *clientName=[dict objectForKey:@"clientName"];
                    NSString *clientUri=[dict objectForKey:@"clientUri"];
                    //MOBI-746
                    NSString *programName=[dict objectForKey:@"programName"];
                    NSString *programUri=[dict objectForKey:@"programUri"];
                    NSString *taskName=[dict objectForKey:@"taskName"];
                    NSString *taskUri=[dict objectForKey:@"taskUri"];
                    NSString *timeOffName=[dict objectForKey:@"timeOffTypeName"];
                    NSString *timeOffUri=[dict objectForKey:@"timeOffUri"];
                    NSString *entryType=[dict objectForKey:@"entryType"];
                    NSString *comments=[dict objectForKey:@"comments"];
                    NSString *durationHourFormat=[dict objectForKey:@"durationHourFormat"];

                    NSString *tempTime_in=[dict objectForKey:@"time_in"];
                    NSString *temp_Time_out=[dict objectForKey:@"time_out"];
                    NSString *time_in=[dict objectForKey:@"time_in"];
                    NSString *time_out=[dict objectForKey:@"time_out"];
                    NSString *rowUri=[dict objectForKey:@"rowUri"];
                    //Implentation for US8956//JUHI
                    NSString *breakName=[dict objectForKey:@"breakName"];
                    NSString *breakUri=[dict objectForKey:@"breakUri"];
                    NSString *rowNumber=[dict objectForKey:@"rowNumber"];

                    BOOL hasTimeEntryValue = NO;

                    if ([dict objectForKey:@"hasTimeEntryValue"]!=nil && [dict objectForKey:@"hasTimeEntryValue"]!=(id)[NSNull null]) {
                        hasTimeEntryValue = [[dict objectForKey:@"hasTimeEntryValue"] boolValue];
                    }

                    if (tempTime_in != (id)[NSNull null])
                    {
                        NSArray *timeInCompsArr=[tempTime_in componentsSeparatedByString:@":"];
                        if ([timeInCompsArr count]==3)
                        {
                            NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeInCompsArr objectAtIndex:0],[timeInCompsArr objectAtIndex:1]];
                            NSArray *amPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                            if ([amPmCompsArr count]==2)
                            {
                                time_in=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                            }
                        }
                    }

                    if (temp_Time_out != (id)[NSNull null])
                    {
                        NSArray *timeOutCompsArr=[temp_Time_out componentsSeparatedByString:@":"];
                        if ([timeOutCompsArr count]==3)
                        {
                            NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeOutCompsArr objectAtIndex:0],[timeOutCompsArr objectAtIndex:1]];
                            NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                            if ([amPmCompsArr count]==2)
                            {
                                time_out=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                            }
                        }
                    }

                    TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
                    NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                    NSDate *timentryDate=[Util convertTimestampFromDBToDate:timesheetEntryDate];

                    BOOL isMidnightCrossover=FALSE;
                    if (temp_Time_out != (id)[NSNull null])
                    {
                        NSArray *timeOutCompsArr=[temp_Time_out componentsSeparatedByString:@":"];
                        if ([timeOutCompsArr count]==3)
                        {
                            NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeOutCompsArr objectAtIndex:0],[timeOutCompsArr objectAtIndex:1]];
                            NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                            if ([amPmCompsArr count]==2)
                            {
                                time_out=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                if ([amPmCompsArr[0]isEqualToString:@"59"] && [hrsMinsStr isEqualToString:@"11:59"] && ([amPmCompsArr[1]isEqualToString:@"PM"] || [amPmCompsArr[1]isEqualToString:@"pm"]))
                                {
                                    isMidnightCrossover=TRUE;
                                }
                            }
                        }
                    }

                    if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]])
                        [multiDayInOutDict setObject:[time_in lowercaseString] forKey:@"in_time"];
                    else
                        [multiDayInOutDict setObject:@"" forKey:@"in_time"];

                    if (time_out!=nil && ![time_out isKindOfClass:[NSNull class]])
                        [multiDayInOutDict setObject:[time_out lowercaseString] forKey:@"out_time"];
                    else
                        [multiDayInOutDict setObject:@"" forKey:@"out_time"];

                    if (isMidnightCrossover)
                    {
                        [multiDayInOutDict setObject:[NSNumber numberWithBool:YES] forKey:@"isMidnightCrossover"];
                    }

                    NSMutableArray *udfArray=[[NSMutableArray alloc]init];
                    if (timeOffName!=nil && (![timeOffName isKindOfClass:[NSNull class]] && ![timeOffName isEqualToString:@""]))
                    {
                        if ([entryType isEqualToString:Time_Off_Key])
                        {
                            [tsEntryObject setEntryType:Time_Off_Key];
                            [tsEntryObject setTimeEntryTimeOffRowUri:rowUri];
                        }
                        else
                        {
                            [tsEntryObject setEntryType:Adhoc_Time_OffKey];
                        }

                        NSMutableArray *tempCustomFieldArray=[self getUDFArrayForModuleName:TIMEOFF_UDF andEntryDate:timentryDate andEntryType:entryType andRowUri:timeAllocationUri isRowEditable:YES andTimeSheetUri:timesheetURI];
                        for (int i=0; i<[tempCustomFieldArray count]; i++)
                        {
                            NSDictionary *udfDict = [tempCustomFieldArray objectAtIndex: i];
                            NSString *udfType=[udfDict objectForKey:@"type"];
                            NSString *udfName=[udfDict objectForKey:@"name"];
                            NSString *udfUri=[udfDict objectForKey:@"uri"];

                            if ([udfType isEqualToString:TEXT_UDF_TYPE])
                            {
                                NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_TEXT];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfArray addObject:udfDetails];


                            }
                            else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
                            {
                                NSString *defaultValue=nil;
                                if ([entryType isEqualToString:Time_Off_Key])
                                {
                                    NSString *tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                    if (tempDefaultValue!=nil && ![tempDefaultValue isKindOfClass:[NSNull class]]&& ![tempDefaultValue isEqualToString:@""]&&![tempDefaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                    {
                                        defaultValue=tempDefaultValue;
                                    }
                                    else
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }

                                }
                                else
                                {
                                    defaultValue=[udfDict objectForKey:@"defaultValue"];
                                }
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_NUMERIC];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setDecimalPoints:defaultDecimalValue];
                                [udfArray addObject:udfDetails];


                            }
                            else if ([udfType isEqualToString:DATE_UDF_TYPE])
                            {
                                NSString *defaultValue=nil;
                                id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])
                                {
                                    defaultValue=RPLocalizedString(NONE_STRING, @"");
                                }
                                else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                                    if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                        defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                    }
                                    else{
                                        NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                        defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                                    }

                                }
                                id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                if ([systemDefaultValue isKindOfClass:[NSDate class]])
                                {
                                    systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                                }
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_DATE];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfArray addObject:udfDetails];


                                ;
                            }
                            else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                            {
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_DROPDOWN];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                [udfArray addObject:udfDetails];

                            }




                        }

                        if (time_in==nil||[time_in isKindOfClass:[NSNull class]]||time_out==nil||[time_out isKindOfClass:[NSNull class]])
                        {

                            NSString *key=nil;
                            BOOL isProjectAccess=FALSE;
                            BOOL isActivityAccess=FALSE;
                            BOOL isBreakAccess=FALSE;

                            isProjectAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
                            isActivityAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];

                            SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                            NSDictionary *dictionary=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                            isBreakAccess=[[dictionary objectForKey:@"allowBreakForInOutGen4"] boolValue];

                            if (isProjectAccess)
                            {//Implemented as per TIME-495//JUHI
                                if (projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]])
                                {
                                    key=projectUri;
                                }
                                else
                                    key=@"";


                            }
                            else if (isActivityAccess)
                            {//Implemented as per TIME-495//JUHI
                                if (activityUri!=nil && ![activityUri isKindOfClass:[NSNull class]])
                                {
                                    key=activityUri;
                                }
                                else
                                    key=@"";


                            }
                            else if (isBreakAccess)
                            {//Implemented as per TIME-495//JUHI
                                if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]])
                                {
                                    key=breakUri;
                                }
                                else
                                    key=@"";

                            }
                            else
                            {
                                key=@"";
                            }
                            NSMutableArray *timePunchesArr=[dict objectForKey:key];

                            if (key==nil ||[key isKindOfClass:[NSNull class]]||[key isEqualToString:@""]) {
                                timePunchesArr=[dict objectForKey:[NSNull null]];
                            }
                            double totalHours=0;
                            double w_o_RoundedTotalHours=0;

                            for (int count=0; count<[timePunchesArr count]; count++)
                            {
                                NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                                NSDictionary *punchDict=[timePunchesArr objectAtIndex:count];

                                NSString *inTime=nil;
                                NSString *outTime=nil;

                                NSString *tempTime_in=[punchDict objectForKey:@"in_time"];
                                NSString *temp_Time_out=[punchDict objectForKey:@"out_time"];
                                NSString *time_in=[punchDict objectForKey:@"in_time"];
                                NSString *time_out=[punchDict objectForKey:@"out_time"];
                                //NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                NSString *clientPunchID=[punchDict objectForKey:@"clientPunchId"];
                                if (clientPunchID==nil || [clientPunchID isKindOfClass:[NSNull class]])
                                {
                                    clientPunchID=[punchDict objectForKey:@"clientID"];
                                }
                                NSArray *timeInCompsArr=[tempTime_in componentsSeparatedByString:@":"];
                                if ([timeInCompsArr count]==3)
                                {
                                    NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeInCompsArr objectAtIndex:0],[timeInCompsArr objectAtIndex:1]];
                                    NSArray *amPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                    if ([amPmCompsArr count]==2)
                                    {
                                        time_in=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                    }
                                }

                                NSArray *timeOutCompsArr=[temp_Time_out componentsSeparatedByString:@":"];
                                if ([timeOutCompsArr count]==3)
                                {
                                    NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeOutCompsArr objectAtIndex:0],[timeOutCompsArr objectAtIndex:1]];
                                    NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                    if ([amPmCompsArr count]==2)
                                    {
                                        time_out=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                    }
                                }


                                if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]])
                                    inTime=[time_in lowercaseString];
                                else
                                    inTime=@"";

                                if (time_out!=nil && ![time_out isKindOfClass:[NSNull class]])
                                    outTime=[time_out lowercaseString];
                                else
                                    outTime=@"";



                                if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]] &&![time_in isEqualToString:@""] && time_out!=nil && ![time_out isKindOfClass:[NSNull class]]&&![time_out isEqualToString:@""])
                                {
                                    totalHours=totalHours+[[Util getNumberOfHoursForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                    w_o_RoundedTotalHours=w_o_RoundedTotalHours+[[Util getNumberOfHoursWithoutRoundingForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                }

                                NSString *tempComments=[punchDict objectForKey:@"comments"];
                                if (tempComments==nil ||[tempComments isKindOfClass:[NSNull class]]||[tempComments isEqualToString:@""])
                                {
                                    tempComments=@"";
                                }
                                NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                [formattedTimePunchesDict setObject:tempComments forKey:@"comments"];
                                [formattedTimePunchesDict setObject:inTime forKey:@"in_time"];
                                [formattedTimePunchesDict setObject:outTime forKey:@"out_time"];
                                [formattedTimePunchesDict setObject:udfArray forKey:@"udfArray"];
                                [formattedTimePunchesDict setObject:timePunchesUri forKey:@"timePunchesUri"];
                                if(clientPunchID!=nil && ![clientPunchID isKindOfClass:[NSNull class]])
                                {
                                    [formattedTimePunchesDict setObject:clientPunchID forKey:@"clientID"];
                                }
                                [timePunchesArr replaceObjectAtIndex:count withObject:formattedTimePunchesDict];


                            }

                            [tsEntryObject setTimePunchesArray:timePunchesArr];
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"%f",totalHours]];
                            [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[NSString stringWithFormat:@"%f",w_o_RoundedTotalHours]];



                        }
                        else
                        {

                            NSString *key=nil;


                            BOOL isProjectAccess=FALSE;
                            BOOL isActivityAccess=FALSE;
                            BOOL isBreakAccess=FALSE;

                            isProjectAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
                            isActivityAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];

                            SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                            NSDictionary *dictionary=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                            isBreakAccess=[[dictionary objectForKey:@"allowBreakForInOutGen4"] boolValue];


                            if (isProjectAccess)
                            {//Implemented as per TIME-495//JUHI
                                if (projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]])
                                {
                                    key=projectUri;
                                }
                                else
                                    key=@"";


                            }
                            else if (isActivityAccess)
                            {//Implemented as per TIME-495//JUHI
                                if (activityUri!=nil && ![activityUri isKindOfClass:[NSNull class]])
                                {
                                    key=activityUri;
                                }
                                else
                                    key=@"";


                            }
                            else if (isBreakAccess)
                            {//Implemented as per TIME-495//JUHI
                                if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]])
                                {
                                    key=breakUri;
                                }
                                else
                                    key=@"";

                            }
                            else
                            {
                                key=@"";
                            }

                            NSMutableArray *timePunchesArr=[dict objectForKey:key];
                            if (key==nil ||[key isKindOfClass:[NSNull class]]||[key isEqualToString:@""]) {
                                timePunchesArr=[dict objectForKey:[NSNull null]];
                            }
                            double totalHours=0;
                            double w_o_RoundedTotalHours=0;

                            for (int count=0; count<[timePunchesArr count]; count++)
                            {
                                NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                                NSDictionary *punchDict=[timePunchesArr objectAtIndex:count];

                                NSString *inTime=nil;
                                NSString *outTime=nil;


                                NSString *tempTime_in=[punchDict objectForKey:@"in_time"];
                                NSString *temp_Time_out=[punchDict objectForKey:@"out_time"];
                                NSString *time_in=[punchDict objectForKey:@"in_time"];
                                NSString *time_out=[punchDict objectForKey:@"out_time"];
                                //NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                NSString *clientPunchID=[punchDict objectForKey:@"clientPunchId"];
                                if (clientPunchID==nil || [clientPunchID isKindOfClass:[NSNull class]])
                                {
                                    clientPunchID=[punchDict objectForKey:@"clientID"];
                                }
                                NSArray *timeInCompsArr=[tempTime_in componentsSeparatedByString:@":"];
                                if ([timeInCompsArr count]==3)
                                {
                                    NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeInCompsArr objectAtIndex:0],[timeInCompsArr objectAtIndex:1]];
                                    NSArray *amPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                    if ([amPmCompsArr count]==2)
                                    {
                                        time_in=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                    }
                                }

                                NSArray *timeOutCompsArr=[temp_Time_out componentsSeparatedByString:@":"];
                                if ([timeOutCompsArr count]==3)
                                {
                                    NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeOutCompsArr objectAtIndex:0],[timeOutCompsArr objectAtIndex:1]];
                                    NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                    if ([amPmCompsArr count]==2)
                                    {
                                        time_out=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                    }
                                }


                                if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]])
                                    inTime=[time_in lowercaseString];
                                else
                                    inTime=@"";

                                if (time_out!=nil && ![time_out isKindOfClass:[NSNull class]])
                                    outTime=[time_out lowercaseString];
                                else
                                    outTime=@"";


                                if (tempTime_in!=nil &&  ![tempTime_in isKindOfClass:[NSNull class]]&&![tempTime_in isEqualToString:@""] &&temp_Time_out!=nil  && ![temp_Time_out isKindOfClass:[NSNull class]]&&![temp_Time_out isEqualToString:@""])
                                {
                                    totalHours=totalHours+[[Util getNumberOfHoursForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                    w_o_RoundedTotalHours=w_o_RoundedTotalHours+[[Util getNumberOfHoursWithoutRoundingForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                }


                                NSString *tempComments=[punchDict objectForKey:@"comments"];
                                if (tempComments==nil ||[tempComments isKindOfClass:[NSNull class]]||[tempComments isEqualToString:@""])
                                {
                                    tempComments=@"";
                                }
                                NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                [formattedTimePunchesDict setObject:tempComments forKey:@"comments"];
                                [formattedTimePunchesDict setObject:inTime forKey:@"in_time"];
                                [formattedTimePunchesDict setObject:outTime forKey:@"out_time"];
                                [formattedTimePunchesDict setObject:udfArray forKey:@"udfArray"];
                                [formattedTimePunchesDict setObject:timePunchesUri forKey:@"timePunchesUri"];
                                if(clientPunchID!=nil && ![clientPunchID isKindOfClass:[NSNull class]])
                                {
                                    [formattedTimePunchesDict setObject:clientPunchID forKey:@"clientID"];
                                }
                                [timePunchesArr replaceObjectAtIndex:count withObject:formattedTimePunchesDict];


                            }

                            [tsEntryObject setTimePunchesArray:timePunchesArr];
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"%f",totalHours]];
                            [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[NSString stringWithFormat:@"%f",w_o_RoundedTotalHours]];



                        }
                        [tsEntryObject setIsTimeoffSickRowPresent:YES];
                        [tsEntryObject setTimeAllocationUri:timeAllocationUri];
                        [tsEntryObject setRowUri:timeAllocationUri];
                        [tsEntryObject setTimeEntryCellOEFArray:[self constructCellOEFObjectForTimeSheetUri:timesheetURI andtimesheetFormat:timeSheetFormat andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:timeAllocationUri]];
                        [tsEntryObject setTimeEntryRowOEFArray:[self constructCellOEFObjectForTimeSheetUri:timesheetURI andtimesheetFormat:timeSheetFormat andOEFLevel:TIMESHEET_ROW_OEF andTimePunchUri:timeAllocationUri]];
                        [tsEntryObject setTimeEntryHoursInDecimalFormat:[Util getRoundedValueFromDecimalPlaces: [[dict objectForKey:@"durationDecimalFormat"] doubleValue ]withDecimalPlaces:2 ]];
                        [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[Util getRoundedValueFromDecimalPlaces: [[dict objectForKey:@"durationDecimalFormat"] doubleValue ]withDecimalPlaces:2 ]];
                    }
                    else
                    {

                        [tsEntryObject setEntryType:Time_Entry_Key];
                        isAtleastOneTimeInOutPresent=YES;
                        [tsEntryObject setIsTimeoffSickRowPresent:NO];
                        [tsEntryObject setTimePunchUri:timePunchesUri];
                        [tsEntryObject setRowUri:timePunchesUri];
                        [tsEntryObject setTimeEntryCellOEFArray:[self constructCellOEFObjectForTimeSheetUri:timesheetURI andtimesheetFormat:timeSheetFormat andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:rowUri]];
                        [tsEntryObject setTimeEntryRowOEFArray:[self constructCellOEFObjectForTimeSheetUri:timesheetURI andtimesheetFormat:timeSheetFormat andOEFLevel:TIMESHEET_ROW_OEF andTimePunchUri:rowUri]];

                        if (time_in==nil||[time_in isKindOfClass:[NSNull class]]||time_out==nil||[time_out isKindOfClass:[NSNull class]])
                        {

                            NSString *key=nil;
                            BOOL isProjectAccess=FALSE;
                            BOOL isActivityAccess=FALSE;
                            BOOL isBreakAccess=FALSE;

                            isProjectAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
                            isActivityAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];
                            SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                            NSDictionary *dictionary=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                            isBreakAccess=[[dictionary objectForKey:@"allowBreakForInOutGen4"] boolValue];


                            if (isProjectAccess)
                            {//Implemented as per TIME-495//JUHI
                                if (projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]])
                                {
                                    key=projectUri;
                                }
                                else
                                    key=@"";


                            }
                            else if (isActivityAccess)
                            {//Implemented as per TIME-495//JUHI
                                if (activityUri!=nil && ![activityUri isKindOfClass:[NSNull class]])
                                {
                                    key=activityUri;
                                }
                                else
                                    key=@"";


                            }
                            else if (isBreakAccess)
                            {//Implemented as per TIME-495//JUHI
                                if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]])
                                {
                                    key=breakUri;
                                }
                                else
                                    key=@"";

                            }
                            else
                            {
                                key=@"";
                            }

                            NSMutableArray *timePunchesArr=[dict objectForKey:key];
                            if (key==nil ||[key isKindOfClass:[NSNull class]]||[key isEqualToString:@""]) {
                                timePunchesArr=[dict objectForKey:[NSNull null]];
                            }
                            double totalHours=0;
                            double w_o_RoundedTotalHours=0;

                            for (int count=0; count<[timePunchesArr count]; count++)
                            {
                                NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                                NSDictionary *punchDict=[timePunchesArr objectAtIndex:count];

                                NSString *inTime=nil;
                                NSString *outTime=nil;


                                NSString *tempTime_in=[punchDict objectForKey:@"in_time"];
                                NSString *temp_Time_out=[punchDict objectForKey:@"out_time"];
                                NSString *time_in=[punchDict objectForKey:@"in_time"];
                                NSString *time_out=[punchDict objectForKey:@"out_time"];
                                // NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                NSString *clientPunchID=[punchDict objectForKey:@"clientPunchId"];
                                if (clientPunchID==nil || [clientPunchID isKindOfClass:[NSNull class]])
                                {
                                    clientPunchID=[punchDict objectForKey:@"clientID"];
                                }
                                NSArray *timeInCompsArr=[tempTime_in componentsSeparatedByString:@":"];
                                if ([timeInCompsArr count]==3)
                                {
                                    NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeInCompsArr objectAtIndex:0],[timeInCompsArr objectAtIndex:1]];
                                    NSArray *amPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                    if ([amPmCompsArr count]==2)
                                    {
                                        time_in=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                    }
                                }

                                NSArray *timeOutCompsArr=[temp_Time_out componentsSeparatedByString:@":"];
                                if ([timeOutCompsArr count]==3)
                                {
                                    NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeOutCompsArr objectAtIndex:0],[timeOutCompsArr objectAtIndex:1]];
                                    NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                    if ([amPmCompsArr count]==2)
                                    {
                                        time_out=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                    }
                                }


                                if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]])
                                    inTime=[time_in lowercaseString];
                                else
                                    inTime=@"";

                                if (time_out!=nil && ![time_out isKindOfClass:[NSNull class]])
                                    outTime=[time_out lowercaseString];
                                else
                                    outTime=@"";



                                if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]] &&![time_in isEqualToString:@""] && time_out!=nil && ![time_out isKindOfClass:[NSNull class]]&&![time_out isEqualToString:@""])
                                {
                                    totalHours=totalHours+[[Util getNumberOfHoursForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                    w_o_RoundedTotalHours=w_o_RoundedTotalHours+[[Util getNumberOfHoursWithoutRoundingForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                }

                                NSString *tempComments=[punchDict objectForKey:@"comments"];
                                if (tempComments==nil ||[tempComments isKindOfClass:[NSNull class]]||[tempComments isEqualToString:@""])
                                {
                                    tempComments=@"";
                                }
                                NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                [formattedTimePunchesDict setObject:tempComments forKey:@"comments"];
                                [formattedTimePunchesDict setObject:inTime forKey:@"in_time"];
                                [formattedTimePunchesDict setObject:outTime forKey:@"out_time"];
                                [formattedTimePunchesDict setObject:udfArray forKey:@"udfArray"];
                                [formattedTimePunchesDict setObject:timePunchesUri forKey:@"timePunchesUri"];
                                if(clientPunchID!=nil && ![clientPunchID isKindOfClass:[NSNull class]])
                                {
                                    [formattedTimePunchesDict setObject:clientPunchID forKey:@"clientID"];
                                }
                                [timePunchesArr replaceObjectAtIndex:count withObject:formattedTimePunchesDict];


                            }

                            [tsEntryObject setTimePunchesArray:timePunchesArr];
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"%f",totalHours]];
                            [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[NSString stringWithFormat:@"%f",w_o_RoundedTotalHours]];

                        }
                        else
                        {


                            NSString *key=nil;


                            BOOL isProjectAccess=FALSE;
                            BOOL isActivityAccess=FALSE;
                            BOOL isBreakAccess=FALSE;

                            isProjectAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetProjectAccess" forSheetUri:timesheetURI];
                            isActivityAccess=[self.timesheetModel getTimesheetCapabilityStatusForGivenPermissions:@"hasTimesheetActivityAccess" forSheetUri:timesheetURI];

                            SupportDataModel *supportModel=[[SupportDataModel alloc]init];
                            NSDictionary *dictionary=[supportModel getTimesheetPermittedApprovalActionsDataToDBWithUri:timesheetURI];
                            isBreakAccess=[[dictionary objectForKey:@"allowBreakForInOutGen4"] boolValue];


                            if (isProjectAccess)
                            {//Implemented as per TIME-495//JUHI
                                if (projectUri!=nil && ![projectUri isKindOfClass:[NSNull class]])
                                {
                                    key=projectUri;
                                }
                                else
                                    key=@"";


                            }
                            else if (isActivityAccess)
                            {//Implemented as per TIME-495//JUHI
                                if (activityUri!=nil && ![activityUri isKindOfClass:[NSNull class]])
                                {
                                    key=activityUri;
                                }
                                else
                                    key=@"";


                            }
                            else if (isBreakAccess)
                            {//Implemented as per TIME-495//JUHI
                                if (breakUri!=nil && ![breakUri isKindOfClass:[NSNull class]])
                                {
                                    key=breakUri;
                                }
                                else
                                    key=@"";

                            }
                            else
                            {
                                key=@"";
                            }

                            NSMutableArray *timePunchesArr=[dict objectForKey:key];
                            if (key==nil ||[key isKindOfClass:[NSNull class]]||[key isEqualToString:@""]) {
                                timePunchesArr=[dict objectForKey:[NSNull null]];
                            }
                            double totalHours=0;
                            double w_o_RoundedTotalHours=0;

                            for (int count=0; count<[timePunchesArr count]; count++)
                            {

                                NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                                NSDictionary *punchDict=[timePunchesArr objectAtIndex:count];

                                NSString *inTime=nil;
                                NSString *outTime=nil;

                                NSString *tempTime_in=[punchDict objectForKey:@"in_time"];
                                NSString *temp_Time_out=[punchDict objectForKey:@"out_time"];
                                NSString *time_in=[punchDict objectForKey:@"in_time"];
                                NSString *time_out=[punchDict objectForKey:@"out_time"];
                                //NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                NSString *clientPunchID=[punchDict objectForKey:@"clientPunchId"];
                                if (clientPunchID==nil || [clientPunchID isKindOfClass:[NSNull class]])
                                {
                                    clientPunchID=[punchDict objectForKey:@"clientID"];
                                }
                                NSArray *timeInCompsArr=[tempTime_in componentsSeparatedByString:@":"];
                                if ([timeInCompsArr count]==3)
                                {
                                    NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeInCompsArr objectAtIndex:0],[timeInCompsArr objectAtIndex:1]];
                                    NSArray *amPmCompsArr=[[timeInCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                    if ([amPmCompsArr count]==2)
                                    {
                                        time_in=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                    }
                                }

                                NSArray *timeOutCompsArr=[temp_Time_out componentsSeparatedByString:@":"];
                                if ([timeOutCompsArr count]==3)
                                {
                                    NSString *hrsMinsStr=[NSString stringWithFormat:@"%@:%@",[timeOutCompsArr objectAtIndex:0],[timeOutCompsArr objectAtIndex:1]];
                                    NSArray *amPmCompsArr=[[timeOutCompsArr objectAtIndex:2] componentsSeparatedByString:@" "];
                                    if ([amPmCompsArr count]==2)
                                    {
                                        time_out=[NSString stringWithFormat:@"%@ %@",hrsMinsStr,[amPmCompsArr objectAtIndex:1]];
                                    }
                                }


                                if (time_in!=nil && ![time_in isKindOfClass:[NSNull class]])
                                    inTime=[time_in lowercaseString];
                                else
                                    inTime=@"";

                                if (time_out!=nil && ![time_out isKindOfClass:[NSNull class]])
                                    outTime=[time_out lowercaseString];
                                else
                                    outTime=@"";


                                if (tempTime_in!=nil &&  ![tempTime_in isKindOfClass:[NSNull class]]&&![tempTime_in isEqualToString:@""] &&temp_Time_out!=nil  && ![temp_Time_out isKindOfClass:[NSNull class]]&&![temp_Time_out isEqualToString:@""])
                                {
                                    totalHours=totalHours+[[Util getNumberOfHoursForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                    w_o_RoundedTotalHours=w_o_RoundedTotalHours+[[Util getNumberOfHoursWithoutRoundingForInTime:tempTime_in outTime:temp_Time_out]newDoubleValue];
                                }


                                NSString *tempComments=[punchDict objectForKey:@"comments"];
                                if (tempComments==nil ||[tempComments isKindOfClass:[NSNull class]]||[tempComments isEqualToString:@""])
                                {
                                    tempComments=@"";
                                }
                                NSString *timePunchesUri=[punchDict objectForKey:@"timePunchesUri"];
                                [formattedTimePunchesDict setObject:tempComments forKey:@"comments"];
                                [formattedTimePunchesDict setObject:inTime forKey:@"in_time"];
                                [formattedTimePunchesDict setObject:outTime forKey:@"out_time"];
                                [formattedTimePunchesDict setObject:udfArray forKey:@"udfArray"];
                                [formattedTimePunchesDict setObject:timePunchesUri forKey:@"timePunchesUri"];
                                if(clientPunchID!=nil && ![clientPunchID isKindOfClass:[NSNull class]])
                                {
                                    [formattedTimePunchesDict setObject:clientPunchID forKey:@"clientID"];
                                }
                               
                                [timePunchesArr replaceObjectAtIndex:count withObject:formattedTimePunchesDict];


                            }

                            [tsEntryObject setTimePunchesArray:timePunchesArr];
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"%f",totalHours]];
                            [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:[NSString stringWithFormat:@"%f",w_o_RoundedTotalHours]];


                        }

                    }

                    //NSString *timeEntryHoursInDecimal=[Util getRoundedValueFromDecimalPlaces:[durationDecimalFormat newDoubleValue]];
                    BOOL isBothInOutNull=NO;


                    [tsEntryObject setTimeEntryDate:timentryDate];
                    [tsEntryObject setTimeEntryActivityName:activityName];
                    [tsEntryObject setTimeEntryActivityUri:activityUri];
                    [tsEntryObject setTimeEntryBillingName:billingName];
                    [tsEntryObject setTimeEntryBillingUri:billingUri];
                    [tsEntryObject setTimeEntryProjectName:projectName];
                    [tsEntryObject setTimeEntryProjectUri:projectUri];
                    [tsEntryObject setTimeEntryClientName:clientName];
                    [tsEntryObject setTimeEntryClientUri:clientUri];
                    //MOBI-746
                    [tsEntryObject setTimeEntryProgramName:programName];
                    [tsEntryObject setTimeEntryProgramUri:programUri];
                    [tsEntryObject setTimeEntryTaskName:taskName];
                    [tsEntryObject setTimeEntryTaskUri:taskUri];
                    [tsEntryObject setTimeEntryTimeOffName:timeOffName];
                    [tsEntryObject setTimeEntryTimeOffUri:timeOffUri];
                    [tsEntryObject setTimeEntryComments:comments];
                    [tsEntryObject setTimeEntryHoursInHourFormat:durationHourFormat];
                    [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                    [tsEntryObject setTimeEntryUdfArray:udfArray];
                    [tsEntryObject setTimesheetUri:timesheetURI];
                    //Implentation for US8956//JUHI
                    [tsEntryObject setBreakName:breakName];
                    [tsEntryObject setBreakUri:breakUri];
                    [tsEntryObject setRownumber:rowNumber];
                    [tsEntryObject setHasTimeEntryValue:hasTimeEntryValue];
                    if (!isBothInOutNull)
                    {
                        [temptimesheetEntryDataArray addObject:tsEntryObject];
                    }


                }

                int indexOfObject=9999;
                for (int b=0; b<[temptimesheetEntryDataArray count]; b++)
                {
                    TimesheetEntryObject *tsEntryObject=[temptimesheetEntryDataArray objectAtIndex:b];
                    NSString *breakUri=[tsEntryObject breakUri];
                    NSString *timeEntryTimeOffUri=[tsEntryObject timeEntryTimeOffUri];
                    if ((breakUri==nil||[breakUri isKindOfClass:[NSNull class]])&&(timeEntryTimeOffUri==nil||[timeEntryTimeOffUri isKindOfClass:[NSNull class]]))
                    {
                        indexOfObject=b;
                    }
                }

                if (indexOfObject==9999)
                {
                    TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];

                    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
                    NSLocale *locale=[NSLocale currentLocale];
                    [formatter setLocale:locale];
                    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
                    NSDate *todayDate=[formatter dateFromString:dateString];


                    NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                    [multiDayInOutDict setObject:@"" forKey:@"in_time"];
                    [multiDayInOutDict setObject:@"" forKey:@"out_time"];

                    [tsEntryObject setTimeEntryDate:todayDate];
                    [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                    [tsEntryObject setTimeAllocationUri:@""];
                    [tsEntryObject setTimePunchUri:@""];
                    [tsEntryObject setTimeEntryHoursInHourFormat:@""];
                    [tsEntryObject setTimeEntryHoursInDecimalFormat:@"0.00"];
                    [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:@"0.00"];
                    [tsEntryObject setIsTimeoffSickRowPresent:NO];
                    [tsEntryObject setTimeEntryTimeOffName:@""];
                    [tsEntryObject setTimeEntryActivityName:@""];
                    [tsEntryObject setTimeEntryActivityUri:@""];
                    [tsEntryObject setTimeEntryBillingName:@""];
                    [tsEntryObject setTimeEntryBillingUri:@""];
                    [tsEntryObject setTimeEntryProjectName:@""];
                    [tsEntryObject setTimeEntryProjectUri:@""];
                    [tsEntryObject setTimeEntryClientName:nil];
                    [tsEntryObject setTimeEntryClientUri:nil];
                    //MOBI-746
                    [tsEntryObject setTimeEntryProgramName:nil];
                    [tsEntryObject setTimeEntryProgramUri:nil];
                    [tsEntryObject setTimeEntryTaskName:@""];
                    [tsEntryObject setTimeEntryTaskUri:@""];
                    [tsEntryObject setTimeEntryTimeOffName:@""];
                    [tsEntryObject setTimeEntryTimeOffUri:@""];
                    [tsEntryObject setTimeEntryComments:@""];
                    [tsEntryObject setTimeEntryUdfArray:nil];
                    [tsEntryObject setTimesheetUri:timesheetURI];
                    NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                    [formattedTimePunchesDict setObject:@"" forKey:@"comments"];
                    [formattedTimePunchesDict setObject:@"" forKey:@"in_time"];
                    [formattedTimePunchesDict setObject:@"" forKey:@"out_time"];
                    [formattedTimePunchesDict setObject:[NSMutableArray array] forKey:@"udfArray"];
                    [formattedTimePunchesDict setObject:@"" forKey:@"timePunchesUri"];
                    [formattedTimePunchesDict setObject:[Util getRandomGUID] forKey:@"clientID"];
                    NSMutableArray *timePunchesArr=[NSMutableArray array];
                    [timePunchesArr addObject:formattedTimePunchesDict];
                    [tsEntryObject setTimePunchesArray:timePunchesArr];
                    [tsEntryObject setBreakName:@""];
                    [tsEntryObject setBreakUri:@""];
                    [tsEntryObject setRowUri:@""];
                    [tsEntryObject setHasTimeEntryValue:NO];
                    BOOL isBothInOutNull=NO;


                    if (!isBothInOutNull)
                    {
                        [temptimesheetEntryDataArray addObject:tsEntryObject];
                    }

                }
                else
                {
                    TimesheetEntryObject *tEntryObject=(TimesheetEntryObject *)[temptimesheetEntryDataArray objectAtIndex:indexOfObject];
                    NSMutableArray *tmpPunchesArray=[tEntryObject timePunchesArray];

                    BOOL isEmptyEntryAlreadyPresent=NO;
                    for (int y=0; y<[tmpPunchesArray count]; y++)
                    {
                        NSMutableDictionary *timeDict=[tmpPunchesArray objectAtIndex:y];
                        if (timeDict!=nil && ![timeDict isKindOfClass:[NSNull class]])
                        {
                            NSString *inTimeString=[timeDict objectForKey:@"in_time"];
                            NSString *outTimeString=[timeDict objectForKey:@"out_time"];
                            if ((inTimeString==nil || [inTimeString isKindOfClass:[NSNull class]] || [inTimeString isEqualToString:@""]) && (outTimeString==nil || [outTimeString isKindOfClass:[NSNull class]]|| [outTimeString isEqualToString:@""]))
                            {
                                isEmptyEntryAlreadyPresent=YES;
                            }
                        }
                    }

                    if (isEmptyEntryAlreadyPresent==NO)
                    {
                        NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                        [formattedTimePunchesDict setObject:@"" forKey:@"comments"];
                        [formattedTimePunchesDict setObject:@"" forKey:@"in_time"];
                        [formattedTimePunchesDict setObject:@"" forKey:@"out_time"];
                        [formattedTimePunchesDict setObject:[NSMutableArray array] forKey:@"udfArray"];
                        [formattedTimePunchesDict setObject:@"" forKey:@"timePunchesUri"];
                        [formattedTimePunchesDict setObject:[Util getRandomGUID] forKey:@"clientID"];
                        [tmpPunchesArray addObject:formattedTimePunchesDict];
                        NSMutableArray *array=[NSMutableArray arrayWithArray:tmpPunchesArray];
                        [tEntryObject setTimePunchesArray:array];
                        [temptimesheetEntryDataArray replaceObjectAtIndex:indexOfObject withObject:tEntryObject];
                    }

                }

            }
            else
            {
                TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];

                NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
                NSLocale *locale=[NSLocale currentLocale];
                [formatter setLocale:locale];
                [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
                NSDate *todayDate=[formatter dateFromString:dateString];

                NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                [multiDayInOutDict setObject:@"" forKey:@"in_time"];
                [multiDayInOutDict setObject:@"" forKey:@"out_time"];

                [tsEntryObject setTimeEntryDate:todayDate];
                [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                [tsEntryObject setTimeAllocationUri:@""];
                [tsEntryObject setTimePunchUri:@""];
                [tsEntryObject setTimeEntryHoursInHourFormat:@""];
                [tsEntryObject setTimeEntryHoursInDecimalFormat:@"0.00"];
                [tsEntryObject setTimeEntryHoursInDecimalFormatWithOutRoundOff:@"0.00"];
                [tsEntryObject setIsTimeoffSickRowPresent:NO];
                [tsEntryObject setTimeEntryTimeOffName:@""];
                [tsEntryObject setTimeEntryActivityName:@""];
                [tsEntryObject setTimeEntryActivityUri:@""];
                [tsEntryObject setTimeEntryBillingName:@""];
                [tsEntryObject setTimeEntryBillingUri:@""];
                [tsEntryObject setTimeEntryProjectName:@""];
                [tsEntryObject setTimeEntryProjectUri:@""];
                [tsEntryObject setTimeEntryClientName:nil];
                [tsEntryObject setTimeEntryClientUri:nil];
                [tsEntryObject setTimeEntryTaskName:@""];
                [tsEntryObject setTimeEntryTaskUri:@""];
                [tsEntryObject setTimeEntryTimeOffName:@""];
                [tsEntryObject setTimeEntryTimeOffUri:@""];
                [tsEntryObject setTimeEntryComments:@""];
                [tsEntryObject setTimeEntryUdfArray:nil];
                [tsEntryObject setTimesheetUri:timesheetURI];
                NSMutableDictionary *formattedTimePunchesDict=[NSMutableDictionary dictionary];
                [formattedTimePunchesDict setObject:@"" forKey:@"comments"];
                [formattedTimePunchesDict setObject:@"" forKey:@"in_time"];
                [formattedTimePunchesDict setObject:@"" forKey:@"out_time"];
                [formattedTimePunchesDict setObject:[NSMutableArray array] forKey:@"udfArray"];
                [formattedTimePunchesDict setObject:@"" forKey:@"timePunchesUri"];
                [formattedTimePunchesDict setObject:[Util getRandomGUID] forKey:@"clientID"];
                NSMutableArray *timePunchesArr=[NSMutableArray array];
                [timePunchesArr addObject:formattedTimePunchesDict];
                [tsEntryObject setTimePunchesArray:timePunchesArr];
                [tsEntryObject setBreakName:@""];
                [tsEntryObject setBreakUri:@""];
                [tsEntryObject setRowUri:@""];
                [tsEntryObject setHasTimeEntryValue:NO];
                [temptimesheetEntryDataArray addObject:tsEntryObject];

            }
            [timesheetDataArray addObject:temptimesheetEntryDataArray];

        }

    }
    if ([timeSheetFormat isEqualToString:GEN4_STANDARD_TIMESHEET])
    {

        NSMutableArray *availableEntryDatesArray=[NSMutableArray array];
        NSMutableArray *availableEntriesDictArray=[NSMutableArray array];
        NSMutableArray *tsEntryDataArray=[self createCurrentTimesheetEntryList:timesheetURI forTimeSheetFormat:timeSheetFormat];
        NSMutableArray *dbTimeEntriesArray=[NSMutableArray arrayWithArray:[self.timesheetModel getGroupedStandardTimeEntriesForSheetFromDB:timesheetURI andTimesheetFormat:GEN4_STANDARD_TIMESHEET]];
        for (int i=0; i<[dbTimeEntriesArray count]; i++)
        {

            NSMutableArray *arrayOfEntries=[dbTimeEntriesArray objectAtIndex:i];

            for (int k=0; k<[arrayOfEntries count]; k++)
            {

                NSMutableArray *entryArray=[arrayOfEntries objectAtIndex:k];
                if ([entryArray count]>0)
                {
                    NSDate *tmpDate = [Util convertTimestampFromDBToDate:[[[entryArray objectAtIndex:0] objectForKey:@"timesheetEntryDate"] stringValue]];
                    NSCalendar *gregorian=[NSCalendar currentCalendar];
                    [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    NSUInteger flags = ( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay );
                    NSDate * date = [gregorian dateFromComponents:[gregorian components:flags fromDate:tmpDate]];
                    if (![availableEntryDatesArray containsObject:date])
                    {

                        [availableEntryDatesArray addObject:date];
                        [availableEntriesDictArray addObject:arrayOfEntries];
                    }

                }
            }

        }

        if (dbTimeEntriesArray.count>0)
        {
            for (int j=0; j<[tsEntryDataArray count]; j++)
            {

                NSMutableArray *temptimesheetEntryDataArray=[[NSMutableArray alloc]init];
                NSString *dateString = [[tsEntryDataArray objectAtIndex:j] entryDate];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

                NSLocale *locale=[NSLocale currentLocale];
                [dateFormatter setLocale:locale];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [dateFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
                NSDate *date = [dateFormatter dateFromString:dateString];

                if ([availableEntryDatesArray containsObject:date ])
                {
                    NSUInteger index=[availableEntryDatesArray indexOfObject:date];
                    NSMutableArray *arrayOfEntries=[availableEntriesDictArray objectAtIndex:index];
                    // Entry Available on this date
                    for (int m=0; m<[arrayOfEntries count]; m++)
                    {
                        NSMutableArray *entryArray=[arrayOfEntries objectAtIndex:m];
                        NSMutableDictionary *dict=[entryArray objectAtIndex:0];

                        NSString *value=[dict objectForKey:@"isObjectEmpty"];

                        if ([value isKindOfClass:[NSNull class]]|| value==nil)
                        {
                            //Entry available
                            TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];
                            NSDateFormatter *formatter=[[NSDateFormatter alloc] init];

                            NSLocale *locale=[NSLocale currentLocale];
                            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                            [formatter setLocale:locale];
                            [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
                            NSDate *todayDate=[formatter dateFromString:dateString];
                            BOOL isRowEditable=NO;
                            if ([[dict objectForKey:@"entryType"] isEqualToString:Time_Entry_Key])
                            {
                                if ([dict objectForKey:@"endDateAllowedTime"]!=nil && ![[dict objectForKey:@"endDateAllowedTime"] isKindOfClass:[NSNull class]] && [dict objectForKey:@"startDateAllowedTime"]!=nil && ![[dict objectForKey:@"startDateAllowedTime"] isKindOfClass:[NSNull class]]) {
                                    NSDate *endDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"endDateAllowedTime"]];
                                    NSDate *startDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"startDateAllowedTime"]];
                                    isRowEditable=[Util date:todayDate isBetweenDate:startDateAllowed andDate:endDateAllowed];
                                }
                                else
                                {
                                    isRowEditable=YES;
                                }

                            }



                            NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                            NSString *comments=[dict objectForKey:@"comments"];
                            NSString *projectName=[dict objectForKey:@"projectName"];
                            NSString *projectUri=[dict objectForKey:@"projectUri"];
                            NSString *clientName=[dict objectForKey:@"clientName"];
                            NSString *clientUri=[dict objectForKey:@"clientUri"];
                            //MOBI-746
                            NSString *programName=[dict objectForKey:@"programName"];
                            NSString *programUri=[dict objectForKey:@"programUri"];
                            NSString *timeoffName=[dict objectForKey:@"timeOffTypeName"];
                            NSString *timeoffUri=[dict objectForKey:@"timeOffUri"];
                            NSString *durationDecimal=[dict objectForKey:@"durationDecimalFormat"];
                            NSString *billingName=[dict objectForKey:@"billingName"];
                            NSString *billingUri=[dict objectForKey:@"billingUri"];
                            NSString *activityName=[dict objectForKey:@"activityName"];
                            NSString *activityUri=[dict objectForKey:@"activityUri"];
                            NSString *taskName=[dict objectForKey:@"taskName"];
                            NSString *taskUri=[dict objectForKey:@"taskUri"];
                            NSString *entryType=[dict objectForKey:@"entryType"];
                            NSString *rowUri=[dict objectForKey:@"rowUri"];
                            NSString *rowNumber=[dict objectForKey:@"rowNumber"];

                            BOOL hasTimeEntryValue = NO;

                            if ([dict objectForKey:@"hasTimeEntryValue"]!=nil && [dict objectForKey:@"hasTimeEntryValue"]!=(id)[NSNull null]) {
                                hasTimeEntryValue = [[dict objectForKey:@"hasTimeEntryValue"] boolValue];
                            }

                            NSMutableArray *tempCustomFieldArray=nil;
                            NSMutableArray *tempRowCustomFieldArray=nil;//Implementation for US9371//JUHI
                            if (timeoffName!=nil && timeoffUri !=nil && ![timeoffUri isKindOfClass:[NSNull class]] &&![timeoffName isKindOfClass:[NSNull class]] && ![timeoffName isEqualToString:@""]&& ![timeoffUri isEqualToString:@""])
                            {
                                if ([entryType isEqualToString:Time_Off_Key])
                                {
                                    [tsEntryObject setEntryType:Time_Off_Key];
                                    tempCustomFieldArray=[self getUDFArrayForModuleName:TIMEOFF_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri isRowEditable:YES andTimeSheetUri:timesheetURI];
                                }


                                [tsEntryObject setIsTimeoffSickRowPresent:YES];
                                [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                                [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
                                [tsEntryObject setTimeEntryProjectName:@""];
                                [tsEntryObject setTimeEntryProjectUri:@""];
                                [tsEntryObject setTimeEntryClientName:nil];
                                [tsEntryObject setTimeEntryClientUri:nil];
                            }
                            else
                            {

                                [tsEntryObject setIsTimeoffSickRowPresent:NO];
                                [tsEntryObject setTimeEntryTimeOffName:@""];
                                [tsEntryObject setTimeEntryTimeOffUri:@""];
                                [tsEntryObject setTimeEntryProjectName:projectName];
                                [tsEntryObject setTimeEntryProjectUri:projectUri];
                                [tsEntryObject setTimeEntryClientName:clientName];
                                [tsEntryObject setTimeEntryClientUri:clientUri];
                                //MOBI-746
                                [tsEntryObject setTimeEntryProgramName:programName];
                                [tsEntryObject setTimeEntryProgramUri:programUri];


                            }


                            NSMutableArray *udfArray=[[NSMutableArray alloc]init];
                            for (int i=0; i<[tempCustomFieldArray count]; i++)
                            {
                                NSDictionary *udfDict = [tempCustomFieldArray objectAtIndex: i];
                                NSString *udfType=[udfDict objectForKey:@"type"];
                                NSString *udfName=[udfDict objectForKey:@"name"];
                                NSString *udfUri=[udfDict objectForKey:@"uri"];

                                if ([udfType isEqualToString:TEXT_UDF_TYPE])
                                {
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    if (isRowEditable==NO && [defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_TEXT];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [udfArray addObject:udfDetails];


                                }
                                else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
                                {
                                    NSString *defaultValue=nil;
                                    if ([entryType isEqualToString:Time_Off_Key])
                                    {
                                        NSString *tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                        if (tempDefaultValue!=nil && ![tempDefaultValue isKindOfClass:[NSNull class]]&& ![tempDefaultValue isEqualToString:@""]&&![tempDefaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                        {
                                            defaultValue=tempDefaultValue;
                                        }
                                        else
                                        {
                                            defaultValue=RPLocalizedString(NONE_STRING, @"");
                                        }

                                    }
                                    else
                                    {
                                        defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    }
                                    int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_NUMERIC];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDecimalPoints:defaultDecimalValue];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [udfArray addObject:udfDetails];


                                }
                                else if ([udfType isEqualToString:DATE_UDF_TYPE])
                                {
                                    NSString *defaultValue=nil;
                                    id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                    if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||(isRowEditable==NO &&[tempDefaultValue isKindOfClass:[NSString class]]&& [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
                                    else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                                        if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                            defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                        }
                                        else{
                                            if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                                defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                            }
                                            else{
                                                NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                                defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                                            }

                                        }
                                    }
                                    id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    if ([systemDefaultValue isKindOfClass:[NSDate class]])
                                    {
                                        systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                                    }
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DATE];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [udfArray addObject:udfDetails];

                                }
                                else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                                {
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DROPDOWN];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [udfArray addObject:udfDetails];

                                }




                            }//Implementation for US9371//JUHI
                            NSMutableArray *rowUdfArray=[[NSMutableArray alloc]init];
                            for (int i=0; i<[tempRowCustomFieldArray count]; i++)
                            {
                                NSDictionary *udfDict = [tempRowCustomFieldArray objectAtIndex: i];
                                NSString *udfType=[udfDict objectForKey:@"type"];
                                NSString *udfName=[udfDict objectForKey:@"name"];
                                NSString *udfUri=[udfDict objectForKey:@"uri"];

                                if ([udfType isEqualToString:TEXT_UDF_TYPE])
                                {
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    if (isRowEditable==NO && [defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_TEXT];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [rowUdfArray addObject:udfDetails];


                                }
                                else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
                                {
                                    NSString *defaultValue=nil;
                                    if ([entryType isEqualToString:Time_Off_Key])
                                    {
                                        NSString *tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                        if (tempDefaultValue!=nil && ![tempDefaultValue isKindOfClass:[NSNull class]]&& ![tempDefaultValue isEqualToString:@""]&&![tempDefaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                        {
                                            defaultValue=tempDefaultValue;
                                        }
                                        else
                                        {
                                            defaultValue=RPLocalizedString(NONE_STRING, @"");
                                        }

                                    }
                                    else
                                    {
                                        defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    }
                                    int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_NUMERIC];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDecimalPoints:defaultDecimalValue];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [rowUdfArray addObject:udfDetails];


                                }
                                else if ([udfType isEqualToString:DATE_UDF_TYPE])
                                {
                                    NSString *defaultValue=nil;
                                    id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                    if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||(isRowEditable==NO &&[tempDefaultValue isKindOfClass:[NSString class]]&& [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
                                    else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                                        if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                            defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                        }
                                        else{
                                            if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                                defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                            }
                                            else{
                                                NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                                defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                                            }

                                        }
                                    }
                                    id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    if ([systemDefaultValue isKindOfClass:[NSDate class]])
                                    {
                                        systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                                    }
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DATE];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [rowUdfArray addObject:udfDetails];

                                }
                                else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                                {
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DROPDOWN];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [rowUdfArray addObject:udfDetails];

                                }




                            }
                            [tsEntryObject setIsRowEditable:isRowEditable];
                            [tsEntryObject setTimeEntryComments:comments];
                            [tsEntryObject setTimeEntryUdfArray:udfArray];
                            [tsEntryObject setTimeEntryDate:todayDate];
                            [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                            [tsEntryObject setTimeAllocationUri:@""];
                            [tsEntryObject setTimePunchUri:@""];
                            [tsEntryObject setTimeEntryHoursInHourFormat:@""];
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:[Util getRoundedValueFromDecimalPlaces: [durationDecimal doubleValue ]withDecimalPlaces:2 ]];
                            [tsEntryObject setTimeEntryActivityName:activityName];
                            [tsEntryObject setTimeEntryActivityUri:activityUri];
                            [tsEntryObject setTimeEntryBillingName:billingName];
                            [tsEntryObject setTimeEntryBillingUri:billingUri];
                            [tsEntryObject setTimeEntryTaskName:taskName];
                            [tsEntryObject setTimeEntryTaskUri:taskUri];
                            [tsEntryObject setTimesheetUri:timesheetURI];
                            [tsEntryObject setRowUri:rowUri];
                            [tsEntryObject setTimeEntryCellOEFArray:[self constructCellOEFObjectForTimeSheetUri:timesheetURI andtimesheetFormat:timeSheetFormat andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:rowUri]];
                            [tsEntryObject setTimeEntryRowOEFArray:[self constructCellOEFObjectForTimeSheetUri:timesheetURI andtimesheetFormat:timeSheetFormat andOEFLevel:TIMESHEET_ROW_OEF andTimePunchUri:rowUri]];
                            [tsEntryObject setRownumber:rowNumber];
                            [tsEntryObject setTimeEntryRowUdfArray:rowUdfArray];//Implementation for US9371//JUHI
                            [tsEntryObject setHasTimeEntryValue:hasTimeEntryValue];
                            [temptimesheetEntryDataArray addObject:tsEntryObject];


                        }
                        else
                        {
                            //No entry available
                            TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];

                            NSDateFormatter *formatter=[[NSDateFormatter alloc] init];

                            NSLocale *locale=[NSLocale currentLocale];
                            [formatter setLocale:locale];
                            [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                            [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
                            NSDate *todayDate=[formatter dateFromString:dateString];
                            BOOL isRowEditable=NO;
                            if ([[dict objectForKey:@"entryType"] isEqualToString:Time_Entry_Key])
                            {
                                if ([dict objectForKey:@"endDateAllowedTime"]!=nil && ![[dict objectForKey:@"endDateAllowedTime"] isKindOfClass:[NSNull class]] && [dict objectForKey:@"startDateAllowedTime"]!=nil && ![[dict objectForKey:@"startDateAllowedTime"] isKindOfClass:[NSNull class]]) {
                                    NSDate *endDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"endDateAllowedTime"]];
                                    NSDate *startDateAllowed=[Util convertTimestampFromDBToDate:[dict objectForKey:@"startDateAllowedTime"]];
                                    isRowEditable=[Util date:todayDate isBetweenDate:startDateAllowed andDate:endDateAllowed];
                                }
                                else
                                {
                                    isRowEditable=YES;
                                }
                            }



                            NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                            NSString *projectName=[dict objectForKey:@"projectName"];
                            NSString *projectUri=[dict objectForKey:@"projectUri"];
                            NSString *clientName=[dict objectForKey:@"clientName"];
                            NSString *clientUri=[dict objectForKey:@"clientUri"];
                            //MOBI-746
                            NSString *programName=[dict objectForKey:@"programName"];
                            NSString *programUri=[dict objectForKey:@"programUri"];
                            NSString *timeoffName=[dict objectForKey:@"timeOffTypeName"];
                            NSString *timeoffUri=[dict objectForKey:@"timeOffUri"];
                            NSString *billingName=[dict objectForKey:@"billingName"];
                            NSString *billingUri=[dict objectForKey:@"billingUri"];
                            NSString *activityName=[dict objectForKey:@"activityName"];
                            NSString *activityUri=[dict objectForKey:@"activityUri"];
                            NSString *taskName=[dict objectForKey:@"taskName"];
                            NSString *taskUri=[dict objectForKey:@"taskUri"];
                            NSString *entryType=[dict objectForKey:@"entryType"];

                            NSString *rowUri=nil;

                            NSString *rowNumber=[dict objectForKey:@"rowNumber"];

                            BOOL hasTimeEntryValue = NO;

                            if ([dict objectForKey:@"hasTimeEntryValue"]!=nil && [dict objectForKey:@"hasTimeEntryValue"]!=(id)[NSNull null]) {
                                hasTimeEntryValue = [[dict objectForKey:@"hasTimeEntryValue"] boolValue];
                            }

                            NSMutableArray *tempCustomFieldArray=nil;
                            NSMutableArray *tempRowCustomFieldArray=nil;//Implementation for US9371//JUHI
                            if (timeoffName!=nil && timeoffUri !=nil && ![timeoffUri isKindOfClass:[NSNull class]] &&![timeoffName isKindOfClass:[NSNull class]] && ![timeoffName isEqualToString:@""]&& ![timeoffUri isEqualToString:@""])
                            {
                                if ([entryType isEqualToString:Time_Off_Key])
                                {
                                    [tsEntryObject setEntryType:Time_Off_Key];
                                    tempCustomFieldArray=[self getUDFArrayForModuleName:TIMEOFF_UDF andEntryDate:[todayDate dateByAddingDays:100] andEntryType:entryType andRowUri:rowUri isRowEditable:YES andTimeSheetUri:timesheetURI];//passing hacked date since entry is empty and created forcefully
                                }


                                [tsEntryObject setIsTimeoffSickRowPresent:YES];
                                [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                                [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
                                [tsEntryObject setTimeEntryProjectName:@""];
                                [tsEntryObject setTimeEntryProjectUri:@""];
                                [tsEntryObject setTimeEntryClientName:nil];
                                [tsEntryObject setTimeEntryClientUri:nil];
                                //MOBI-746
                                [tsEntryObject setTimeEntryProgramName:nil];
                                [tsEntryObject setTimeEntryProgramUri:nil];
                            }
                            else
                            {

                                [tsEntryObject setIsTimeoffSickRowPresent:NO];
                                [tsEntryObject setTimeEntryTimeOffName:@""];
                                [tsEntryObject setTimeEntryTimeOffUri:@""];
                                [tsEntryObject setTimeEntryProjectName:projectName];
                                [tsEntryObject setTimeEntryProjectUri:projectUri];
                                [tsEntryObject setTimeEntryClientName:clientName];
                                [tsEntryObject setTimeEntryClientUri:clientUri];
                                //MOBI-746
                                [tsEntryObject setTimeEntryProgramName:programName];
                                [tsEntryObject setTimeEntryProgramUri:programUri];
                            }
                            NSMutableArray *udfArray=[[NSMutableArray alloc]init];
                            for (int i=0; i<[tempCustomFieldArray count]; i++)
                            {
                                NSDictionary *udfDict = [tempCustomFieldArray objectAtIndex: i];
                                NSString *udfType=[udfDict objectForKey:@"type"];
                                NSString *udfName=[udfDict objectForKey:@"name"];
                                NSString *udfUri=[udfDict objectForKey:@"uri"];

                                if ([udfType isEqualToString:TEXT_UDF_TYPE])
                                {
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    if (isRowEditable==NO && [defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_TEXT];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [udfArray addObject:udfDetails];


                                }
                                else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
                                {
                                    NSString *defaultValue=nil;
                                    if ([entryType isEqualToString:Time_Off_Key])
                                    {
                                        NSString *tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                        if (tempDefaultValue!=nil && ![tempDefaultValue isKindOfClass:[NSNull class]]&& ![tempDefaultValue isEqualToString:@""]&&![tempDefaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                        {
                                            defaultValue=tempDefaultValue;
                                        }
                                        else
                                        {
                                            defaultValue=RPLocalizedString(NONE_STRING, @"");
                                        }

                                    }
                                    else
                                    {
                                        defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    }
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_NUMERIC];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDecimalPoints:defaultDecimalValue];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [udfArray addObject:udfDetails];


                                }
                                else if ([udfType isEqualToString:DATE_UDF_TYPE])
                                {
                                    NSString *defaultValue=nil;
                                    id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                    if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||(isRowEditable==NO && [tempDefaultValue isKindOfClass:[NSString class]] &&[tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
                                    else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                                        if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                            defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                        }
                                        else{
                                            NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                            defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                                        }

                                    }
                                    id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    if ([systemDefaultValue isKindOfClass:[NSDate class]])
                                    {
                                        systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                                    }
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DATE];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [udfArray addObject:udfDetails];

                                }
                                else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                                {
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DROPDOWN];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [udfArray addObject:udfDetails];

                                }

                            }
                            //Implementation for US9371//JUHI
                            NSMutableArray *rowUdfArray=[[NSMutableArray alloc]init];
                            for (int i=0; i<[tempRowCustomFieldArray count]; i++)
                            {
                                NSDictionary *udfDict = [tempRowCustomFieldArray objectAtIndex: i];
                                NSString *udfType=[udfDict objectForKey:@"type"];
                                NSString *udfName=[udfDict objectForKey:@"name"];
                                NSString *udfUri=[udfDict objectForKey:@"uri"];

                                if ([udfType isEqualToString:TEXT_UDF_TYPE])
                                {
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    if (isRowEditable==NO && [defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_TEXT];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [rowUdfArray addObject:udfDetails];


                                }
                                else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
                                {
                                    NSString *defaultValue=nil;
                                    if ([entryType isEqualToString:Time_Off_Key])
                                    {
                                        NSString *tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                        if (tempDefaultValue!=nil && ![tempDefaultValue isKindOfClass:[NSNull class]]&& ![tempDefaultValue isEqualToString:@""]&&![tempDefaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                        {
                                            defaultValue=tempDefaultValue;
                                        }
                                        else
                                        {
                                            defaultValue=RPLocalizedString(NONE_STRING, @"");
                                        }

                                    }
                                    else
                                    {
                                        defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    }
                                    int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_NUMERIC];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDecimalPoints:defaultDecimalValue];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [rowUdfArray addObject:udfDetails];


                                }
                                else if ([udfType isEqualToString:DATE_UDF_TYPE])
                                {
                                    NSString *defaultValue=nil;
                                    id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                    if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||(isRowEditable==NO &&[tempDefaultValue isKindOfClass:[NSString class]]&& [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }
                                    else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                                        if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                            defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                        }
                                        else{
                                            if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                                defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                            }
                                            else{
                                                NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                                defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                                            }

                                        }
                                    }
                                    id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    if ([systemDefaultValue isKindOfClass:[NSDate class]])
                                    {
                                        systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                                    }
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DATE];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [rowUdfArray addObject:udfDetails];

                                }
                                else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                                {
                                    NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                    NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                    NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                    EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                    [udfDetails setFieldName:udfName];
                                    [udfDetails setFieldType:UDFType_DROPDOWN];
                                    [udfDetails setFieldValue:defaultValue];
                                    [udfDetails setUdfIdentity:udfUri];
                                    [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                    [udfDetails setSystemDefaultValue:systemDefaultValue];
                                    [rowUdfArray addObject:udfDetails];

                                }




                            }
                            [tsEntryObject setIsRowEditable:isRowEditable];
                            [tsEntryObject setTimeEntryDate:todayDate];
                            [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                            [tsEntryObject setTimeAllocationUri:@""];
                            [tsEntryObject setTimePunchUri:@""];
                            [tsEntryObject setTimeEntryHoursInHourFormat:@""];
                            [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                            [tsEntryObject setTimeEntryActivityName:activityName];
                            [tsEntryObject setTimeEntryActivityUri:activityUri];
                            [tsEntryObject setTimeEntryBillingName:billingName];
                            [tsEntryObject setTimeEntryBillingUri:billingUri];
                            [tsEntryObject setTimeEntryTaskName:taskName];
                            [tsEntryObject setTimeEntryTaskUri:taskUri];
                            [tsEntryObject setTimeEntryComments:@""];
                            [tsEntryObject setTimeEntryUdfArray:udfArray];
                            [tsEntryObject setTimesheetUri:timesheetURI];
                            [tsEntryObject setRowUri:rowUri];
                            [tsEntryObject setTimeEntryCellOEFArray:[self constructCellOEFObjectForTimeSheetUri:timesheetURI andtimesheetFormat:timeSheetFormat andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:rowUri]];
                            [tsEntryObject setTimeEntryRowOEFArray:[self constructCellOEFObjectForTimeSheetUri:timesheetURI andtimesheetFormat:timeSheetFormat andOEFLevel:TIMESHEET_ROW_OEF andTimePunchUri:rowUri]];
                            [tsEntryObject setTimeEntryRowUdfArray:rowUdfArray];//Implementation for US9371//JUHI
                            [tsEntryObject setRownumber:rowNumber];
                            [tsEntryObject setHasTimeEntryValue:hasTimeEntryValue];
                            [temptimesheetEntryDataArray addObject:tsEntryObject];

                        }



                    }
                    [timesheetDataArray addObject:temptimesheetEntryDataArray];


                }
                else
                {
                    //No Entry Available on this date.insert Blank entries
                    NSMutableArray *timesheetArray=nil;
                    //Approval context Flow for Timesheets

                    timesheetArray=[self.timesheetModel getAllDistinctStandardTimeEntriesInfoFromDBForTimesheetUri:timesheetURI];

                    for (int i=0; i<[timesheetArray count]; i++)
                    {
                        TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];

                        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];

                        NSLocale *locale=[NSLocale currentLocale];
                        [formatter setLocale:locale];
                        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                        [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
                        NSDate *todayDate=[formatter dateFromString:dateString];
                        BOOL isRowEditable=NO;
                        if ([[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"entryType"] isEqualToString:Time_Entry_Key])
                        {

                            if ([[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"endDateAllowedTime"]!=nil && ![[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"endDateAllowedTime"] isKindOfClass:[NSNull class]] && [[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"startDateAllowedTime"]!=nil && ![[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"startDateAllowedTime"] isKindOfClass:[NSNull class]]) {
                                NSDate *endDateAllowed=[Util convertTimestampFromDBToDate:[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"endDateAllowedTime"]];
                                NSDate *startDateAllowed=[Util convertTimestampFromDBToDate:[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"startDateAllowedTime"]];
                                isRowEditable=[Util date:todayDate isBetweenDate:startDateAllowed andDate:endDateAllowed];
                            }
                            else
                            {
                                isRowEditable=YES;
                            }


                        }



                        NSMutableDictionary *multiDayInOutDict=[NSMutableDictionary dictionary];
                        NSString *projectName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"projectName"];
                        NSString *projectUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"projectUri"];
                        NSString *clientName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"clientName"];
                        NSString *clientUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"clientUri"];
                        //MOBI-746
                        NSString *programName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"programName"];
                        NSString *programUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"programUri"];
                        NSString *timeoffName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"timeOffTypeName"];
                        NSString *timeoffUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"timeOffUri"];
                        NSString *entryType=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"entryType"];
                        NSString *billingName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"billingName"];
                        NSString *billingUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"billingUri"];
                        NSString *activityName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"activityName"];
                        NSString *activityUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"activityUri"];
                        NSString *taskName=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"taskName"];
                        NSString *taskUri=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"taskUri"];
                        NSString *rowUri=nil;



                        NSString *rowNumber=[[[timesheetArray objectAtIndex:i] objectAtIndex:0]objectForKey:@"rowNumber"];

                        BOOL hasTimeEntryValue = NO;

                        if ([[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"hasTimeEntryValue"]!=nil && [[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"hasTimeEntryValue"]!=(id)[NSNull null]) {
                            hasTimeEntryValue = [[[[timesheetArray objectAtIndex:i] objectAtIndex:0] objectForKey:@"hasTimeEntryValue"] boolValue];
                        }

                        NSMutableArray *tempCustomFieldArray=nil;
                        NSMutableArray *tempRowCustomFieldArray=nil;//Implementation for US9371//JUHI
                        if ([entryType isEqualToString:Time_Entry_Key])
                        {

                            [tsEntryObject setIsTimeoffSickRowPresent:NO];
                            [tsEntryObject setTimeEntryTimeOffName:@""];
                            [tsEntryObject setTimeEntryTimeOffUri:@""];
                            [tsEntryObject setTimeEntryProjectName:projectName];
                            [tsEntryObject setTimeEntryProjectUri:projectUri];
                            [tsEntryObject setTimeEntryClientName:clientName];
                            [tsEntryObject setTimeEntryClientUri:clientUri];
                            //MOBI-746
                            [tsEntryObject setTimeEntryProgramName:programName];
                            [tsEntryObject setTimeEntryProgramUri:programUri];
                        }
                        else
                        {
                            if ([entryType isEqualToString:Time_Off_Key])
                            {
                                [tsEntryObject setEntryType:Time_Off_Key];
                                tempCustomFieldArray=[self getUDFArrayForModuleName:TIMEOFF_UDF andEntryDate:todayDate andEntryType:entryType andRowUri:rowUri isRowEditable:YES andTimeSheetUri:timesheetURI];
                            }


                            [tsEntryObject setIsTimeoffSickRowPresent:YES];
                            [tsEntryObject setTimeEntryTimeOffName:timeoffName];
                            [tsEntryObject setTimeEntryTimeOffUri:timeoffUri];
                            [tsEntryObject setTimeEntryProjectName:@""];
                            [tsEntryObject setTimeEntryProjectUri:@""];
                            [tsEntryObject setTimeEntryClientName:nil];
                            [tsEntryObject setTimeEntryClientUri:nil];
                            //MOBI-746
                            [tsEntryObject setTimeEntryProgramName:nil];
                            [tsEntryObject setTimeEntryProgramUri:nil];
                        }

                        NSMutableArray *udfArray=[[NSMutableArray alloc]init];
                        for (int i=0; i<[tempCustomFieldArray count]; i++)
                        {
                            NSDictionary *udfDict = [tempCustomFieldArray objectAtIndex: i];
                            NSString *udfType=[udfDict objectForKey:@"type"];
                            NSString *udfName=[udfDict objectForKey:@"name"];
                            NSString *udfUri=[udfDict objectForKey:@"uri"];

                            if ([udfType isEqualToString:TEXT_UDF_TYPE])
                            {
                                NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                if (isRowEditable==NO && [defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                {
                                    defaultValue=RPLocalizedString(NONE_STRING, @"");
                                }
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_TEXT];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfArray addObject:udfDetails];


                            }
                            else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
                            {
                                NSString *defaultValue=nil;
                                if ([entryType isEqualToString:Time_Off_Key])
                                {
                                    NSString *tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                    if (tempDefaultValue!=nil && ![tempDefaultValue isKindOfClass:[NSNull class]]&& ![tempDefaultValue isEqualToString:@""]&&![tempDefaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                    {
                                        defaultValue=tempDefaultValue;
                                    }
                                    else
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }

                                }
                                else
                                {
                                    defaultValue=[udfDict objectForKey:@"defaultValue"];
                                }
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_NUMERIC];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setDecimalPoints:defaultDecimalValue];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfArray addObject:udfDetails];


                            }
                            else if ([udfType isEqualToString:DATE_UDF_TYPE])
                            {
                                NSString *defaultValue=nil;
                                id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||(isRowEditable==NO && [tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                                {
                                    defaultValue=RPLocalizedString(NONE_STRING, @"");
                                }
                                else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                                    if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                        defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                    }
                                    else{
                                        NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                        defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                                    }

                                }
                                id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                if ([systemDefaultValue isKindOfClass:[NSDate class]])
                                {
                                    systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                                }
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_DATE];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfArray addObject:udfDetails];

                            }
                            else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                            {
                                NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_DROPDOWN];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [udfArray addObject:udfDetails];

                            }




                        }

                        //Implementation for US9371//JUHI
                        NSMutableArray *rowUdfArray=[[NSMutableArray alloc]init];
                        for (int i=0; i<[tempRowCustomFieldArray count]; i++)
                        {
                            NSDictionary *udfDict = [tempRowCustomFieldArray objectAtIndex: i];
                            NSString *udfType=[udfDict objectForKey:@"type"];
                            NSString *udfName=[udfDict objectForKey:@"name"];
                            NSString *udfUri=[udfDict objectForKey:@"uri"];

                            if ([udfType isEqualToString:TEXT_UDF_TYPE])
                            {
                                NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                if (isRowEditable==NO && [defaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                {
                                    defaultValue=RPLocalizedString(NONE_STRING, @"");
                                }
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_TEXT];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [rowUdfArray addObject:udfDetails];


                            }
                            else if([udfType isEqualToString:NUMERIC_UDF_TYPE])
                            {
                                NSString *defaultValue=nil;
                                if ([entryType isEqualToString:Time_Off_Key])
                                {
                                    NSString *tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                    if (tempDefaultValue!=nil && ![tempDefaultValue isKindOfClass:[NSNull class]]&& ![tempDefaultValue isEqualToString:@""]&&![tempDefaultValue isEqualToString:RPLocalizedString(ADD_STRING, @"")])
                                    {
                                        defaultValue=tempDefaultValue;
                                    }
                                    else
                                    {
                                        defaultValue=RPLocalizedString(NONE_STRING, @"");
                                    }

                                }
                                else
                                {
                                    defaultValue=[udfDict objectForKey:@"defaultValue"];
                                }
                                int defaultDecimalValue=[[udfDict objectForKey:@"defaultDecimalValue"] intValue];
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_NUMERIC];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setDecimalPoints:defaultDecimalValue];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [rowUdfArray addObject:udfDetails];


                            }
                            else if ([udfType isEqualToString:DATE_UDF_TYPE])
                            {
                                NSString *defaultValue=nil;
                                id tempDefaultValue=[udfDict objectForKey:@"defaultValue"];
                                if (([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")])||(isRowEditable==NO &&[tempDefaultValue isKindOfClass:[NSString class]]&& [tempDefaultValue isEqualToString:RPLocalizedString(NONE_STRING, @"")]))
                                {
                                    defaultValue=RPLocalizedString(NONE_STRING, @"");
                                }
                                else{//Implemented for US8763_HandleWhenDateUDFDoesNotHaveDefaultValue//JUHI
                                    if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                        defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                    }
                                    else{
                                        if ([tempDefaultValue isKindOfClass:[NSString class]] && [tempDefaultValue isEqualToString:RPLocalizedString(SELECT_STRING, @"")]) {
                                            defaultValue=RPLocalizedString(SELECT_STRING, @"");
                                        }
                                        else{
                                            NSDate *date=(NSDate *)[udfDict objectForKey:@"defaultValue"];
                                            defaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:date]];
                                        }

                                    }
                                }
                                id systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                if ([systemDefaultValue isKindOfClass:[NSDate class]])
                                {
                                    systemDefaultValue=[NSString stringWithFormat:@"%@",[Util convertPickerDateToStringShortStyle:systemDefaultValue]];
                                }
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_DATE];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [rowUdfArray addObject:udfDetails];

                            }
                            else if([udfType isEqualToString:DROPDOWN_UDF_TYPE])
                            {
                                NSString *defaultValue=[udfDict objectForKey:@"defaultValue"];
                                NSString *systemDefaultValue=[udfDict objectForKey:@"systemDefaultValue"];
                                NSString *dropDownOptionUri=[udfDict objectForKey:@"dropDownOptionUri"];
                                EntryCellDetails *udfDetails=[[EntryCellDetails alloc]initWithDefaultValue:defaultValue ];
                                [udfDetails setFieldName:udfName];
                                [udfDetails setFieldType:UDFType_DROPDOWN];
                                [udfDetails setFieldValue:defaultValue];
                                [udfDetails setUdfIdentity:udfUri];
                                [udfDetails setDropdownOptionUri:dropDownOptionUri];
                                [udfDetails setSystemDefaultValue:systemDefaultValue];
                                [rowUdfArray addObject:udfDetails];

                            }




                        }



                        [tsEntryObject setIsRowEditable:isRowEditable];
                        [tsEntryObject setTimeEntryDate:todayDate];
                        [tsEntryObject setMultiDayInOutEntry:multiDayInOutDict];
                        [tsEntryObject setTimeAllocationUri:@""];
                        [tsEntryObject setTimePunchUri:@""];
                        [tsEntryObject setTimeEntryHoursInHourFormat:@""];
                        [tsEntryObject setTimeEntryHoursInDecimalFormat:[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]]];
                        [tsEntryObject setTimeEntryActivityName:activityName];
                        [tsEntryObject setTimeEntryActivityUri:activityUri];
                        [tsEntryObject setTimeEntryBillingName:billingName];
                        [tsEntryObject setTimeEntryBillingUri:billingUri];
                        [tsEntryObject setTimeEntryTaskName:taskName];
                        [tsEntryObject setTimeEntryTaskUri:taskUri];
                        [tsEntryObject setTimeEntryComments:@""];
                        [tsEntryObject setTimeEntryUdfArray:udfArray];
                        [tsEntryObject setTimesheetUri:timesheetURI];
                        [tsEntryObject setRowUri:rowUri];
                        [tsEntryObject setTimeEntryCellOEFArray:[self constructCellOEFObjectForTimeSheetUri:timesheetURI andtimesheetFormat:timeSheetFormat andOEFLevel:TIMESHEET_CELL_OEF andTimePunchUri:rowUri]];
                        [tsEntryObject setTimeEntryRowOEFArray:[self constructCellOEFObjectForTimeSheetUri:timesheetURI andtimesheetFormat:timeSheetFormat andOEFLevel:TIMESHEET_ROW_OEF andTimePunchUri:rowUri]];
                        [tsEntryObject setTimeEntryRowUdfArray:rowUdfArray];//Implementation for US9371//JUHI
                        [tsEntryObject setRownumber:rowNumber];
                        [tsEntryObject setHasTimeEntryValue:hasTimeEntryValue];
                        [temptimesheetEntryDataArray addObject:tsEntryObject];


                    }
                    [timesheetDataArray addObject:temptimesheetEntryDataArray];


                }


            }

        }


    }
    if ([timeSheetFormat isEqualToString:GEN4_DAILY_WIDGET_TIMESHEET])
    {

        NSMutableArray *availableEntryDatesArray=[NSMutableArray array];
        NSMutableArray *availableEntriesDictArray=[NSMutableArray array];
        NSMutableArray *tsEntryDataArray=[self createCurrentTimesheetEntryList:timesheetURI forTimeSheetFormat:timeSheetFormat];
        NSMutableArray *dbTimeEntriesArray=[NSMutableArray arrayWithArray:[self.timesheetModel getTimeEntriesForExtendedInOutSheetFromDB:timesheetURI andTimeSheetFormat:GEN4_DAILY_WIDGET_TIMESHEET]];
        for (int i=0; i<[dbTimeEntriesArray count]; i++)
        {

            NSMutableArray *arrayOfEntries=[dbTimeEntriesArray objectAtIndex:i];

            for (int k=0; k<[arrayOfEntries count]; k++)
            {

                NSMutableDictionary *entryDict=[arrayOfEntries objectAtIndex:k];
                NSDate *tmpDate = [Util convertTimestampFromDBToDate:[[entryDict objectForKey:@"timesheetEntryDate"] stringValue]];
                NSCalendar *gregorian=[NSCalendar currentCalendar];
                [gregorian setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                NSUInteger flags = ( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay );
                NSDate * date = [gregorian dateFromComponents:[gregorian components:flags fromDate:tmpDate]];
                if (![availableEntryDatesArray containsObject:date])
                {

                    [availableEntryDatesArray addObject:date];
                    [availableEntriesDictArray addObject:arrayOfEntries];
                }
            }

        }

        if (dbTimeEntriesArray.count>0)
        {
            for (int j=0; j<[tsEntryDataArray count]; j++)
            {

                NSMutableArray *temptimesheetEntryDataArray=[[NSMutableArray alloc]init];
                NSString *dateString = [[tsEntryDataArray objectAtIndex:j] entryDate];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

                NSLocale *locale=[NSLocale currentLocale];
                [dateFormatter setLocale:locale];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                [dateFormatter setDateFormat:@"EEEE, dd MMM yyyy"];
                NSDate *date = [dateFormatter dateFromString:dateString];

                if ([availableEntryDatesArray containsObject:date ])
                {
                    NSUInteger index=[availableEntryDatesArray indexOfObject:date];
                    NSMutableArray *arrayOfEntries=[availableEntriesDictArray objectAtIndex:index];
                    // Entry Available on this date
                    temptimesheetEntryDataArray=[self createDayLevelDailyWidgetOEFArrayForDate:dateString andTimeEntries:arrayOfEntries andTimesheetUri:timesheetURI];
                    [timesheetDataArray addObject:temptimesheetEntryDataArray];


                }
                else
                {
                    //No Entry Available on this date.insert Blank entries

                    temptimesheetEntryDataArray=[self createDayLevelDailyWidgetOEFArrayForDate:dateString andTimeEntries:nil andTimesheetUri:timesheetURI];

                    [timesheetDataArray addObject:temptimesheetEntryDataArray];
                    
                    
                }
                
                
            }
            
        }
        
        
    }



    return timesheetDataArray;


}


-(NSMutableArray *)createCurrentTimesheetEntryList:(NSString *)timesheetURI forTimeSheetFormat:(NSString *)timeSheetFormat
{


    NSMutableArray *currentTimesheetArray=[NSMutableArray array];

    NSMutableArray *arrayFromDB=[self.timesheetModel getAllTimesheetDaySummaryFromDBForTimesheet:timesheetURI];

    for (int i=0; i<[arrayFromDB count]; i++)

    {
        NSDictionary *dataDic=[arrayFromDB objectAtIndex:i];
        TimesheetObject *timeobj=[[TimesheetObject alloc]init];
        NSDate *nowDateFromLong = [Util convertTimestampFromDBToDate:[[dataDic objectForKey:@"timesheetEntryDate"] stringValue]];
        NSDateFormatter *myDateFormatter = [[NSDateFormatter alloc] init];

        NSLocale *locale=[NSLocale currentLocale];
        [myDateFormatter setLocale:locale];
        [myDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        myDateFormatter.dateFormat = @"EEEE, dd MMM yyyy";
        [timeobj setEntryDate:[myDateFormatter stringFromDate:nowDateFromLong]];
        myDateFormatter.dateFormat = @"EEE, MMM dd";
        [timeobj setEntryDateWithDesiredFormat:[myDateFormatter stringFromDate:nowDateFromLong]];


        if ([timeSheetFormat isEqualToString:GEN4_PUNCH_WIDGET_TIMESHEET])
        {
            id totalPunchTimeDurationDecimal = [dataDic objectForKey:@"totalPunchTimeDurationDecimal"];
            if (totalPunchTimeDurationDecimal != nil && ![totalPunchTimeDurationDecimal isKindOfClass:[NSNull class]]) {
                [timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:[[dataDic objectForKey:@"totalPunchTimeDurationDecimal"]newDoubleValue]withDecimalPlaces:2]];
            }
        }
        else if ([timeSheetFormat isEqualToString:GEN4_INOUT_TIMESHEET] || [timeSheetFormat isEqualToString:GEN4_EXT_INOUT_TIMESHEET])
        {
            id totalPunchTimeDurationDecimal = [dataDic objectForKey:@"totalInOutTimeDurationDecimal"];
            if (totalPunchTimeDurationDecimal != nil && ![totalPunchTimeDurationDecimal isKindOfClass:[NSNull class]]) {
                [timeobj setNumberOfHours:[Util getRoundedValueFromDecimalPlaces:[[dataDic objectForKey:@"totalInOutTimeDurationDecimal"]newDoubleValue]withDecimalPlaces:2]];
            }
        }


        [timeobj setHasComments:[[dataDic objectForKey:@"hasComments"] boolValue]];
        [timeobj setIsHolidayDayOff:[[dataDic objectForKey:@"isHolidayDayOff"] boolValue]];
        [timeobj setIsWeeklyDayOff:[[dataDic objectForKey:@"isWeeklyDayOff"] boolValue]];
        if ([[dataDic objectForKey:@"timeOffDurationDecimal"] intValue]!=0)
        {
            [timeobj setHasTimeOff:TRUE];

        }
        else
        {
            [timeobj setHasTimeOff:FALSE];

        }
        [currentTimesheetArray addObject:timeobj];


    }
    return currentTimesheetArray;





}


-(NSMutableArray *)getUDFArrayForModuleName:(NSString *)moduleName andEntryDate:(NSDate *)entryDate andEntryType:(NSString *)entryType andRowUri:(NSString *)rowUri isRowEditable:(BOOL)isRowEditable andTimeSheetUri:(NSString*)timesheetUri
{
    NSMutableArray *customFieldArray=[NSMutableArray array];
    LoginModel *loginModel=[[LoginModel alloc]init];
    NSMutableArray *udfArray=[loginModel getEnabledOnlyUDFsforModuleName:moduleName];

    int decimalPlace=0;
    for (int i=0; i<[udfArray count]; i++)
    {
        NSDictionary *udfDict = [udfArray objectAtIndex: i];
        NSMutableDictionary *dictInfo = [NSMutableDictionary dictionary];
        [dictInfo setObject:[udfDict objectForKey:@"name"] forKey:@"fieldName"];
        [dictInfo setObject:[udfDict objectForKey:@"uri"] forKey:@"identity"];

        if ([[udfDict objectForKey:@"udfType"] isEqualToString: NUMERIC_UDF_TYPE])
        {
            [dictInfo setObject:NUMERIC_UDF_TYPE forKey:@"fieldType"];

            [dictInfo setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];


            if ([udfDict objectForKey:@"numericDecimalPlaces"]!=nil && !([[udfDict objectForKey:@"numericDecimalPlaces"] isKindOfClass:[NSNull class]])){
                decimalPlace=[[udfDict objectForKey:@"numericDecimalPlaces"] intValue];
                [dictInfo setObject:[udfDict objectForKey:@"numericDecimalPlaces"] forKey:@"defaultDecimalValue"];
            }
            if ([udfDict objectForKey:@"numericMinValue"]!=nil && !([[udfDict objectForKey:@"numericMinValue"] isKindOfClass:[NSNull class]])) {
                [dictInfo setObject:[udfDict objectForKey:@"numericMinValue"] forKey:@"defaultMinValue"];
            }
            if ([udfDict objectForKey:@"numericMaxValue"]!=nil && !([[udfDict objectForKey:@"numericMaxValue"] isKindOfClass:[NSNull class]])) {
                [dictInfo setObject:[udfDict objectForKey:@"numericMaxValue"] forKey:@"defaultMaxValue"];
            }

            if ([udfDict objectForKey:@"numericDefaultValue"]!=nil && !([[udfDict objectForKey:@"numericDefaultValue"] isKindOfClass:[NSNull class]])&&![[udfDict objectForKey:@"numericDefaultValue"] isEqualToString:@""])
            {
                [dictInfo setObject:[Util getRoundedValueFromDecimalPlaces:[[udfDict objectForKey:@"numericDefaultValue"] newDoubleValue] withDecimalPlaces:decimalPlace] forKey:@"defaultValue"];
                [dictInfo setObject:[Util getRoundedValueFromDecimalPlaces:[[udfDict objectForKey:@"numericDefaultValue"] newDoubleValue] withDecimalPlaces:decimalPlace] forKey:@"systemDefaultValue"];
            }
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:TEXT_UDF_TYPE])
        {
            [dictInfo setObject:TEXT_UDF_TYPE forKey:@"fieldType"];
            [dictInfo setObject:RPLocalizedString(ADD, @"") forKey:@"defaultValue"];


            if ([udfDict objectForKey:@"textDefaultValue"]!=nil && ![[udfDict objectForKey:@"textDefaultValue"]isKindOfClass:[NSNull class]]){
                if (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@""]&& (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@"null"])) {
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"systemDefaultValue"];
                }
            }

            if ([udfDict objectForKey:@"textMaxValue"]!=nil && !([[udfDict objectForKey:@"textMaxValue"] isKindOfClass:[NSNull class]]))
                [dictInfo setObject:[udfDict objectForKey:@"textMaxValue"] forKey:@"defaultMaxValue"];
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:DATE_UDF_TYPE])
        {
            [dictInfo setObject: DATE_UDF_TYPE forKey: @"fieldType"];

            [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];


            if ([udfDict objectForKey:@"dateMaxValue"]!=nil && !([[udfDict objectForKey:@"dateMaxValue"] isKindOfClass:[NSNull class]]))
            {
                [dictInfo setObject:[udfDict objectForKey:@"dateMaxValue"] forKey:@"defaultMaxValue"];
            }
            if ([udfDict objectForKey:@"dateMinValue"]!=nil && !([[udfDict objectForKey:@"dateMinValue"] isKindOfClass:[NSNull class]]))
            {
                [dictInfo setObject:[udfDict objectForKey:@"dateMinValue"] forKey:@"defaultMinValue"];
            }

            if ([udfDict objectForKey:@"isDateDefaultValueToday"]!=nil && !([[udfDict objectForKey:@"isDateDefaultValueToday"] isKindOfClass:[NSNull class]]))
            {
                if ([[udfDict objectForKey:@"isDateDefaultValueToday"]intValue]==1)
                {
                    [dictInfo setObject:[NSDate date] forKey:@"defaultValue"];
                    [dictInfo setObject:[NSDate date] forKey:@"systemDefaultValue"];

                }else
                {
                    if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                    {
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"defaultValue"];
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"systemDefaultValue"];

                    }
                    else
                    {
                        [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];

                    }
                }
            }
            else {
                if ([udfDict objectForKey:@"dateDefaultValue"]!=nil && !([[udfDict objectForKey:@"dateDefaultValue"] isKindOfClass:[NSNull class]]))
                {
                    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

                    NSLocale *locale=[NSLocale currentLocale];
                    [dateFormat setLocale:locale];
                    [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                    [dateFormat setDateFormat:@"MMMM dd, yyyy"];

                    NSDate *dateToBeUsed = [Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]];
                    NSString *dateStr = [dateFormat stringFromDate:dateToBeUsed];
                    dateToBeUsed=[dateFormat dateFromString:dateStr];

                    if (dateToBeUsed==nil) {
                        [dateFormat setDateFormat:@"d MMMM yyyy"];
                        dateToBeUsed = [dateFormat dateFromString:dateStr];

                    }


                    NSString *dateDefaultValueFormatted = [Util convertPickerDateToString:dateToBeUsed];

                    if(dateDefaultValueFormatted != nil)
                    {
                        [dictInfo setObject:dateToBeUsed forKey:@"defaultValue"];
                        [dictInfo setObject:dateToBeUsed forKey:@"systemDefaultValue"];

                    }
                    else
                    {
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"defaultValue"];
                        [dictInfo setObject:[Util convertTimestampFromDBToDate:[[udfDict objectForKey:@"dateDefaultValue"] stringValue]] forKey:@"systemDefaultValue"];
                    }
                }
                else
                {
                    [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];

                }
            }
        }
        else if ([[udfDict objectForKey:@"udfType"] isEqualToString:DROPDOWN_UDF_TYPE])
        {
            [dictInfo setObject:DROPDOWN_UDF_TYPE forKey:@"fieldType"];
            [dictInfo setObject:RPLocalizedString(SELECT_STRING, @"") forKey:@"defaultValue"];

            if ([udfDict objectForKey:@"textDefaultValue"]!=nil &&![[udfDict objectForKey:@"textDefaultValue"]isKindOfClass:[NSNull class]])
            {
                if (![[udfDict objectForKey:@"textDefaultValue"] isEqualToString:@""])
                {
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"defaultValue"];
                    [dictInfo setObject:[udfDict objectForKey:@"dropDownOptionDefaultURI"] forKey:@"dropDownOptionUri"];
                    [dictInfo setObject:[udfDict objectForKey:@"textDefaultValue"] forKey:@"systemDefaultValue"];

                }
            }
        }
        NSString *entryDateTimestamp=[NSString stringWithFormat:@"%f",[Util convertDateToTimestamp:entryDate]];
        NSArray *selectedudfArray=nil;

        //Implementation for US9371//JUHI
        if ([moduleName isEqualToString:TIMESHEET_ROW_UDF])
        {
            selectedudfArray=[self.timesheetModel getTimesheetSheetCustomFieldsForSheetURI:timesheetUri moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"]andRowUri:rowUri];
        }
        else
            selectedudfArray=[self.timesheetModel getTimesheetSheetUdfInfoForSheetURI:timesheetUri moduleName:moduleName andUdfURI:[dictInfo objectForKey: @"identity"] entryDate:entryDateTimestamp andRowUri:rowUri];




        if ([selectedudfArray count]>0)
        {
            NSMutableDictionary *selUDFDataDict=[selectedudfArray objectAtIndex:0];
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];
            if (selUDFDataDict!=nil && ![selUDFDataDict isKindOfClass:[NSNull class]]) {
                NSString *udfvaleFormDb=[selUDFDataDict objectForKey: @"udfValue"];
                if (udfvaleFormDb!=nil && ![udfvaleFormDb isKindOfClass:[NSNull class]])
                {
                    if (![udfvaleFormDb isEqualToString:@""]) {
                        if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DATE_UDF_TYPE])
                        {
                            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];

                            NSLocale *locale=[NSLocale currentLocale];
                            [dateFormat setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                            [dateFormat setLocale:locale];
                            [dateFormat setDateFormat:@"yyyy-MM-dd"];
                            NSDate *setDate=[dateFormat dateFromString:udfvaleFormDb];
                            if (!setDate) {
                                [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                                setDate=[dateFormat dateFromString:udfvaleFormDb];

                                if (setDate==nil) {
                                    [dateFormat setDateFormat:@"d MMMM yyyy"];
                                    setDate = [dateFormat dateFromString:udfvaleFormDb];
                                    if (setDate==nil)
                                    {
                                        [dateFormat setDateFormat:@"d MMMM, yyyy"];
                                        setDate = [dateFormat dateFromString:udfvaleFormDb];

                                    }
                                }

                            }
                            [dateFormat setDateFormat:@"MMMM dd, yyyy"];
                            udfvaleFormDb=[dateFormat stringFromDate:setDate];
                            NSDate *dateToBeUsed = [dateFormat dateFromString:udfvaleFormDb];

                            [udfDetailDict setObject:dateToBeUsed forKey:@"defaultValue"];
                        }
                        else{
                            if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:NUMERIC_UDF_TYPE])
                            {
                                [udfDetailDict setObject:[Util getRoundedValueFromDecimalPlaces:[udfvaleFormDb newDoubleValue] withDecimalPlaces:decimalPlace] forKey:@"defaultValue"];
                            }
                            else
                                [udfDetailDict setObject:udfvaleFormDb forKey:@"defaultValue"];
                            if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DROPDOWN_UDF_TYPE])
                            {
                                [udfDetailDict setObject:[selUDFDataDict objectForKey: @"dropDownOptionURI" ] forKey:@"dropDownOptionUri"];
                            }

                        }

                    }
                    else
                    {
                        [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];

                    }

                }
                else
                {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];
                }
                [udfDetailDict setObject:[dictInfo objectForKey: @"fieldName" ] forKey:@"name"];
                if ([dictInfo objectForKey: @"systemDefaultValue"]!=nil && ![[dictInfo objectForKey: @"systemDefaultValue"]isKindOfClass:[NSNull class]]) {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"systemDefaultValue"] forKey:@"systemDefaultValue"];
                }
                else{
                    [udfDetailDict setObject:[NSNull null] forKey:@"systemDefaultValue"];
                }
                
                [udfDetailDict setObject:[dictInfo objectForKey: @"fieldType"] forKey:@"type"];
                [udfDetailDict setObject:[dictInfo objectForKey: @"identity"] forKey:@"uri"];
                if ([dictInfo objectForKey: @"defaultDecimalValue" ]!=nil)
                {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultDecimalValue" ] forKey:@"defaultDecimalValue"];
                }
                if ([dictInfo objectForKey: @"defaultMinValue" ]!=nil)
                {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultMinValue" ] forKey:@"defaultMinValue"];
                }
                if ([dictInfo objectForKey: @"defaultMaxValue" ]!=nil)
                {
                    [udfDetailDict setObject:[dictInfo objectForKey: @"defaultMaxValue" ] forKey:@"defaultMaxValue"];
                }
                
                //                if ([[selUDFDataDict objectForKey:@"entry_type"] isEqualToString:DROPDOWN_UDF_TYPE])
                //                {
                //                    if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
                //                    {
                //                        [udfDetailDict setObject:[dictInfo objectForKey: @"dropDownOptionUri" ] forKey:@"dropDownOptionUri"];
                //                    }
                //                }
                
                [customFieldArray addObject:udfDetailDict];
                
            }
        }
        else{
            NSMutableDictionary *udfDetailDict=[[NSMutableDictionary alloc]init];
            if ([entryType isEqualToString:Time_Off_Key]||(!isRowEditable && [entryType isEqualToString:Time_Entry_Key]))
            {
                [udfDetailDict setObject:RPLocalizedString(NONE_STRING, @"") forKey:@"defaultValue"];
            }
            else
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultValue" ] forKey:@"defaultValue"];
            }
            
            [udfDetailDict setObject:[dictInfo objectForKey: @"fieldName" ] forKey:@"name"];
            if ([dictInfo objectForKey: @"systemDefaultValue"]!=nil && ![[dictInfo objectForKey: @"systemDefaultValue"]isKindOfClass:[NSNull class]]) {
                [udfDetailDict setObject:[dictInfo objectForKey: @"systemDefaultValue"] forKey:@"systemDefaultValue"];
            }
            else{
                [udfDetailDict setObject:[NSNull null] forKey:@"systemDefaultValue"];
            }
            
            [udfDetailDict setObject:[dictInfo objectForKey: @"fieldType"] forKey:@"type"];
            [udfDetailDict setObject:[dictInfo objectForKey: @"identity"] forKey:@"uri"];
            if ([dictInfo objectForKey: @"defaultDecimalValue" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"defaultDecimalValue" ] forKey:@"defaultDecimalValue"];
            }
            if ([dictInfo objectForKey: @"dropDownOptionUri" ]!=nil)
            {
                [udfDetailDict setObject:[dictInfo objectForKey: @"dropDownOptionUri" ] forKey:@"dropDownOptionUri"];
            }
            [customFieldArray addObject:udfDetailDict];
            
            
        }
        
    }
    
    return customFieldArray;
}

#pragma mark - Private

- (NSString *)urlStringWithEndpointName:(NSString *)endpointName
{
    NSString *serviceEndpoint = [[NSUserDefaults standardUserDefaults] objectForKey:@"serviceEndpointRootUrl"];
    AppProperties *appProperties = [AppProperties getInstance];
    NSString *endpointPath = [appProperties getServiceURLFor: endpointName];

    return [NSString stringWithFormat:@"%@%@", serviceEndpoint, endpointPath];
}

-(NSMutableArray *)constructCellOEFObjectForTimeSheetUri:(NSString*)timesheetUri andtimesheetFormat:(NSString *)timesheetFormat andOEFLevel:(NSString *)oefLevel andTimePunchUri:(NSString*)timePunchesUri
{
    NSMutableArray *oefObjectArr=[NSMutableArray array];
    TimesheetModel *timesheetModel = [[TimesheetModel alloc]init];
    NSArray *timesheetObjectExtensionsFieldsArr=[timesheetModel getTimesheetObjectExtensionFieldsForTimeSheetUri:timesheetUri andtimesheetFormat:timesheetFormat andOEFLevel:oefLevel];
    NSArray *timeEntryOEFArr=[timesheetModel getTimesheetEntryObjectExtensionFieldsForTimeSheetUri:timesheetUri andtimesheetEntryUri:timePunchesUri];

    for (NSDictionary *timesheetObjectExtensionsFieldsDict in timesheetObjectExtensionsFieldsArr)
    {
        OEFObject *oefObject=[[OEFObject alloc]init];
        NSString *oefUri=timesheetObjectExtensionsFieldsDict[@"uri"];
        oefObject.oefUri=oefUri;
        oefObject.oefName=timesheetObjectExtensionsFieldsDict[@"displayText"];
        oefObject.oefLevelType=oefLevel;
        oefObject.oefDefinitionTypeUri=timesheetObjectExtensionsFieldsDict[@"definitionTypeUri"];
        for (NSDictionary *timeEntryOEFDict in timeEntryOEFArr)
        {
            if ([timeEntryOEFDict[@"uri"] isEqualToString:oefUri])
            {
                NSString *definitionUri=timesheetObjectExtensionsFieldsDict[@"definitionTypeUri"];;
                if ([definitionUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
                {
                    oefObject.oefTextValue=timeEntryOEFDict[@"textValue"];
                }
                else if ([definitionUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
                {
                    oefObject.oefNumericValue=[NSString stringWithFormat:@"%@",timeEntryOEFDict[@"numericValue"]];
                }
                else if ([definitionUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
                {
                    oefObject.oefDropdownOptionUri=timeEntryOEFDict[@"dropdownOptionUri"];
                    oefObject.oefDropdownOptionValue=timeEntryOEFDict[@"dropdownOptionValue"];
                }

                break;
            }
        }


        [oefObjectArr addObject:oefObject];
        
    }
    
    return oefObjectArr;
}

-(NSMutableArray *)createDayLevelDailyWidgetOEFArrayForDate:(NSString *)dateString andTimeEntries:(NSMutableArray*)timeEntries andTimesheetUri:(NSString *)timesheetURI
{
    TimesheetModel *timeSheetModel=[[TimesheetModel alloc]init];

    NSMutableArray *dailyWidgetOEFArr=[timeSheetModel getTimesheetObjectExtensionFieldsForTimeSheetUri:timesheetURI andtimesheetFormat:GEN4_DAILY_WIDGET_TIMESHEET andOEFLevel:DAILY_WIDGET_DAYLEVEL_OEF];

    NSMutableArray *dayLevelDailyWidgetOEFArray = [NSMutableArray array];

    for (NSDictionary *timesheetObjectExtensionsFieldsDict in dailyWidgetOEFArr)
    {
        OEFObject *oefObject=[[OEFObject alloc]init];
        NSString *oefUri=timesheetObjectExtensionsFieldsDict[@"uri"];
        oefObject.oefUri=oefUri;
        oefObject.oefName=timesheetObjectExtensionsFieldsDict[@"displayText"];
        oefObject.oefLevelType=DAILY_WIDGET_DAYLEVEL_OEF;
        oefObject.oefDefinitionTypeUri=timesheetObjectExtensionsFieldsDict[@"definitionTypeUri"];

        for (NSDictionary *timeEntryDict in timeEntries)
        {
            NSString *rowUri=[timeEntryDict objectForKey:@"rowUri"];
            NSArray *timeEntryOEFArr=[timeSheetModel getTimesheetEntryObjectExtensionFieldsForTimeSheetUri:timesheetURI andtimesheetEntryUri:rowUri];

            for (NSDictionary *timeEntryOEFDict in timeEntryOEFArr)
            {
                if ([timeEntryOEFDict[@"uri"] isEqualToString:oefUri])
                {
                    NSString *definitionUri=timesheetObjectExtensionsFieldsDict[@"definitionTypeUri"];;
                    if ([definitionUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI])
                    {
                        oefObject.oefTextValue=timeEntryOEFDict[@"textValue"];
                    }
                    else if ([definitionUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI])
                    {
                        oefObject.oefNumericValue=[NSString stringWithFormat:@"%@",timeEntryOEFDict[@"numericValue"]];
                    }
                    else if ([definitionUri isEqualToString:OEF_DROPDOWN_DEFINITION_TYPE_URI])
                    {
                        oefObject.oefDropdownOptionUri=timeEntryOEFDict[@"dropdownOptionUri"];
                        oefObject.oefDropdownOptionValue=timeEntryOEFDict[@"dropdownOptionValue"];
                    }

                    break;
                }
            }
        }

        TimesheetEntryObject *tsEntryObject=[[TimesheetEntryObject alloc] init];

        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];

        NSLocale *locale=[NSLocale currentLocale];
        [formatter setLocale:locale];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [formatter setDateFormat:@"EEEE, dd MMM yyyy"];
        NSDate *todayDate=[formatter dateFromString:dateString];
        BOOL isRowEditable=YES;

        [tsEntryObject setIsRowEditable:isRowEditable];
        [tsEntryObject setTimeEntryDate:todayDate];
        [tsEntryObject setTimeAllocationUri:@""];
        [tsEntryObject setTimePunchUri:@""];
        [tsEntryObject setTimeEntryHoursInHourFormat:@""];
        [tsEntryObject setTimeEntryComments:@""];
        [tsEntryObject setTimesheetUri:timesheetURI];
        [tsEntryObject setEntryType:Time_Entry_Key];
        [tsEntryObject setTimeEntryDailyFieldOEFArray:[NSMutableArray arrayWithObject:oefObject]];
        [dayLevelDailyWidgetOEFArray addObject:tsEntryObject];
        
    }
    
    return dayLevelDailyWidgetOEFArray;
}

-(NSMutableArray  *)saveDailyWidgetTimeSheetData:(NSMutableArray *)timesheetArray andTimesheetUri:(NSString *)timesheetUri
{

    NSMutableArray *timeEntriesArray=[[RepliconServiceManager timesheetRequest] constructTimeEntriesArrForSavingWidgetTimesheet:timesheetArray andTimeSheetFormat:GEN4_DAILY_WIDGET_TIMESHEET andIsHybridTimesheet:NO];


    return timeEntriesArray;
    
}

-(void)businessLogicErrorHandlingFortimesheetUri:(NSString *)timeSheetURI
{
    [self.timesheetModel deleteAllOperationNamesForTimesheetURI:timeSheetURI];

    NSArray *timesheetsArr=[self.timesheetModel getTimeSheetInfoSheetIdentity:timeSheetURI];
    NSMutableDictionary *timesheetDict=nil;
    if (timesheetsArr.count>0)
    {
        timesheetDict=[timesheetsArr[0] mutableCopy];
        if (timesheetDict[@"lastKnownApprovalStatus"]!=nil && ![timesheetDict[@"lastKnownApprovalStatus"] isKindOfClass:[NSNull class]])
        {
            if ([timesheetDict[@"lastKnownApprovalStatus"] isEqualToString:NOT_SUBMITTED_STATUS] || [timesheetDict[@"lastKnownApprovalStatus"] isEqualToString:REJECTED_STATUS])
            {
                [timesheetDict setObject:[NSNumber numberWithInt:1]  forKey:@"canEditTimesheet" ];
            }

            [timesheetDict setObject:timesheetDict[@"lastKnownApprovalStatus"] forKey:@"approvalStatus" ];

        }

        [self.timesheetModel updateTimesheetDataForTimesheetUri:timeSheetURI withDataDict:timesheetDict];
    }

    [self.timesheetModel deleteLastKnownApprovalStatusForTimesheetURI:timeSheetURI];
}

@end
