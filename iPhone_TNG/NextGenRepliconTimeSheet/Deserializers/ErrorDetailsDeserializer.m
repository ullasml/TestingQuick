//
//  ErrorDetailsDeserializer.m
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 5/12/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "ErrorDetailsDeserializer.h"
#import "ErrorDetails.h"
#import "DateProvider.h"
#import "Constants.h"
#import "TimesheetModel.h"

@interface ErrorDetailsDeserializer ()

@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) TimesheetModel *timeSheetModel;

@end

@implementation ErrorDetailsDeserializer

- (instancetype)initWithDateProvider:(DateProvider *)dateProvider
                       dateFormatter:(NSDateFormatter *)dateFormatter
                      timeSheetModel:(TimesheetModel *)timeSheetModel
{
    self = [super init];
    if (self) {
        self.dateProvider = dateProvider;
        self.dateFormatter = dateFormatter;
        self.timeSheetModel = timeSheetModel;
    }
    return self;
}

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary
{
    NSMutableArray *allErrorDetails = [NSMutableArray array];

    NSDate *currentDate = [self.dateProvider date];

    NSString *utcDateStr = [self.dateFormatter stringFromDate:currentDate];

    ErrorDetails *errorDetails = [[ErrorDetails alloc] initWithUri:jsonDictionary[@"uri"] errorMessage:jsonDictionary[@"error_msg"] errorDate:utcDateStr moduleName:jsonDictionary[@"module"]];
    [allErrorDetails addObject:errorDetails];
    return allErrorDetails;
}

-(NSArray *)deserializeValidationServiceResponse:(NSDictionary *)jsonDictionary
{
    NSMutableArray *allErrorDetails = [NSMutableArray array];

    NSDate *currentDate = [self.dateProvider date];

    NSString *utcDateStr = [self.dateFormatter stringFromDate:currentDate];

    NSArray *timesheetArray = jsonDictionary[@"timesheet"];
    for (NSDictionary *timesheetDict in timesheetArray)
    {
        NSDictionary *errorDict = timesheetDict[@"error"];
        if (errorDict!=nil && ![errorDict isKindOfClass:[NSNull class]])
        {
            NSString *displayText = errorDict[@"displayText"];
            if (displayText!=nil && ![displayText isKindOfClass:[NSNull class]])
            {
                if (![displayText isEqualToString:@"Timesheet does not exist"])
                {
                    ErrorDetails *errorDetails = [[ErrorDetails alloc] initWithUri:timesheetDict[@"objectUri"] errorMessage:displayText errorDate:utcDateStr moduleName:TIMESHEETS_TAB_MODULE_NAME];
                    [allErrorDetails addObject:errorDetails];
                }
            }

        }
        else
        {
            NSArray *notificationArr = timesheetDict[@"notifications"];
            NSString *newLineDisplayText = nil;
            for (NSDictionary *notificationDict in notificationArr)
            {
                NSString *displayText = notificationDict[@"displayText"];
                if (displayText!=nil && ![displayText isKindOfClass:[NSNull class]])
                {
                    if (newLineDisplayText)
                    {
                        newLineDisplayText = [NSString stringWithFormat:@"%@\n\n%@",newLineDisplayText,displayText];
                    }
                    else
                    {
                        newLineDisplayText = [NSString stringWithFormat:@"%@",displayText];
                    }

                }
            }

            if (newLineDisplayText)
            {
                ErrorDetails *errorDetails = [[ErrorDetails alloc] initWithUri:timesheetDict[@"objectUri"] errorMessage:newLineDisplayText errorDate:utcDateStr moduleName:TIMESHEETS_TAB_MODULE_NAME];
                [allErrorDetails addObject:errorDetails];
            }


        }
    }


    return allErrorDetails;
}

-(NSMutableArray *)deserializeTimeSheetUpdateData:(NSDictionary *)jsonDictionary
{
    
    NSMutableDictionary *mainresponseDict=jsonDictionary[@"d"];
    NSMutableArray *deletedErrorDetailsUris = [NSMutableArray array];
    if ([mainresponseDict count]>0 && mainresponseDict!=nil)
    {
        if ([mainresponseDict objectForKey:@"updateMode"]!=nil && ![[mainresponseDict objectForKey:@"updateMode"] isKindOfClass:[NSNull class]])
        {
            if ([[mainresponseDict objectForKey:@"updateMode"]isEqualToString:FULL_UPDATEMODE])
            {
                deletedErrorDetailsUris = [self.timeSheetModel getAllTimesheetsUrisFromDB];

            }
            else if ([[mainresponseDict objectForKey:@"updateMode"]isEqualToString:DELTA_UPDATEMODE])
            {
                if ([mainresponseDict objectForKey:@"deletedObjects"]!=nil && ![[mainresponseDict objectForKey:@"deletedObjects"] isKindOfClass:[NSNull class]])
                {
                    NSMutableArray *deletedObjArray=[mainresponseDict objectForKey:@"deletedObjects"];
                    for (int i=0; i<[deletedObjArray count]; i++)
                    {
                        if ([[deletedObjArray objectAtIndex:i] objectForKey:@"uri"]!=nil && ![[[deletedObjArray objectAtIndex:i] objectForKey:@"uri"] isKindOfClass:[NSNull class]]) {
                            NSString *timesheetURI=[[deletedObjArray objectAtIndex:i] objectForKey:@"uri"];
                            [deletedErrorDetailsUris addObject:timesheetURI];
                        }


                    }
                }
            }
        }

        if ([mainresponseDict objectForKey:@"listData"]!=nil && ![[mainresponseDict objectForKey:@"listData"] isKindOfClass:[NSNull class]])
        {
            NSDictionary *responseDict = mainresponseDict[@"listData"];
            NSMutableArray *headerArray=[responseDict objectForKey:@"header"];
            NSMutableArray *rowsArray=[responseDict objectForKey:@"rows"];
            if (rowsArray!=nil && ![rowsArray isKindOfClass:[NSNull class]])
            {
                for (int i=0; i<[rowsArray count]; i++)
                {
                    NSString *timesheetURI=@"";
                    NSArray *array=[[rowsArray objectAtIndex:i] objectForKey:@"cells"];
                    for (int k=0; k<[array count]; k++)
                    {
                        NSString *refrenceHeaderUri=[[headerArray objectAtIndex:k] objectForKey:@"uri"];
                        NSMutableArray *columnUriArray=nil;
                        columnUriArray=[[AppProperties getInstance] getTimesheetColumnURIFromPlist];
                        NSString *refrenceHeader=nil;
                        for (int i=0; i<[columnUriArray count]; i++)
                        {
                            NSMutableDictionary *columnDict=[columnUriArray objectAtIndex:i];
                            NSString *uri=[columnDict objectForKey:@"uri"];

                            if ([refrenceHeaderUri isEqualToString:uri])
                            {
                                refrenceHeader=[columnDict objectForKey:@"name"];
                                break;
                            }
                        }

                        NSMutableDictionary *responseDict=[array objectAtIndex:k];

                        if ([refrenceHeader isEqualToString:@"Timesheet"])
                        {
                            timesheetURI=[responseDict objectForKey:@"uri"];
                            break;
                        }

                    }
                

                    if ([self.timeSheetModel getPendingOperationsArr:timesheetURI].count==0)
                    {
                        [deletedErrorDetailsUris addObject:timesheetURI];
                    }

                }
            }
        }
    }

    return deletedErrorDetailsUris;
    
}


@end
