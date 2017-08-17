#import <Cedar/Cedar.h>
#import "RepliconSpecHelper.h"
#import <Blindside/BlindSide.h>
#import "InjectorProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ShiftSummaryPresenterSpec)

describe(@"ShiftSummaryPresenter", ^{
    __block ShiftSummaryPresenter *subject;
    __block id<BSInjector, BSBinder> injector;
    __block id<Theme> theme;
    
    __block NSArray *presenters;
    
    
    beforeEach(^{
        
        injector = [InjectorProvider injector];
        
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        subject = [injector getInstance:[ShiftSummaryPresenter class]];

    });
    
    describe(@"shift data", ^{
        
        beforeEach(^{
            // create the shift data dictionary
            NSDictionary *shiftInfo = @{@"color":@"F07373",
                                        @"date":@"1502064000",
                                        @"endTime":@"6:15 PM",
                                        @"holiday":[NSNull null],
                                        @"id":@"3d00e0703d134c3f90e51aeadb1d6475",
                                        @"in_time_stamp":@"1502076600",
                                        @"note":[NSNull null],
                                        @"out_time_stamp":@"1502109900",
                                        @"shiftDuration":@" 9:00 AM - 6:15 PM ",
                                        @"shiftName":@"Day shift",
                                        @"startTime":@"9:00 AM",
                                        @"timeOffApprovalStatus":[NSNull null],
                                        @"timeOffDayDuration":[NSNull null],
                                        @"timeOffDisplayFormatUri":[NSNull null],
                                        @"timeOffHourDuration":[NSNull null],
                                        @"timeOffName":[NSNull null],
                                        @"type":@"Shifts",
                                        @"uri":@"urn:replicon-tenant:repliconiphone-2:shift:919bb35b-b3f1-41fc-94aa-4467ad8b395b"};
            
            NSArray *shiftData = @[shiftInfo];
            
            NSString *shiftDay = @"Monday, Aug 07, 2017";
            
            NSDictionary *shiftDataDict = @{@"shiftDay" : shiftDay,
                                            @"ShiftEntry" : shiftData };
            
            presenters = [subject shiftItemPresenterSectionsForShiftDataList:@[shiftDataDict]];
            
        });
        
        it(@"Presenter should contain a section presenter", ^{
            presenters.count should equal(1);
        });
        it(@"Section should scontain one item", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(1);
        });

        
        it(@"Cell Identifier should be correct", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters[0].cellReuseIdentifier should equal(@"ShiftScheduleCell");
            
        });
        
        it(@"The presenter structure should be proper", ^{
            ShiftItemPresenter *shiftItemPresenter = [[ShiftItemPresenter alloc] initWithTheme: theme];
            [shiftItemPresenter setupWithCellType:ShiftCellTypeShiftInfo
                             shiftDescriptionText: @"Day shift -  9:00 AM to 6:15 PM "
                      shiftDetailsDescriptionText: nil
                                            notes:nil
                                    shiftColorHex:@"#F07373"
                                          udfName:nil
                                         udfValue:nil
                                  timeOffDescText:nil
                                    timeOffStatus:nil
                           holidayDescriptionText:nil];
            
            ShiftItemsSectionPresenter *sectionPresenter = [[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:@"Monday, Aug 07, 2017"
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter]];
            
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
        
    });
    
    
    describe(@"holiday data", ^{
        
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
            
            NSArray *shiftData = @[holidayInfo];
            
            NSString *shiftDay = @"Friday, Jul 28, 2017";
            
            NSDictionary *shiftDataDict = @{@"shiftDay" : shiftDay,
                                            @"ShiftEntry" : shiftData };
            
            presenters = [subject shiftItemPresenterSectionsForShiftDataList:@[shiftDataDict]];
            
        });
        
        it(@"Presenter should contain a section presenter", ^{
            
            presenters.count should equal(1);
            
        });
        
        it(@"The presenter structure should be proper", ^{
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
           
            
            
            ShiftItemsSectionPresenter *sectionPresenter = [[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:@"Friday, Jul 28, 2017"
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter]];
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
        
    });
    
    
    describe(@"Time Off (more than one hours) data", ^{
        
        
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
            
            NSArray *shiftData = @[timeOffInfo];
            
            NSString *shiftDay = @"Tuesday, Jul 25, 2017";
            
            NSDictionary *shiftDataDict = @{@"shiftDay" : shiftDay,
                                            @"ShiftEntry" : shiftData };
            
            presenters = [subject shiftItemPresenterSectionsForShiftDataList:@[shiftDataDict]];
            
        });
        it(@"One section should be there", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 1 rows", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(1);
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
                                  timeOffDescText: @"Vacation_Hours : 4.63 hours"
                                    timeOffStatus: @"Waiting for Approval"
                           holidayDescriptionText: nil];
            
            
            
            ShiftItemsSectionPresenter *sectionPresenter = [[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:@"Tuesday, Jul 25, 2017"
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter]];
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
        
    });
    
    describe(@"Time Off (less than one hour) data", ^{
        
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
            
            NSArray *shiftData = @[timeOffInfo];
            
            NSString *shiftDay = @"Tuesday, Jul 25, 2017";
            
            NSDictionary *shiftDataDict = @{@"shiftDay" : shiftDay,
                                            @"ShiftEntry" : shiftData };
            
            presenters = [subject shiftItemPresenterSectionsForShiftDataList:@[shiftDataDict]];
            
            
        });
        it(@"One section should be there", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 1 rows", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(1);
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
            
            
            
            ShiftItemsSectionPresenter *sectionPresenter = [[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:@"Tuesday, Jul 25, 2017"
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter]];
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
        
        
        
    });
    
    describe(@"Time Off (exactly one hour) data", ^{
        
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
            
            NSArray *shiftData = @[timeOffInfo];
            
            NSString *shiftDay = @"Tuesday, Jul 25, 2017";
            
            NSDictionary *shiftDataDict = @{@"shiftDay" : shiftDay,
                                            @"ShiftEntry" : shiftData };
            
            presenters = [subject shiftItemPresenterSectionsForShiftDataList:@[shiftDataDict]];
            
        });
        it(@"One section should be there", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 1 rows", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(1);
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
                                  timeOffDescText: @"Vacation_Hours : 1.00 hour"
                                    timeOffStatus: @"Waiting for Approval"
                           holidayDescriptionText: nil];
            
            
            ShiftItemsSectionPresenter *sectionPresenter = [[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:@"Tuesday, Jul 25, 2017"
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter]];
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
        
    });
    
    describe(@"Time Off hours (All Day) data", ^{
        
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
            
            NSArray *shiftData = @[timeOffInfo];
            
            NSString *shiftDay = @"Tuesday, Jul 25, 2017";
            
            NSDictionary *shiftDataDict = @{@"shiftDay" : shiftDay,
                                            @"ShiftEntry" : shiftData };
            
            presenters = [subject shiftItemPresenterSectionsForShiftDataList:@[shiftDataDict]];
            
        });
        it(@"One section should be there", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 1 rows", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(1);
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
                                  timeOffDescText: @"Vacation_Hours : All Day"
                                    timeOffStatus: @"Waiting for Approval"
                           holidayDescriptionText: nil];
            
            
            ShiftItemsSectionPresenter *sectionPresenter = [[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:@"Tuesday, Jul 25, 2017"
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter]];
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
        
    });
    
    
    describe(@"Time Off days data", ^{
        
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
            
            
            NSString *shiftDay = @"Tuesday, Aug 15, 2017";
            NSArray *shiftData = @[timeOffInfo];
            
            NSDictionary *shiftDataDict = @{@"shiftDay" : shiftDay,
                                            @"ShiftEntry" : shiftData };
            
            presenters = [subject shiftItemPresenterSectionsForShiftDataList:@[shiftDataDict]];
            
        });
        it(@"One section should be there", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 1 rows", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(1);
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
            
            
            ShiftItemsSectionPresenter *sectionPresenter = [[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:@"Tuesday, Aug 15, 2017"
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter]];
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
        
    });
    
    describe(@"Time Off day ( one day ) data", ^{
        
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
            
            
            NSString *shiftDay = @"Tuesday, Aug 15, 2017";
            NSArray *shiftData = @[timeOffInfo];
            
            NSDictionary *shiftDataDict = @{@"shiftDay" : shiftDay,
                                            @"ShiftEntry" : shiftData };
            
            presenters = [subject shiftItemPresenterSectionsForShiftDataList:@[shiftDataDict]];
            
        });
        it(@"One section should be there", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 1 rows", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(1);
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
            
            
            ShiftItemsSectionPresenter *sectionPresenter = [[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:@"Tuesday, Aug 15, 2017"
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter]];
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
        
    });
    
    describe(@"Time Off day ( All day ) data", ^{
        
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
            
            NSString *shiftDay = @"Tuesday, Aug 15, 2017";
            NSArray *shiftData = @[timeOffInfo];
            
            NSDictionary *shiftDataDict = @{@"shiftDay" : shiftDay,
                                            @"ShiftEntry" : shiftData };
            
            presenters = [subject shiftItemPresenterSectionsForShiftDataList:@[shiftDataDict]];
            
        });
        it(@"One section should be there", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 1 rows", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(1);
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
            
            
            ShiftItemsSectionPresenter *sectionPresenter = [[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:@"Tuesday, Aug 15, 2017"
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter]];
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
            
        });
        
    });
    
    describe(@"Multiple (Shift and TimeOff) rows data", ^{
        
        
        beforeEach(^{
            // create the Time Off data dictionary
            NSDictionary *row1Info = @{@"color":[NSNull null],
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
            
            
            // create the Shift data dictionary
            NSDictionary *row2Info = @{@"color":@"F07373",
                                       @"date":@"1502064000",
                                       @"endTime":@"6:15 PM",
                                       @"holiday":[NSNull null],
                                       @"id":@"3d00e0703d134c3f90e51aeadb1d6475",
                                       @"in_time_stamp":@"1502076600",
                                       @"note":@"Notes added by supervisor",
                                       @"out_time_stamp":@"1502109900",
                                       @"shiftDuration":@" 1:00 PM - 6:15 PM ",
                                       @"shiftName":@"Day shift",
                                       @"startTime":@"1:00 PM",
                                       @"timeOffApprovalStatus":[NSNull null],
                                       @"timeOffDayDuration":[NSNull null],
                                       @"timeOffDisplayFormatUri":[NSNull null],
                                       @"timeOffHourDuration":[NSNull null],
                                       @"timeOffName":[NSNull null],
                                       @"type":@"Shifts",
                                       @"uri":@"urn:replicon-tenant:repliconiphone-2:shift:919bb35b-b3f1-41fc-94aa-4467ad8b395b"};
            
            NSArray *shiftData = @[row1Info,row2Info];
            
            NSString *shiftDay = @"Tuesday, Aug 16, 2017";
            
            NSDictionary *shiftDataDict = @{@"shiftDay" : shiftDay,
                                            @"ShiftEntry" : shiftData };
            
            presenters = [subject shiftItemPresenterSectionsForShiftDataList:@[shiftDataDict]];
            
        });
        
        it(@"The presenter structure should be proper", ^{
            ShiftItemPresenter *timeOffPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            [timeOffPresenter setupWithCellType:ShiftCellTypeTimeOff
                           shiftDescriptionText: nil
                    shiftDetailsDescriptionText: nil
                                          notes: nil
                                  shiftColorHex: nil
                                        udfName: nil
                                       udfValue: nil
                                timeOffDescText: @"Vacation_Hours : 4.63 hours"
                                  timeOffStatus: @"Waiting for Approval"
                         holidayDescriptionText: nil];
            
            
            
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            [shiftItemPresenter setupWithCellType:ShiftCellTypeShiftInfo
                             shiftDescriptionText: @"Day shift -  1:00 PM to 6:15 PM "
                      shiftDetailsDescriptionText: nil
                                            notes: @"Notes added by supervisor"
                                    shiftColorHex: @"#F07373"
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: nil
                                    timeOffStatus: nil
                           holidayDescriptionText: nil];
            
            ShiftItemsSectionPresenter *sectionPresenter = [[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:@"Tuesday, Aug 16, 2017"
                                            subText:nil
                                shiftItemPresenters:@[timeOffPresenter, shiftItemPresenter]];
            
            
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
        
        it(@"Should contain 1 section with 2 item", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            
            testSectionPresenter.shiftItemPresenters.count should equal(2);
        });
        
    });
    
    describe(@"No shifts", ^{
        
        beforeEach(^{
            
            NSString *shiftDay = @"Tuesday, Aug 16, 2017";
            
            NSDictionary *shiftDataDict = @{@"shiftDay" : shiftDay,
                                            @"ShiftEntry" : @"No shifts assigned" };
            
            presenters = [subject shiftItemPresenterSectionsForShiftDataList:@[shiftDataDict]];
            
        });
        
        it(@"One section should be there", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have no rows", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(0);
        });
        
        it(@"Section text shoule be proper", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftDayText should equal(@"Tuesday, Aug 16, 2017");
            testSectionPresenter.subText should equal(@"No shifts assigned");
        });
        
        
    });
    
    describe(@"No proper data", ^{
        
        beforeEach(^{
            
            NSString *shiftDay = @"Tuesday, Aug 16, 2017";
            NSDictionary *shiftDataDict = @{@"shiftDay" : shiftDay,
                                            @"ShiftEntry" : @{}};
            presenters = [subject shiftItemPresenterSectionsForShiftDataList:@[shiftDataDict]];
            
        });
        
        it(@"One section should be there", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have no rows", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(0);
        });
        
        it(@"Section text shoule be proper", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftDayText should equal(@"Tuesday, Aug 16, 2017");
        });
        
        
    });
});

SPEC_END
