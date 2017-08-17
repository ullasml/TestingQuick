//
//  TimeOffObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 1/27/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeOffObject : NSObject <NSCopying>
@property(nonatomic, strong) NSString *typeName;
@property(nonatomic, strong) NSString *typeIdentity;
@property(nonatomic, strong) NSString *comments;
@property(nonatomic, strong) NSString *identity;
@property(nonatomic, strong) NSString *sheetId;
@property(nonatomic, strong) NSString *numberOfHours;
@property(nonatomic, strong) NSString *entryType;
@property(nonatomic, strong) NSString *approvalStatus;
@property(nonatomic, strong) NSDate   *bookedStartDate;
@property(nonatomic, strong) NSDate   *bookedEndDate;
@property(nonatomic, strong) NSDate   *entryDate;

@property(nonatomic, strong) NSString *startDurationEntryType;
@property(nonatomic, strong) NSString *endDurationEntryType;
@property(nonatomic, strong) NSString *startNumberOfHours;
@property(nonatomic, strong) NSString *endNumberOfHours;
@property(nonatomic, strong) NSString *startTime;
@property(nonatomic, strong) NSString *endTime;
@property(nonatomic, strong) NSString *totalTimeOffDays;
@property(nonatomic, strong) NSString *resubmitComments;
@property(nonatomic, strong) NSString *timeOffDisplayFormatUri;
@property(nonatomic, strong) NSString *totalDurationHour;
@property(nonatomic, assign) BOOL canEdit;
@property(nonatomic, assign) BOOL isDeviceSupportedEntryConfiguration;
-(id) copyWithZone: (NSZone *) zone;
-(id)initWithDataDictionary:(NSDictionary *)timeOffDict;
@end
