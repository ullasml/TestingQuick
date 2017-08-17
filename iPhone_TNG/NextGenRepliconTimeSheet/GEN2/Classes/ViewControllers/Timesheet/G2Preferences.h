//
//  Preferences.h
//  Replicon
//
//  Created by Swapna P on 6/2/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface G2Preferences : NSObject {
	NSString *hourFormat;
	BOOL     activitiesEnabled;
	BOOL	 useBillingInfo;
	NSString *timeSheetType;
	NSString *dateformat;

}
@property (nonatomic, strong) NSString *hourFormat;
@property (nonatomic, assign) BOOL     activitiesEnabled;
@property (nonatomic, assign) BOOL	   useBillingInfo;
@property (nonatomic, strong) NSString *timeSheetType;
@property (nonatomic, strong) NSString *dateformat;
@end
