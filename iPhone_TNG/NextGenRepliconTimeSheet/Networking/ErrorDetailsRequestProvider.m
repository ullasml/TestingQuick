//
//  ErrorDetailsRequestProvider.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 6/2/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "ErrorDetailsRequestProvider.h"
#import "URLStringProvider.h"
#import "RequestBuilder.h"
#import "AppProperties.h"
#import "DateProvider.h"
#import "Util.h"

@interface ErrorDetailsRequestProvider ()

@property (nonatomic) URLStringProvider *urlStringProvider;
@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic, readwrite) NSUserDefaults *userDefaults;
@end

@implementation ErrorDetailsRequestProvider

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider dateProvider:(DateProvider *)dateProvider defaults:(NSUserDefaults *)userDefaults
{
    self = [super init];
    if (self) {
        self.urlStringProvider = urlStringProvider;
        self.dateProvider = dateProvider;
        self.userDefaults = userDefaults;
    }
    return self;
}

- (NSURLRequest *)requestForValidationErrorsWithURI:(NSArray *)uris
{

    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"ErrorDetails_Validation"];

    NSDictionary *requestBody = @{
                                   @"uri":uris
                                  };
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};

    NSMutableURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];

    return request;
}

- (NSURLRequest *)requestForTimeSheetUpdateDataForUserUri:(NSString *)strUserURI
{
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"GetTimesheetUpdateData"];

    NSDictionary *leftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNull null],@"leftExpression",
                                      [NSNull null],@"operatorUri",
                                      [NSNull null],@"rightExpression",
                                      [NSNull null],@"value",
                                      @"urn:replicon:timesheet-list-filter:timesheet-owner",@"filterDefinitionUri",
                                      nil];



    NSDictionary *valueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                             strUserURI,@"uri",
                             [NSNull null],@"uris",
                             [NSNull null],@"bool",
                             [NSNull null],@"date",
                             [NSNull null],@"money",
                             [NSNull null],@"number",
                             [NSNull null],@"text",
                             [NSNull null],@"time",
                             [NSNull null],@"calendarDayDurationValue",
                             [NSNull null],@"workdayDurationValue",
                             [NSNull null],@"dateRange", nil];



    NSDictionary *rightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNull null],@"leftExpression",
                                       [NSNull null],@"operatorUri",
                                       [NSNull null],@"rightExpression",
                                       valueDict,@"value",
                                       [NSNull null],@"filterDefinitionUri",
                                       nil];

    NSDictionary *finalLeftExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                           leftExpressionDict,@"leftExpression",
                                           @"urn:replicon:filter-operator:equal",@"operatorUri",
                                           rightExpressionDict,@"rightExpression",
                                           [NSNull null],@"value",
                                           [NSNull null],@"filterDefinitionUri",
                                           nil];


    NSDictionary *rightExpressionsLeftDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            [NSNull null],@"leftExpression",
                                            [NSNull null],@"operatorUri",
                                            [NSNull null],@"rightExpression",
                                            [NSNull null],@"value",
                                            @"urn:replicon:timesheet-list-filter:timesheet-period-date-range",@"filterDefinitionUri",
                                            nil];


    NSDate *date = [self.dateProvider date];
    NSDictionary *todayDateDict=[Util convertDateToApiDateDictionaryOnLocalTimeZone:date];
    NSDictionary *currentDateDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                   [todayDateDict objectForKey:@"day"],@"day",
                                   [todayDateDict objectForKey:@"month"],@"month",
                                   [todayDateDict objectForKey:@"year"],@"year",
                                   nil];

    NSDictionary *dateRangeDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNull null],@"relativeDateRangeAsOfDate",
                                 [NSNull null],@"relativeDateRangeUri",
                                 [NSNull null],@"startDate",
                                 currentDateDict,@"endDate",
                                 nil];

    NSDictionary *rightExpressionsValueDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNull null],@"bool",
                                             [NSNull null],@"calendarDayDurationValue",
                                             [NSNull null],@"date",
                                             [NSNull null],@"money",
                                             [NSNull null],@"number",
                                             [NSNull null],@"text",
                                             [NSNull null],@"time",
                                             [NSNull null],@"uri",
                                             [NSNull null],@"uris",
                                             [NSNull null],@"workdayDurationValue",
                                             dateRangeDict,@"dateRange", nil];

    NSDictionary *rightExpressionsRightDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNull null],@"leftExpression",
                                             [NSNull null],@"operatorUri",
                                             [NSNull null],@"rightExpression",
                                             rightExpressionsValueDict,@"value",
                                             [NSNull null],@"filterDefinitionUri",
                                             nil];


    NSDictionary *finalRightExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                            rightExpressionsLeftDict,@"leftExpression",
                                            @"urn:replicon:filter-operator:in",@"operatorUri",
                                            rightExpressionsRightDict,@"rightExpression",
                                            [NSNull null],@"value",
                                            [NSNull null],@"filterDefinitionUri",
                                            nil];


    NSDictionary *filterDict=[NSDictionary dictionaryWithObjectsAndKeys:
                              finalLeftExpressionDict,@"leftExpression",
                              @"urn:replicon:filter-operator:and",@"operatorUri",
                              finalRightExpressionDict,@"rightExpression",
                              [NSNull null],@"value",
                              [NSNull null],@"filterDefinitionUri",
                              nil];




    NSMutableArray *columnUriArray=nil;
    columnUriArray=[[AppProperties getInstance] getTimesheetColumnURIFromPlist];
    NSMutableArray *requestColumnUriArray=[NSMutableArray array];
    for (int i=0; i<[columnUriArray count]; i++)
    {
        NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
        NSString *columnName=[columnDict objectForKey:@"name"];

        if ([columnName isEqualToString:@"Timesheet Period"]||
            [columnName isEqualToString:@"Regular Hours"]||
            [columnName isEqualToString:@"Overtime Hours"]||
            [columnName isEqualToString:@"Time Off Hours"]||
            [columnName isEqualToString:@"Total Hours"]||
            [columnName isEqualToString:@"Due Date"]||
            [columnName isEqualToString:@"Meal Penalties"]||
            [columnName isEqualToString:@"Timesheet"]||
            [columnName isEqualToString:@"Approval Status"]||
            [columnName isEqualToString:@"Total Hours Excluding Break"])
        {
            [requestColumnUriArray addObject:[columnDict objectForKey:@"uri"]];
        }
    }

    NSDictionary *requestBody = nil;
    if ([requestColumnUriArray count]>0 && requestColumnUriArray!=nil)
    {
        NSNumber *pageSize=[[AppProperties getInstance] getAppPropertyFor:@"timesheetDownloadCount"];

        NSMutableArray *sortArray=[NSMutableArray array];
        NSDictionary *sortExpressionDict=[NSDictionary dictionaryWithObjectsAndKeys:
                                          @"urn:replicon:timesheet-list-column:timesheet-period",@"columnUri",
                                          @"false",@"isAscending",
                                          nil];
        [sortArray addObject:sortExpressionDict];


        NSMutableDictionary *lastUpdatedDateTimeDict = nil;
        id lastUpdatedDateTime;

        NSString *lastUpdateDateStr=(NSString*)[self.userDefaults objectForKey:@"ErrorTimeSheetLastModifiedTime"];

        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSLocale *locale=[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [dateFormatter setLocale:locale];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];

        NSDate *lastUpdateDate=[dateFormatter dateFromString:lastUpdateDateStr];




        unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute|NSCalendarUnitSecond;
        NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [calendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        NSDateComponents *comps = [calendar components:unitFlags fromDate:lastUpdateDate];
        if(comps != nil) {
            lastUpdatedDateTimeDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInteger:[comps year]],@"year",
                                       [NSNumber numberWithInteger:[comps month]],@"month",
                                       [NSNumber numberWithInteger:[comps day]], @"day",
                                       [NSNumber numberWithInteger:[comps hour]],@"hour",
                                       [NSNumber numberWithInteger:[comps minute]],@"minute",
                                       [NSNumber numberWithInteger:[comps second]],@"second",
                                       UTC_TIMEZONE,@"timeZoneUri",
                                       nil];
            lastUpdatedDateTime=lastUpdatedDateTimeDict;
        }
        else{
            lastUpdatedDateTime=[NSNull null];
        }


        requestBody = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     pageSize,@"pageSize",
                                     requestColumnUriArray,@"columnUris",
                                     sortArray,@"sort",filterDict,@"filterExpression",
                                     lastUpdatedDateTime,@"lastUpdatedDateTime",nil];

    }


    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};

    NSMutableURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];

    return request;
}

@end
