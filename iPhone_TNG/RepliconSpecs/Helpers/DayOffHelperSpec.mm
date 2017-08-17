#import <Cedar/Cedar.h>
#import "DayOffHelper.h"
#import "JsonWrapper.h"
using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(DayOffHelperSpec)

describe(@"DayOffHelper", ^{
    context(@"When timesheetdaysoff dictionary is nil", ^{
        __block NSDictionary *timesheetdaysoffDict;
        beforeEach(^{
            timesheetdaysoffDict = nil;
        });
        
        it(@"should return nil", ^{
            NSArray *dayOffList = [DayOffHelper getDayOffListFrom:timesheetdaysoffDict];
            dayOffList should be_nil;
        });
    });
    
    context(@"When timesheetdaysoff dictionary has both holidays and non scheduled days", ^{
        __block NSDictionary *timesheetdaysoffDict;
        beforeEach(^{
            NSString *timesheetdaysoffstr = @"{\"nonScheduledDays\":[{\"day\":16,\"month\":4,\"year\":2017},{\"day\":22,\"month\":4,\"year\":2017}],\"holidays\":[{\"uri\":\"urn:replicon-tenant:repliconiphone-2:holiday:1960\",\"isHalfDay\":false,\"name\":\"Holiday\",\"date\":{\"day\":19,\"month\":4,\"year\":2017}}],\"timesheet\":{\"slug\":\".iwd/2017-4-16\",\"uri\":\"urn:replicon-tenant:repliconiphone-2:timesheet:92ca65fb-59dd-4075-a419-a553635b4629\",\"displayText\":\".iwd/2017-4-16\"}}";
            NSData *data = [timesheetdaysoffstr dataUsingEncoding:NSUTF8StringEncoding];
            timesheetdaysoffDict =(NSDictionary *) [JsonWrapper parseJson:data error: nil];
            
        });
        
        it(@"should return both holidays and non scheduled days", ^{
            NSArray *dayOffList = [DayOffHelper getDayOffListFrom:timesheetdaysoffDict];
            NSDate *date1 = [DateHelper getDateFromComponentDictionary:@{@"day":@(16),@"month":@(4),@"year":@(2017)}];
            NSDate *date2 = [DateHelper getDateFromComponentDictionary:@{@"day":@(22),@"month":@(4),@"year":@(2017)}];
            NSDate *date3 = [DateHelper getDateFromComponentDictionary:@{@"day":@(19),@"month":@(4),@"year":@(2017)}];
            
            dayOffList.count should equal(3);
            [DateHelper listOfDates:dayOffList contains:date1] should be_truthy;
            [DateHelper listOfDates:dayOffList contains:date2] should be_truthy;
            [DateHelper listOfDates:dayOffList contains:date3] should be_truthy;
        });
    });

    
    context(@"When timesheetdaysoff dictionary has no holidays but non scheduled days", ^{
        __block NSDictionary *timesheetdaysoffDict;
        beforeEach(^{
            NSString *timesheetdaysoffstr = @"{\"nonScheduledDays\":[{\"day\":16,\"month\":4,\"year\":2017},{\"day\":22,\"month\":4,\"year\":2017}],\"holidays\":[],\"timesheet\":{\"slug\":\".iwd/2017-4-16\",\"uri\":\"urn:replicon-tenant:repliconiphone-2:timesheet:92ca65fb-59dd-4075-a419-a553635b4629\",\"displayText\":\".iwd/2017-4-16\"}}";
            NSData *data = [timesheetdaysoffstr dataUsingEncoding:NSUTF8StringEncoding];
            timesheetdaysoffDict =(NSDictionary *) [JsonWrapper parseJson:data error: nil];
            
        });
        
        it(@"should return only non scheduled days", ^{
            NSArray *dayOffList = [DayOffHelper getDayOffListFrom:timesheetdaysoffDict];
            NSDate *date1 = [DateHelper getDateFromComponentDictionary:@{@"day":@(16),@"month":@(4),@"year":@(2017)}];
            NSDate *date2 = [DateHelper getDateFromComponentDictionary:@{@"day":@(22),@"month":@(4),@"year":@(2017)}];
            
            dayOffList.count should equal(2);
            [DateHelper listOfDates:dayOffList contains:date1] should be_truthy;
            [DateHelper listOfDates:dayOffList contains:date2] should be_truthy;
        });
    });
    
    context(@"When timesheetdaysoff dictionary has holidays but no non scheduled days", ^{
        __block NSDictionary *timesheetdaysoffDict;
        beforeEach(^{
            NSString *timesheetdaysoffstr = @"{\"nonScheduledDays\":[],\"holidays\":[{\"uri\":\"urn:replicon-tenant:repliconiphone-2:holiday:1960\",\"isHalfDay\":false,\"name\":\"Holiday\",\"date\":{\"day\":19,\"month\":4,\"year\":2017}}],\"timesheet\":{\"slug\":\".iwd/2017-4-16\",\"uri\":\"urn:replicon-tenant:repliconiphone-2:timesheet:92ca65fb-59dd-4075-a419-a553635b4629\",\"displayText\":\".iwd/2017-4-16\"}}";
            NSData *data = [timesheetdaysoffstr dataUsingEncoding:NSUTF8StringEncoding];
            timesheetdaysoffDict =(NSDictionary *) [JsonWrapper parseJson:data error: nil];
            
        });
        
        it(@"should return only holidays", ^{
            NSArray *dayOffList = [DayOffHelper getDayOffListFrom:timesheetdaysoffDict];
            NSDate *date1 = [DateHelper getDateFromComponentDictionary:@{@"day":@(19),@"month":@(4),@"year":@(2017)}];
            
            dayOffList.count should equal(1);
            [DateHelper listOfDates:dayOffList contains:date1] should be_truthy;
        });
    });
    
    context(@"When timesheetdaysoff dictionary has no holidays or non scheduled days", ^{
        __block NSDictionary *timesheetdaysoffDict;
        beforeEach(^{
            NSString *timesheetdaysoffstr = @"{\"nonScheduledDays\":[],\"holidays\":[],\"timesheet\":{\"slug\":\".iwd/2017-4-16\",\"uri\":\"urn:replicon-tenant:repliconiphone-2:timesheet:92ca65fb-59dd-4075-a419-a553635b4629\",\"displayText\":\".iwd/2017-4-16\"}}";
            NSData *data = [timesheetdaysoffstr dataUsingEncoding:NSUTF8StringEncoding];
            timesheetdaysoffDict =(NSDictionary *) [JsonWrapper parseJson:data error: nil];
            
        });
        
        it(@"should return empty", ^{
            NSArray *dayOffList = [DayOffHelper getDayOffListFrom:timesheetdaysoffDict];
            dayOffList.count should equal(0);
        });
    });
});

SPEC_END
