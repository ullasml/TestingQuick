//
//  InOutTimesheetEntry.m
//  InOutTest
//
//  Created by Abhi on 5/2/13.
//  Copyright (c) 2013 Aby Nimbalkar. All rights reserved.
//

#import "InOutTimesheetEntry.h"

@implementation InOutTimesheetEntry
@synthesize isMidnightCrossover;
@synthesize hours;
@synthesize crossoverHours;

-(void)intializeWithStartAndEndTime
{
     _startTime = _endTime = -1;
    hours=[NSString stringWithFormat:@"0%@00",[Util detectDecimalMark]];
    crossoverHours=@"";
}
-(void) resetEntry
{
    _startTime = -1;
    _endTime = -1;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"In-Out Timesheet Entry. IN:%i, OUT:%i", _startTime, _endTime];
}

-(int) numHours {
    if(_startTime != -1 && _endTime != -1) return _endTime-_startTime;
    return 0;
}

-(int) numMinutes {
    if(_startTime != -1 && _endTime != -1) {
        return ((int)(_endTime/100)-(int)(_startTime/100))*60 + ((_endTime%100)-(_startTime%100));
    }
    return 0;
}

-(NSString*) duration {
    if(_startTime == -1 || _endTime == -1) return @"0:00";
    
    int diffInMins = ((int)(_endTime/100)-(int)(_startTime/100))*60 + ((_endTime%100)-(_startTime%100));
    int mins = diffInMins%60;
    return [NSString stringWithFormat:@"%i:%@", (int)(diffInMins/60), (mins<10 ? [NSString stringWithFormat:@"0%i", mins] : [NSString stringWithFormat:@"%i", mins])];
}


-(NSString*) startTimeAsString {
    if(_startTime == -1) return @"0000";
    return [self addLeadingZeros:_startTime];
}

-(NSString*) endTimeAsString {
    if(_endTime == -1) return @"0000";
    return [self addLeadingZeros:_endTime];
}

-(NSString*) addLeadingZeros:(int)toInt {
    NSString* res=@"";
    
    if(!toInt) res = @"";
    else if(toInt < 10) res = [NSString stringWithFormat:@"000%i", toInt];
    else if(toInt < 100) res = [NSString stringWithFormat:@"00%i", toInt];
    else if(toInt < 1000) res = [NSString stringWithFormat:@"0%i", toInt];
    
    return res;

}

@end
