//
//  TimeOffObject.m
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 1/27/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimeOffObject.h"
#import "Util.h"
#import "Constants.h"

@implementation TimeOffObject
-(id)initWithDataDictionary:(NSDictionary *)timeOffDict {
    self = [super init];
    if (self!=nil)
    {
        self.typeName = [timeOffDict objectForKey:@"timeoffTypeName"];
        self.typeIdentity = [timeOffDict objectForKey:@"timeoffTypeUri"];
        self.comments = [timeOffDict objectForKey:@"comments"];
        self.identity = [timeOffDict objectForKey:@""];
        self.sheetId = [timeOffDict objectForKey:@"timeoffUri"];
        self.numberOfHours = [Util getRoundedValueFromDecimalPlaces:[[timeOffDict objectForKey:@"totalDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
        self.entryType = [timeOffDict objectForKey:@""];
        self.approvalStatus = [timeOffDict objectForKey:@"approvalStatus"];
        self.bookedStartDate = [Util convertTimestampFromDBToDate:[[timeOffDict objectForKey:@"startDate"] stringValue]];
        self.bookedEndDate = [Util convertTimestampFromDBToDate:[[timeOffDict objectForKey:@"endDate"] stringValue]];
        self.entryDate = [timeOffDict objectForKey:@""];
        if([timeOffDict objectForKey:@"isDeviceSupportedEntryConfiguration"]!=nil && ![[timeOffDict objectForKey:@"isDeviceSupportedEntryConfiguration"]isKindOfClass:[NSNull class]])
        {
            self.isDeviceSupportedEntryConfiguration = [[timeOffDict objectForKey:@"isDeviceSupportedEntryConfiguration"] boolValue];
        }
        if([timeOffDict objectForKey:@"startEntryDurationUri"]!=nil && ![[timeOffDict objectForKey:@"startEntryDurationUri"]isKindOfClass:[NSNull class]])
        {
            if ([[timeOffDict objectForKey:@"startEntryDurationUri"] isEqualToString:FULLDAY_DURATION_TYPE_KEY])
            {
                self.startDurationEntryType=FULLDAY_DURATION_TYPE_KEY;
            }
            else if ([[timeOffDict objectForKey:@"startEntryDurationUri"] isEqualToString:HALFDAY_DURATION_TYPE_KEY])
            {
                self.startDurationEntryType=HALFDAY_DURATION_TYPE_KEY;
            }
            else if ([[timeOffDict objectForKey:@"startEntryDurationUri"] isEqualToString:THREEQUARTERDAY_DURATION_KEY])
            {
                self.startDurationEntryType=THREEQUARTERDAY_DURATION_KEY;
            }
            else if([[timeOffDict objectForKey:@"startEntryDurationUri"] isEqualToString:QUARTERDAY_DURATION_KEY])
            {
                self.startDurationEntryType=QUARTERDAY_DURATION_KEY;
            }
            else
                self.startDurationEntryType=PARTIAL ;
        }
        
        if([timeOffDict objectForKey:@"endEntryDurationUri"]!=nil && ![[timeOffDict objectForKey:@"endEntryDurationUri"]isKindOfClass:[NSNull class]])
        {
        if ([[timeOffDict objectForKey:@"endEntryDurationUri"] isEqualToString:FULLDAY_DURATION_TYPE_KEY])
        {
            self.endDurationEntryType=FULLDAY_DURATION_TYPE_KEY;
        }
        else if ([[timeOffDict objectForKey:@"endEntryDurationUri"] isEqualToString:HALFDAY_DURATION_TYPE_KEY])
        {
            self.endDurationEntryType=HALFDAY_DURATION_TYPE_KEY;
        }
        else if ([[timeOffDict objectForKey:@"endEntryDurationUri"] isEqualToString:THREEQUARTERDAY_DURATION_KEY])
        {
            self.endDurationEntryType=THREEQUARTERDAY_DURATION_KEY;
        }
        else if([[timeOffDict objectForKey:@"endEntryDurationUri"] isEqualToString:QUARTERDAY_DURATION_KEY])
        {
            self.endDurationEntryType=QUARTERDAY_DURATION_KEY;
        }
        else
            self.endDurationEntryType=PARTIAL ;
        }
        if([timeOffDict objectForKey:@"startDateDurationDecimal"]!=nil && ![[timeOffDict objectForKey:@"startDateDurationDecimal"]isKindOfClass:[NSNull class]])
        {
        self.startNumberOfHours = [Util getRoundedValueFromDecimalPlaces:[[timeOffDict objectForKey:@"startDateDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
        }
        if([timeOffDict objectForKey:@"endDateDurationDecimal"]!=nil && ![[timeOffDict objectForKey:@"endDateDurationDecimal"]isKindOfClass:[NSNull class]])
        {
        self.endNumberOfHours = [Util getRoundedValueFromDecimalPlaces:[[timeOffDict objectForKey:@"endDateDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
        }
        if([timeOffDict objectForKey:@"startDateTime"]!=nil && ![[timeOffDict objectForKey:@"startDateTime"]isKindOfClass:[NSNull class]])
        {
        self.startTime =[timeOffDict objectForKey:@"startDateTime"];
        }
        if([timeOffDict objectForKey:@"endDateTime"]!=nil && ![[timeOffDict objectForKey:@"endDateTime"]isKindOfClass:[NSNull class]])
        {
        self.endTime = [timeOffDict objectForKey:@"endDateTime"];
        }
        if([timeOffDict objectForKey:@"totalTimeoffDays"]!=nil && ![[timeOffDict objectForKey:@"totalTimeoffDays"]isKindOfClass:[NSNull class]])
        {
        self.totalTimeOffDays = [Util getRoundedValueFromDecimalPlaces:[[timeOffDict objectForKey:@"totalTimeoffDays"]newDoubleValue]withDecimalPlaces:2];
        }
        if(timeOffDict[@"timeOffDisplayFormatUri"]!=nil && ![[timeOffDict objectForKey:@"timeOffDisplayFormatUri"]isKindOfClass:[NSNull class]])
        {
            self.timeOffDisplayFormatUri = timeOffDict[@"timeOffDisplayFormatUri"];
        }
        if(timeOffDict[@"totalDurationHour"]!=nil && ![[timeOffDict objectForKey:@"totalDurationHour"]isKindOfClass:[NSNull class]])
        {
            self.totalDurationHour = timeOffDict[@"totalDurationHour"];
        }

        self.resubmitComments = [timeOffDict objectForKey:@""];
        
    }
    return self;}
-(id) copyWithZone: (NSZone *) zone
{
    TimeOffObject *copyObject = [[[self class] allocWithZone: zone] init];
    [copyObject setTypeName:[self typeName]];
    [copyObject setTypeName:[self typeName]];
    [copyObject setTypeIdentity:[self typeIdentity]];
    [copyObject setComments:[self comments]];
    [copyObject setIdentity:[self identity]];
    [copyObject setSheetId:[self sheetId]];
    [copyObject setNumberOfHours:[self numberOfHours]];
    [copyObject setEntryType:[self entryType]];
    [copyObject setApprovalStatus:[self approvalStatus]];
    [copyObject setBookedStartDate:[self bookedStartDate]];
    [copyObject setBookedEndDate:[self bookedEndDate]];
    [copyObject setEntryDate:[self entryDate]];
    [copyObject setStartDurationEntryType:[self startDurationEntryType]];
    [copyObject setEndDurationEntryType:[self endDurationEntryType]];
    [copyObject setStartNumberOfHours:[self startNumberOfHours]];
    [copyObject setEndNumberOfHours:[self endNumberOfHours]];
    [copyObject setStartTime:[self startTime]];
    [copyObject setEndTime:[self endTime]];
    [copyObject setTotalTimeOffDays:[self totalTimeOffDays]];
    [copyObject setResubmitComments:[self resubmitComments]];
    [copyObject setTimeOffDisplayFormatUri:[self timeOffDisplayFormatUri]];
    [copyObject setTotalDurationHour:[self totalDurationHour]];
    [copyObject setIsDeviceSupportedEntryConfiguration:[self isDeviceSupportedEntryConfiguration]];
    return copyObject;

}
@end
