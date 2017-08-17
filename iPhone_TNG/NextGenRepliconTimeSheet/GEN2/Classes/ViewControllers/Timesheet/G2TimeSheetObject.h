//
//  TimeSheetObject.h
//  Replicon
//
//  Created by Hepciba on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface G2TimeSheetObject : NSObject {
	
	NSUInteger				timeSheetID;
	NSDate					*startDate;
	NSDate					*endDate;
	
	NSDate					*dueDate;
	
	NSMutableArray			*projects;
	NSMutableArray			*activities;
	NSString				*totalHrs;
	NSString				*status;
	NSMutableArray			*timeEntriesArray;
	NSString				*identity;
	BOOL					isModified;
	BOOL					approversRemaining;
    NSString                *userID;
    NSString                *userFirstName;
    NSString                *userLasttName;
    NSString                *timeSheetType;
    NSDate                  *effectiveDate;
    NSDate                  *disclaimerAccepted;
	
}

@property (nonatomic,strong)	NSDate		*startDate;
@property (nonatomic,strong)	NSDate		*endDate;
@property (nonatomic,strong)	NSDate		*dueDate;
@property (nonatomic,strong)	NSMutableArray			*projects;
@property (nonatomic,strong)	NSString		*totalHrs;
@property (nonatomic,strong)	NSString		*status;
@property (nonatomic,strong)	NSMutableArray	*timeEntriesArray;
@property (nonatomic,strong)	NSString       *identity;
@property (nonatomic,strong)    NSMutableArray *activities;
@property (nonatomic,assign)    BOOL			isModified;
@property (nonatomic,assign)	BOOL			approversRemaining;
@property (nonatomic,strong)	NSString                *userID;
@property (nonatomic,strong)	NSString                *userFirstName;
@property (nonatomic,strong)	NSString                *userLasttName;
 @property (nonatomic,strong)	NSString                *timeSheetType;
@property (nonatomic,strong)	NSDate                  *effectiveDate;
@property (nonatomic,strong)	NSDate                  *disclaimerAccepted;
@end
