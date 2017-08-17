//
//  TimeOffDetailsObject.m
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 2/2/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import "TimeOffDetailsObject.h"
#import "Util.h"
#import "Constants.h"

@implementation TimeOffDetailsObject

-(id)initWithDictionary:(NSDictionary *)timeOffDict
{
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

        
        self.startNumberOfHours = [Util getRoundedValueFromDecimalPlaces:[[timeOffDict objectForKey:@"startDateDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
        self.endNumberOfHours = [Util getRoundedValueFromDecimalPlaces:[[timeOffDict objectForKey:@"endDateDurationDecimal"]newDoubleValue]withDecimalPlaces:2];
        self.startTime =[timeOffDict objectForKey:@"startDateTime"];;
        self.endTime = [timeOffDict objectForKey:@"endDateTime"];
        self.totalTimeOffDays = [Util getRoundedValueFromDecimalPlaces:[[timeOffDict objectForKey:@"totalTimeoffDays"]newDoubleValue]withDecimalPlaces:2];
        self.resubmitComments = [timeOffDict objectForKey:@""];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    TimeOffDetailsObject *copy = [[[self class] allocWithZone: zone] init];
    [copy setTypeName:[self typeName]];
    [copy setTypeIdentity:[self typeIdentity]];
    [copy setComments:[self comments]];
    [copy setIdentity:[self identity]];
    [copy setSheetId:[self sheetId]];
    [copy setNumberOfHours:[self numberOfHours]];
    [copy setEntryType:[self entryType]];
    [copy setApprovalStatus:[self approvalStatus]];
    [copy setBookedStartDate:[self bookedStartDate]];
    [copy setBookedEndDate:[self bookedEndDate]];
    [copy setEntryDate:[self entryDate]];
    [copy setStartDurationEntryType:[self startDurationEntryType]];
    [copy setEndDurationEntryType:[self endDurationEntryType]];
    [copy setStartNumberOfHours:[self startNumberOfHours]];
    [copy setEndNumberOfHours:[self endNumberOfHours]];
    [copy setStartTime:[self startTime]];
    [copy setEndTime:[self endTime]];
    [copy setTotalTimeOffDays:[self totalTimeOffDays]];
    [copy setResubmitComments:[self resubmitComments]];
    return copy;
}

@end
