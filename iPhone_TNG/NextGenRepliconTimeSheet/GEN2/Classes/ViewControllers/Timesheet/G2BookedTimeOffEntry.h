//
//  BookedTimeOffEntry.h
//  Replicon
//
//  Created by Swapna P on 7/14/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface G2BookedTimeOffEntry : NSObject {
	NSString *typeName;
	NSString *typeIdentity;
	NSString *comments;
	NSString *identity;
	NSString *sheetId;
	NSString *numberOfHours;
	NSString *entryType;
	NSString *approvalStatus;
	NSDate   *bookedStartDate;
	NSDate   *bookedEndDate;
	NSDate   *entryDate;
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

@end
