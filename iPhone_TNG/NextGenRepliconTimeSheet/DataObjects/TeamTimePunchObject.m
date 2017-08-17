//
//  TeamTimePunchObject.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 27/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "TeamTimePunchObject.h"

@implementation TeamTimePunchObject
@synthesize PunchInAddress;
@synthesize PunchInDate;
@synthesize PunchInDateTimestamp;
@synthesize PunchInLatitude;
@synthesize PunchInLongitude;
@synthesize PunchInTime;
@synthesize PunchOutAddress;
@synthesize PunchOutDate;
@synthesize PunchOutDateTimestamp;
@synthesize PunchOutLatitude;
@synthesize PunchOutLongitude;
@synthesize PunchOutTime;
@synthesize activityName;
@synthesize activityUri;
@synthesize punchInAgent;
@synthesize punchInAgentUri;
@synthesize punchInCloudClockUri;
@synthesize punchInFullSizeImageLink;
@synthesize punchInFullSizeImageUri;
@synthesize punchInThumbnailSizeImageLink;
@synthesize punchInThumbnailSizeImageUri;
@synthesize punchInUri;
@synthesize punchOutAgent;
@synthesize punchOutAgentUri;
@synthesize punchOutCloudClockUri;
@synthesize punchOutFullSizeImageLink;
@synthesize punchOutFullSizeImageUri;
@synthesize punchOutThumbnailSizeImageLink;
@synthesize punchOutThumbnailSizeImageUri;
@synthesize punchOutUri;
@synthesize punchUserName;
@synthesize punchUserUri;
@synthesize totalHours;
@synthesize CellIdentifier;
@synthesize breakName;
@synthesize breakUri;
@synthesize punchTransferredStatus;
@synthesize isBreakPunch;
@synthesize punchInAccuracyInMeters;
@synthesize punchOutAccuracyInMeters;
@synthesize isInManualEditPunch;
@synthesize isOutManualEditPunch;
@synthesize punchInActionUri;
@synthesize punchOutActionUri;


- (id)copyWithZone:(NSZone *)zone
{
    
    TeamTimePunchObject *copy = [[[self class] allocWithZone: zone] init];
    copy->PunchInAddress = nil;
    [copy setPunchInAddress:[self PunchInAddress]];
    copy->PunchInDate = nil;
    [copy setPunchInDate:[self PunchInDate]];
    copy->PunchInDateTimestamp = nil;
    [copy setPunchInDateTimestamp:[self PunchInDateTimestamp]];
    copy->PunchInLatitude = nil;
    [copy setPunchInLatitude:[self PunchInLatitude]];
    copy->PunchInLongitude = nil;
    [copy setPunchInLongitude:[self PunchInLongitude]];
    copy->PunchInTime = nil;
    [copy setPunchInTime:[self PunchInTime]];
    copy->PunchOutAddress = nil;
    [copy setPunchOutAddress:[self PunchOutAddress]];
    copy->PunchOutDate = nil;
    [copy setPunchOutDate:[self PunchOutDate]];
    copy->PunchOutDateTimestamp = nil;
    [copy setPunchOutDateTimestamp:[self PunchOutDateTimestamp]];
    copy->PunchOutLatitude = nil;
    [copy setPunchOutLatitude:[self PunchOutLatitude]];
    copy->PunchOutLongitude = nil;
    [copy setPunchOutLongitude:[self PunchOutLongitude]];
    copy->PunchOutTime = nil;
    [copy setPunchOutTime:[self PunchOutTime]];
    copy->activityName = nil;
    [copy setActivityName:[self activityName]];
    copy->activityUri=nil;
    [copy setActivityUri:[self activityUri]];
    copy->punchInAgent=nil;
    [copy setPunchInAgent:[self punchInAgent]];
    copy->punchInAgentUri=nil;
    [copy setPunchInAgentUri:[self punchInAgentUri]];
    copy->punchInCloudClockUri=nil;
    [copy setPunchInCloudClockUri:[self punchInCloudClockUri]];
    copy->punchInFullSizeImageLink=nil;
    [copy setPunchInFullSizeImageLink:[self punchInFullSizeImageLink]];
    copy->punchInFullSizeImageUri=nil;
    [copy setPunchInFullSizeImageUri:[self punchInFullSizeImageUri]];
    copy->punchInThumbnailSizeImageLink = nil;
    [copy setPunchInThumbnailSizeImageLink:[self punchInThumbnailSizeImageLink]];
    copy->punchInThumbnailSizeImageUri = nil;
    [copy setPunchInThumbnailSizeImageUri:[self punchInThumbnailSizeImageUri]];
    copy->punchInUri = nil;
    [copy setPunchInUri:[self punchInUri]];
    copy->punchOutAgent = nil;
    [copy setPunchOutAgent:[self punchOutAgent]];
    copy->punchOutAgentUri = nil;
    [copy setPunchOutAgentUri:[self punchOutAgentUri]];
    copy->punchOutCloudClockUri=nil;
    [copy setPunchOutCloudClockUri:[self punchOutCloudClockUri]];
    copy->punchOutFullSizeImageLink=nil;
    [copy setPunchOutFullSizeImageLink:[self punchOutFullSizeImageLink]];
    copy->punchOutFullSizeImageUri=nil;
    [copy setPunchOutFullSizeImageUri:[self punchOutFullSizeImageUri]];
    copy->punchOutThumbnailSizeImageLink=nil;
    [copy setPunchOutThumbnailSizeImageLink:[self punchOutThumbnailSizeImageLink]];
    copy->punchOutThumbnailSizeImageUri=nil;
    [copy setPunchOutThumbnailSizeImageUri:[self punchOutThumbnailSizeImageUri]];
    copy->punchOutUri=nil;
    [copy setPunchOutUri:[self punchOutUri]];
    copy->punchUserName = nil;
    [copy setPunchUserName:[self punchUserName]];
    copy->punchUserUri = nil;
    [copy setPunchUserUri:[self punchUserUri]];
    copy->totalHours = nil;
    [copy setTotalHours:[self totalHours]];
    copy->CellIdentifier = nil;
    [copy setCellIdentifier:[self CellIdentifier]];
    copy->breakName = nil;
    [copy setBreakName:[self breakName]];
    copy->breakUri=nil;
    [copy setBreakUri:[self breakUri]];
    copy->punchTransferredStatus=nil;
    [copy setPunchTransferredStatus:[self punchTransferredStatus]];
    copy->isBreakPunch=nil;
    [copy setIsBreakPunch:[self isBreakPunch]];
    copy->punchInAccuracyInMeters=nil;
    [copy setPunchInAccuracyInMeters:[self punchInAccuracyInMeters]];
    copy->punchOutAccuracyInMeters=nil;
    [copy setPunchOutAccuracyInMeters:[self punchOutAccuracyInMeters]];
    copy->isInManualEditPunch=nil;
    [copy setIsInManualEditPunch:[self isInManualEditPunch]];
    copy->isOutManualEditPunch=nil;
    [copy setIsOutManualEditPunch:[self isOutManualEditPunch]];
    copy->punchInActionUri=nil;
    [copy setPunchInActionUri:[self punchInActionUri]];
    copy->punchOutActionUri=nil;
    [copy setPunchOutActionUri:[self punchOutActionUri]];
   
    return copy;
}

@end
