//
//  BookedTimeOffEntry.h
//  Replicon
//
//  Created by Swapna P on 7/14/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BookedTimeOffEntry : NSObject {
	NSString *typeName;
	NSString *typeIdentity;
	NSString *comments;
	NSString *sheetId;
	NSString *numberOfHours;
    NSString *entryType;
	NSString *approvalStatus;
	NSDate   *bookedStartDate;
	NSDate   *bookedEndDate;
	NSDate   *entryDate;
    NSString *startDurationEntryType;
    NSString *endDurationEntryType;
    NSString *startNumberOfHours;
    NSString *endNumberOfHours;
    NSString *startTime;
    NSString *endTime;
    NSString *totalTimeOffDays;
    NSString *resubmitComments;
}
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

@end
