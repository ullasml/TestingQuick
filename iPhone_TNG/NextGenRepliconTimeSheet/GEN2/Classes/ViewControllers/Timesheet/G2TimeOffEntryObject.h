//
//  TimeOffEntryObject.h
//  Replicon
//
//  Created by Swapna P on 5/19/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface G2TimeOffEntryObject : NSObject {
	NSString *timeOffCodeType;
	NSString *typeIdentity;
	NSDate   *timeOffDate;
	NSString *comments;
	NSString *identity;
	NSString *sheetId;
	NSString *numberOfHours;
	NSString *entryType;
    NSString *userID;
    BOOL	 isModified;
    NSMutableArray *udfArray;
    NSString *numberOfAlternativeHours;

}
@property(nonatomic, strong) NSMutableArray *udfArray;
@property(nonatomic, assign) BOOL	 isModified;
@property(nonatomic, strong) NSString *timeOffCodeType;
@property(nonatomic, strong) NSDate   *timeOffDate;
@property(nonatomic, strong) NSString *comments;
@property(nonatomic, strong) NSString *identity;
@property(nonatomic, strong) NSString *sheetId;
@property(nonatomic, strong) NSString *numberOfHours;
@property(nonatomic, strong) NSString *entryType;
@property(nonatomic, strong) NSString *typeIdentity;
@property(nonatomic, strong) NSString  *userID;
@property(nonatomic, strong) NSString  *numberOfAlternativeHours;

+(G2TimeOffEntryObject *)createObjectWithDefaultValues;

@end
