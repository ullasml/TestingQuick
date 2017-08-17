//
//  InOutTimesheetEntry.h
//  InOutTest
//
//  Created by Abhi on 5/2/13.
//  Copyright (c) 2013 Aby Nimbalkar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InOutTimesheetEntry : NSObject

@property int startTime;
@property int endTime;
@property (nonatomic,assign) BOOL isMidnightCrossover;
@property (nonatomic,strong) NSString *hours;
@property (nonatomic,strong) NSString *crossoverHours;

-(NSString*) startTimeAsString;
-(NSString*) endTimeAsString;

-(int) numHours;
-(int) numMinutes;
-(NSString*) duration;
-(void)intializeWithStartAndEndTime;
-(void) resetEntry;

@end
