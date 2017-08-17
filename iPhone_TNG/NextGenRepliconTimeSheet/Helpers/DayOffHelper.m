//
//  DayOffHelper.m
//  NextGenRepliconTimeSheet
//
//  Created by Prithiviraj Jayapal on 20/04/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

#import "DayOffHelper.h"

@implementation DayOffHelper

+(NSArray *)getDayOffListFrom:(NSDictionary *)timesheetdaysoff{
    if(timesheetdaysoff.count > 0){
        NSArray *nonScheduledDays = timesheetdaysoff[@"nonScheduledDays"];
        NSArray *holidays = timesheetdaysoff[@"holidays"];
        
        NSMutableArray *dayOffList = [NSMutableArray new];
        for (NSDictionary *componentDict in nonScheduledDays){
            NSDate *date = [DateHelper getDateFromComponentDictionary:componentDict];
            
            if(date){
                [dayOffList addObject:date];
            }
        }
        
        for (NSDictionary *holidayDict in holidays){
            NSDictionary *componentDict = holidayDict[@"date"];
            NSDate *date = [DateHelper getDateFromComponentDictionary:componentDict];
            if(date && ![dayOffList containsObject:date]){
                [dayOffList addObject:date];
            }
        }
        
        return dayOffList;
    }
    return nil;
}

@end
