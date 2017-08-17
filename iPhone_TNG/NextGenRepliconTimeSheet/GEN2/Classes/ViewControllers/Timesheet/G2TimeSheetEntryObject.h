//
//  TimeSheetDetailsObject.h
//  Replicon
//
//  Created by Hepciba on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2Util.h"

#import "G2Client.h"
#import "G2Project.h"
#import "G2Activity.h"
#import "G2TaskObject.h"

@interface G2TimeSheetEntryObject : NSObject {
	//Unused members
	NSMutableArray *clientArray;
	NSMutableArray *projectArray;
	NSMutableArray *activityArray;
	/////////////////////////////
	
	NSString *numberOfHours;
	NSString *comments;
	NSString *sheetId;
	NSString *identity;
	NSString *clientIdentity;
	NSString *clientName;
	NSString *projectIdentity;
	NSString *projectName;
	NSNumber *projectRoleId;
	NSString *clientAllocationId;
    NSString *projectBillableStatus;
	
	//NSString *taskIdentity;
	//NSString *taskName;
	G2TaskObject *taskObj;
	
	
	NSString *billingIdentity;
	NSString *billingName;
	NSString *activityIdentity;
	NSString *activityName;
	NSDate	 *entryDate;
	NSString *entryType;
	NSString *timeOffType;
	BOOL	 isModified;
	BOOL	projectRemoved;
	
	NSString *clientProjectTask;
	NSString *timeDefaultValue;
	NSString *dateDefaultValue;
	NSString *billingDefaultValue;
	NSString *activityDefaultValue;

	NSMutableArray *missingFields;
	NSMutableArray *availableFields;
    
    NSMutableArray *rowUDFArray,*cellUDFArray;
    
    NSString *inTime,*outTime;
    
    double numberOfHoursInDouble;
    NSString                *userID;
    NSString *timeCodeType;
	NSString *typeIdentity;
}

+(G2TimeSheetEntryObject *)createObjectWithDefaultValues;
@property double numberOfHoursInDouble;
@property(nonatomic,strong) NSString *timeCodeType;
@property(nonatomic,strong) NSString *typeIdentity;
@property(nonatomic,strong) NSMutableArray *rowUDFArray,*cellUDFArray;
@property(nonatomic,strong) NSMutableArray *clientArray;
@property(nonatomic,strong) NSMutableArray *projectArray;
@property(nonatomic,strong) NSString                *userID;
@property(nonatomic,strong) NSMutableArray *activityArray;
@property(nonatomic,strong) NSString *numberOfHours;
@property(nonatomic,strong) NSString *comments;
@property(nonatomic,strong) NSString *sheetId;
@property(nonatomic,strong) NSString *identity;
@property(nonatomic,strong) NSString *clientIdentity;
@property(nonatomic,strong) NSString *clientName;
@property(nonatomic,strong) NSString *projectIdentity;
@property(nonatomic,strong) NSNumber *projectRoleId;
@property(nonatomic,strong) NSString *projectName;
@property(nonatomic,strong)	NSDate	 *entryDate;
//@property(nonatomic,retain) NSString *taskIdentity;
//@property(nonatomic,retain) NSString *taskName;
@property(nonatomic,strong) NSString *billingIdentity;
@property(nonatomic,strong) NSString *billingName;
@property(nonatomic,strong) NSString *activityIdentity;
@property(nonatomic,strong) NSString *activityName;
@property(nonatomic,strong) NSString *entryType;
@property(nonatomic,assign)	BOOL	 isModified;
@property(nonatomic,strong) NSString *timeDefaultValue;
@property(nonatomic,strong) NSString *dateDefaultValue;
@property(nonatomic,strong) NSString *billingDefaultValue;
@property(nonatomic,strong)	NSString *clientProjectTask;
@property(nonatomic,strong) NSMutableArray *missingFields;
@property(nonatomic,strong) NSMutableArray *availableFields;
@property(nonatomic,strong) G2TaskObject *taskObj;
@property(nonatomic,strong) NSString *clientAllocationId;
@property(nonatomic,assign) BOOL	projectRemoved;
@property(nonatomic,strong) NSString *inTime,*outTime;
@property(nonatomic,strong)NSString *projectBillableStatus;
@end
