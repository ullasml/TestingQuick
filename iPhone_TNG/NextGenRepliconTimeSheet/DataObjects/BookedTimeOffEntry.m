//
//  BookedTimeOffEntry.m
//  Replicon
//
//  Created by Swapna P on 7/14/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import "BookedTimeOffEntry.h"


@implementation BookedTimeOffEntry
@synthesize typeName;
@synthesize typeIdentity;
@synthesize comments;
@synthesize sheetId;
@synthesize numberOfHours;
@synthesize entryType;
@synthesize approvalStatus;
@synthesize bookedStartDate;
@synthesize bookedEndDate;
@synthesize entryDate;
@synthesize startDurationEntryType;
@synthesize endDurationEntryType;
@synthesize startNumberOfHours;
@synthesize endNumberOfHours;
@synthesize startTime;
@synthesize endTime;
@synthesize totalTimeOffDays;
@synthesize resubmitComments;

- (id)copyWithZone:(NSZone *)zone
{
    
    BookedTimeOffEntry *copy = [[[self class] allocWithZone: zone] init];
    copy->typeName = nil;
    [copy setTypeName:[self typeName]];
    copy->typeName = nil;
    [copy setTypeName:[self typeName]];
    copy->typeIdentity = nil;
    [copy setTypeIdentity:[self typeIdentity]];
    copy->comments = nil;
    [copy setComments:[self comments]];
    [copy setIdentity:[self identity]];
    copy->sheetId = nil;
    [copy setSheetId:[self sheetId]];
    copy->numberOfHours = nil;
    [copy setNumberOfHours:[self numberOfHours]];
    copy->entryType = nil;
    [copy setEntryType:[self entryType]];
    copy->approvalStatus = nil;
    [copy setApprovalStatus:[self approvalStatus]];
    copy->bookedStartDate = nil;
    [copy setBookedStartDate:[self bookedStartDate]];
    copy->bookedEndDate = nil;
    [copy setBookedEndDate:[self bookedEndDate]];
    copy->entryDate = nil;
    [copy setEntryDate:[self entryDate]];
    copy->startDurationEntryType = nil;
    [copy setStartDurationEntryType:[self startDurationEntryType]];
    copy->endDurationEntryType = nil;
    [copy setEndDurationEntryType:[self endDurationEntryType]];
    copy->startNumberOfHours=nil;
    [copy setStartNumberOfHours:[self startNumberOfHours]];
    copy->endNumberOfHours=nil;
    [copy setEndNumberOfHours:[self endNumberOfHours]];
    copy->startTime=nil;
    [copy setStartTime:[self startTime]];
    copy->endTime=nil;
    [copy setEndTime:[self endTime]];
    copy->totalTimeOffDays=nil;
    [copy setTotalTimeOffDays:[self totalTimeOffDays]];
    copy->resubmitComments=nil;
    [copy setResubmitComments:[self resubmitComments]];
    
    return copy;
}




@end
