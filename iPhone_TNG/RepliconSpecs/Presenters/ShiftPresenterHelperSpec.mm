#import <Cedar/Cedar.h>
#import "RepliconSpecHelper.h"
#import <Blindside/BlindSide.h>
#import "InjectorProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ShiftPresenterHelperSpec)

describe(@"ShiftPresenterHelper", ^{
    __block ShiftPresenterHelper *subject;
    __block id<BSInjector, BSBinder> injector;
    __block id<Theme> theme;
    
    __block UIColor *approvedColor;
    __block UIColor *rejectedColor;
    __block UIColor *waitingForApprovalColor;
    
    
    beforeEach(^{
        injector = [InjectorProvider injector];
        
        theme = nice_fake_for(@protocol(Theme));
        
        approvedColor = [UIColor greenColor];
        rejectedColor = [UIColor redColor];
        waitingForApprovalColor = [UIColor orangeColor];
        
        theme stub_method(@selector(approvedColor)).and_return(approvedColor);
        theme stub_method(@selector(rejectedColor)).and_return(rejectedColor);
        theme stub_method(@selector(waitingForApprovalColor)).and_return(waitingForApprovalColor);
 
        [injector bind:@protocol(Theme) toInstance:theme];
        
        
        subject = [injector getInstance:[ShiftPresenterHelper class]];
        
    });
    
    
    
    describe(@"Time Off Waiting for approval", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *timeOffInfo = @{@"color":[NSNull null],
                                          @"date":@"1500940800",
                                          @"endTime":[NSNull null],
                                          @"holiday":[NSNull null],
                                          @"id":@"ab068a6ef4c54a99a6cbaea6b3ddcd77",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":@"Waiting for Approval",
                                          @"timeOffDayDuration":@"0.125",
                                          @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                          @"timeOffHourDuration":@"1.00",
                                          @"timeOffName":@"Vacation_Hours",
                                          @"type":@"TimeOff",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:time-off:20354"};
            
            testItemPresenter = [subject createTimeOffItemPresenterWithDataDict:timeOffInfo timeOffNameKey:@"timeOffName" approvalStatusKey:@"timeOffApprovalStatus"];
            
        });
        it(@"Cell Identifier should be correct", ^{
            testItemPresenter.cellReuseIdentifier should equal(@"ShiftScheduleTimeOffCell");
            
        });
        
        it(@"Time Off status Info should be correct", ^{
            TimeOffApprovalStatusInfo *approvalInfo = [testItemPresenter timeOffStatusColorAndText];
            approvalInfo.statusText should equal(@"Waiting for Approval");
            approvalInfo.statusColor should equal(waitingForApprovalColor);
            approvalInfo.statusImageName should equal(@"waiting-for-approval");
        });
    });
    
    describe(@"Time Off Rejected", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *timeOffInfo = @{@"color":[NSNull null],
                                          @"date":@"1500940800",
                                          @"endTime":[NSNull null],
                                          @"holiday":[NSNull null],
                                          @"id":@"ab068a6ef4c54a99a6cbaea6b3ddcd77",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":@"Rejected",
                                          @"timeOffDayDuration":@"0.125",
                                          @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                          @"timeOffHourDuration":@"1.00",
                                          @"timeOffName":@"Vacation_Hours",
                                          @"type":@"TimeOff",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:time-off:20354"};
            
            testItemPresenter = [subject createTimeOffItemPresenterWithDataDict:timeOffInfo timeOffNameKey:@"timeOffName" approvalStatusKey:@"timeOffApprovalStatus"];
            
        });
        it(@"Cell Identifier should be correct", ^{
            testItemPresenter.cellReuseIdentifier should equal(@"ShiftScheduleTimeOffCell");
            
        });
        
        it(@"Time Off status Info should be correct", ^{
            TimeOffApprovalStatusInfo *approvalInfo = [testItemPresenter timeOffStatusColorAndText];
            approvalInfo.statusText should equal(@"Rejected");
            approvalInfo.statusColor should equal(rejectedColor);
            approvalInfo.statusImageName should equal(@"rejected");
        });
    });
    
    describe(@"Time Off Approved", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *timeOffInfo = @{@"color":[NSNull null],
                                          @"date":@"1500940800",
                                          @"endTime":[NSNull null],
                                          @"holiday":[NSNull null],
                                          @"id":@"ab068a6ef4c54a99a6cbaea6b3ddcd77",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":@"Approved",
                                          @"timeOffDayDuration":@"0.125",
                                          @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                          @"timeOffHourDuration":@"1.00",
                                          @"timeOffName":@"Vacation_Hours",
                                          @"type":@"TimeOff",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:time-off:20354"};
            
            testItemPresenter = [subject createTimeOffItemPresenterWithDataDict:timeOffInfo timeOffNameKey:@"timeOffName" approvalStatusKey:@"timeOffApprovalStatus"];
            
        });
        
        it(@"Time Off status Info should be correct", ^{
            TimeOffApprovalStatusInfo *approvalInfo = [testItemPresenter timeOffStatusColorAndText];
            approvalInfo.statusText should equal(@"Approved");
            approvalInfo.statusColor should equal(approvedColor);
            approvalInfo.statusImageName should equal(@"approved");
        });
    });
    
    
    describe(@"holiday data", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Holiday data dictionary
            NSDictionary *holidayInfo = @{@"color":[NSNull null],
                                          @"date":@"1501200000",
                                          @"endTime":[NSNull null],
                                          @"holiday":@"TestHoliday",
                                          @"id":@"ab068a6ef4c54a99a6cbaea6b3ddcd77",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":[NSNull null],
                                          @"timeOffDayDuration":[NSNull null],
                                          @"timeOffDisplayFormatUri":[NSNull null],
                                          @"timeOffHourDuration":[NSNull null],
                                          @"timeOffName":[NSNull null],
                                          @"type":@"Holiday",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:holiday:2540"};
            
            testItemPresenter = [subject createHolidayItemPresenterWithDataDict: holidayInfo];
            
        });
        it(@"Cell Identifier should be correct", ^{
            testItemPresenter.cellReuseIdentifier should equal(@"ShiftScheduleHolidayCell");
            
        });
        it(@"Shift item data should have been proper", ^{
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            [shiftItemPresenter setupWithCellType:ShiftCellTypeHoliday
                             shiftDescriptionText: nil
                      shiftDetailsDescriptionText: nil
                                            notes:nil
                                    shiftColorHex:nil
                                          udfName:nil
                                         udfValue:nil
                                  timeOffDescText:nil
                                    timeOffStatus:nil
                           holidayDescriptionText:@"TestHoliday"];
            
            testItemPresenter should equal(shiftItemPresenter);
            
        });
        
    });
    
    describe(@"Time Off (more than one hours) data", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *timeOffInfo = @{@"color":[NSNull null],
                                          @"date":@"1500940800",
                                          @"endTime":[NSNull null],
                                          @"holiday":[NSNull null],
                                          @"id":@"ab068a6ef4c54a99a6cbaea6b3ddcd77",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":@"Waiting for Approval",
                                          @"timeOffDayDuration":@"0.5",
                                          @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                          @"timeOffHourDuration":@"4.625000000000001",
                                          @"timeOffName":@"Vacation_Hours",
                                          @"type":@"TimeOff",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:time-off:20354"};
            
            testItemPresenter = [subject createTimeOffItemPresenterWithDataDict:timeOffInfo timeOffNameKey:@"timeOffName" approvalStatusKey:@"timeOffApprovalStatus"];
            
        });
        
        it(@"Shift item data should have been proper", ^{
            
            ShiftItemPresenter *shiftItemPresenter =   [[ShiftItemPresenter alloc] initWithTheme: theme];
            [shiftItemPresenter setupWithCellType:ShiftCellTypeTimeOff
                             shiftDescriptionText: nil
                      shiftDetailsDescriptionText: nil
                                            notes: nil
                                    shiftColorHex: nil
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: @"Vacation_Hours : 4.63 hours"
                                    timeOffStatus: @"Waiting for Approval"
                           holidayDescriptionText: nil];
            
            testItemPresenter should equal(shiftItemPresenter);
            
        });
        
    });
    
    
    describe(@"Time Off (less than one hour) data", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *timeOffInfo = @{@"color":[NSNull null],
                                          @"date":@"1500940800",
                                          @"endTime":[NSNull null],
                                          @"holiday":[NSNull null],
                                          @"id":@"ab068a6ef4c54a99a6cbaea6b3ddcd77",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":@"Waiting for Approval",
                                          @"timeOffDayDuration":@"0.08",
                                          @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                          @"timeOffHourDuration":@"0.625000000000001",
                                          @"timeOffName":@"Vacation_Hours",
                                          @"type":@"TimeOff",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:time-off:20354"};
            
            testItemPresenter = [subject createTimeOffItemPresenterWithDataDict:timeOffInfo timeOffNameKey:@"timeOffName" approvalStatusKey:@"timeOffApprovalStatus"];
            
        });
        
        it(@"The presenter structure should be proper", ^{
            
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            [shiftItemPresenter setupWithCellType:ShiftCellTypeTimeOff
                             shiftDescriptionText: nil
                      shiftDetailsDescriptionText: nil
                                            notes: nil
                                    shiftColorHex: nil
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: @"Vacation_Hours : 0.63 hours"
                                    timeOffStatus: @"Waiting for Approval"
                           holidayDescriptionText: nil];
            
            testItemPresenter should equal(shiftItemPresenter);
            
        });
    });
    
    describe(@"Time Off (exactly one hour) data", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *timeOffInfo = @{@"color":[NSNull null],
                                          @"date":@"1500940800",
                                          @"endTime":[NSNull null],
                                          @"holiday":[NSNull null],
                                          @"id":@"ab068a6ef4c54a99a6cbaea6b3ddcd77",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":@"Waiting for Approval",
                                          @"timeOffDayDuration":@"0.125",
                                          @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                          @"timeOffHourDuration":@"1.00",
                                          @"timeOffName":@"Vacation_Hours",
                                          @"type":@"TimeOff",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:time-off:20354"};
            
            testItemPresenter = [subject createTimeOffItemPresenterWithDataDict:timeOffInfo timeOffNameKey:@"timeOffName" approvalStatusKey:@"timeOffApprovalStatus"];
            
        });
        
        it(@"Time Off desc text should be correct", ^{
            testItemPresenter.timeOffDescText should equal(@"Vacation_Hours : 1.00 hour");
        });
    });
    
    describe(@"Time Off hours (All Day) data", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *timeOffInfo = @{@"color":[NSNull null],
                                          @"date":@"1500940800",
                                          @"endTime":[NSNull null],
                                          @"holiday":[NSNull null],
                                          @"id":@"ab068a6ef4c54a99a6cbaea6b3ddcd77",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":@"Waiting for Approval",
                                          @"timeOffDayDuration":@"All Day",
                                          @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                          @"timeOffHourDuration":@"8.00",
                                          @"timeOffName":@"Vacation_Hours",
                                          @"type":@"TimeOff",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:time-off:20354"};
            
            testItemPresenter = [subject createTimeOffItemPresenterWithDataDict:timeOffInfo timeOffNameKey:@"timeOffName" approvalStatusKey:@"timeOffApprovalStatus"];
            
        });
        
        it(@"Time Off desc text should be correct", ^{
            testItemPresenter.timeOffDescText should equal(@"Vacation_Hours : All Day");
        });
    });
    
    describe(@"Time Off days data", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *timeOffInfo = @{@"color":[NSNull null],
                                          @"date":@"1502755200",
                                          @"endTime":[NSNull null],
                                          @"holiday":[NSNull null],
                                          @"id":@"f3774d77a4944e4ab1d4f4b86432360d",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":@"Waiting for Approval",
                                          @"timeOffDayDuration":@"0.891891891891892",
                                          @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:work-days",
                                          @"timeOffHourDuration":@"8.25",
                                          @"timeOffName":@"Holiday_Days",
                                          @"type":@"TimeOff",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:time-off:20394"};
            
            
             testItemPresenter = [subject createTimeOffItemPresenterWithDataDict:timeOffInfo timeOffNameKey:@"timeOffName" approvalStatusKey:@"timeOffApprovalStatus"];
            
        });
        
        it(@"The presenter structure should be proper", ^{
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            [shiftItemPresenter setupWithCellType:ShiftCellTypeTimeOff
                             shiftDescriptionText: nil
                      shiftDetailsDescriptionText: nil
                                            notes: nil
                                    shiftColorHex: nil
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: @"Holiday_Days : 0.89 days"
                                    timeOffStatus: @"Waiting for Approval"
                           holidayDescriptionText: nil];
      
            testItemPresenter should equal(shiftItemPresenter);
            
        });
        
    });
    
    describe(@"Time Off day ( one day ) data", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *timeOffInfo = @{@"color":[NSNull null],
                                          @"date":@"1502755200",
                                          @"endTime":[NSNull null],
                                          @"holiday":[NSNull null],
                                          @"id":@"f3774d77a4944e4ab1d4f4b86432360d",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":@"Waiting for Approval",
                                          @"timeOffDayDuration":@"1.00",
                                          @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:work-days",
                                          @"timeOffHourDuration":@"9.00",
                                          @"timeOffName":@"Holiday_Days",
                                          @"type":@"TimeOff",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:time-off:20394"};
            
              testItemPresenter = [subject createTimeOffItemPresenterWithDataDict:timeOffInfo timeOffNameKey:@"timeOffName" approvalStatusKey:@"timeOffApprovalStatus"];
            
        });
        
        
        it(@"Cell Identifier should be correct", ^{
            testItemPresenter.cellReuseIdentifier should equal(@"ShiftScheduleTimeOffCell");
            
        });
        
        it(@"The presenter structure should be proper", ^{
            
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            [shiftItemPresenter setupWithCellType:ShiftCellTypeTimeOff
                             shiftDescriptionText: nil
                      shiftDetailsDescriptionText: nil
                                            notes: nil
                                    shiftColorHex: nil
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: @"Holiday_Days : 1.00 day"
                                    timeOffStatus: @"Waiting for Approval"
                           holidayDescriptionText: nil];
            
            testItemPresenter should equal(shiftItemPresenter);
            
        });
        
    });
    
    describe(@"Time Off day ( one day ) data", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *timeOffInfo = @{@"color":[NSNull null],
                                          @"date":@"1502755200",
                                          @"endTime":[NSNull null],
                                          @"holiday":[NSNull null],
                                          @"id":@"f3774d77a4944e4ab1d4f4b86432360d",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":@"Waiting for Approval",
                                          @"timeOffDayDuration":@"1.00",
                                          @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:work-days",
                                          @"timeOffHourDuration":@"9.00",
                                          @"timeOffName":@"Holiday_Days",
                                          @"type":@"TimeOff",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:time-off:20394"};
            
            testItemPresenter = [subject createTimeOffItemPresenterWithDataDict:timeOffInfo timeOffNameKey:@"timeOffName" approvalStatusKey:@"timeOffApprovalStatus"];
            
        });
        
        it(@"The presenter structure should be proper", ^{
            
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            [shiftItemPresenter setupWithCellType:ShiftCellTypeTimeOff
                             shiftDescriptionText: nil
                      shiftDetailsDescriptionText: nil
                                            notes: nil
                                    shiftColorHex: nil
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: @"Holiday_Days : 1.00 day"
                                    timeOffStatus: @"Waiting for Approval"
                           holidayDescriptionText: nil];
            
            testItemPresenter should equal(shiftItemPresenter);
            
        });
        
    });
    
    describe(@"Time Off day ( All day ) data", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *timeOffInfo = @{@"color":[NSNull null],
                                          @"date":@"1502755200",
                                          @"endTime":[NSNull null],
                                          @"holiday":[NSNull null],
                                          @"id":@"f3774d77a4944e4ab1d4f4b86432360d",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":@"Waiting for Approval",
                                          @"timeOffDayDuration":@"All Day",
                                          @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:work-days",
                                          @"timeOffHourDuration":@"9.00",
                                          @"timeOffName":@"Holiday_Days",
                                          @"type":@"TimeOff",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:time-off:20394"};
            
            testItemPresenter = [subject createTimeOffItemPresenterWithDataDict:timeOffInfo timeOffNameKey:@"timeOffName" approvalStatusKey:@"timeOffApprovalStatus"];
            
        });
        
        it(@"The presenter structure should be proper", ^{
            
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            [shiftItemPresenter setupWithCellType:ShiftCellTypeTimeOff
                             shiftDescriptionText: nil
                      shiftDetailsDescriptionText: nil
                                            notes: nil
                                    shiftColorHex: nil
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: @"Holiday_Days : All Day"
                                    timeOffStatus: @"Waiting for Approval"
                           holidayDescriptionText: nil];
            
            testItemPresenter should equal(shiftItemPresenter);
            
        });
        
    });
    
    describe(@"Data dictionary corrent but the key passed are not correct", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *timeOffInfo = @{@"color":[NSNull null],
                                          @"date":@"1502755200",
                                          @"endTime":[NSNull null],
                                          @"holiday":[NSNull null],
                                          @"id":@"f3774d77a4944e4ab1d4f4b86432360d",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":@"Waiting for Approval",
                                          @"timeOffDayDuration":@"All Day",
                                          @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:work-days",
                                          @"timeOffHourDuration":@"9.00",
                                          @"timeOffName":@"Holiday_Days",
                                          @"type":@"TimeOff",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:time-off:20394"};
            
            testItemPresenter = [subject createTimeOffItemPresenterWithDataDict:timeOffInfo timeOffNameKey:@"timeOffName123" approvalStatusKey:@"timeOffApprovalStatus234"];
            
        });
        it(@"presenter should not contain timeOffDesc", ^{
            testItemPresenter.timeOffDescText should equal(nil);
        });
        it(@"presenter should not contain timeOff approval status", ^{
            testItemPresenter.timeOffStatus should equal(nil);
        });
        
    });
    
    describe(@"Data dictionary corrent but the key passed are empty", ^{
        __block ShiftItemPresenter *testItemPresenter;
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *timeOffInfo = @{@"color":[NSNull null],
                                          @"date":@"1502755200",
                                          @"endTime":[NSNull null],
                                          @"holiday":[NSNull null],
                                          @"id":@"f3774d77a4944e4ab1d4f4b86432360d",
                                          @"in_time_stamp":[NSNull null],
                                          @"note":[NSNull null],
                                          @"out_time_stamp":[NSNull null],
                                          @"shiftDuration":[NSNull null],
                                          @"shiftName":[NSNull null],
                                          @"startTime":[NSNull null],
                                          @"timeOffApprovalStatus":@"Waiting for Approval",
                                          @"timeOffDayDuration":@"All Day",
                                          @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:work-days",
                                          @"timeOffHourDuration":@"9.00",
                                          @"timeOffName":@"Holiday_Days",
                                          @"type":@"TimeOff",
                                          @"uri":@"urn:replicon-tenant:repliconiphone-2:time-off:20394"};
            
            testItemPresenter = [subject createTimeOffItemPresenterWithDataDict:timeOffInfo timeOffNameKey:@"" approvalStatusKey:@""];
            
        });
        it(@"presenter should not contain timeOffDesc", ^{
            testItemPresenter.timeOffDescText should equal(nil);
        });
        it(@"presenter should not contain timeOff approval status", ^{
            testItemPresenter.timeOffStatus should equal(nil);
        });
        
    });
    
    
});

SPEC_END
