#import <Cedar/Cedar.h>
#import "RepliconSpecHelper.h"
#import <Blindside/BlindSide.h>
#import "InjectorProvider.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ShiftDetailsPresenterSpec)

describe(@"ShiftDetailsPresenter", ^{
    __block ShiftDetailsPresenter *subject;
    __block id<BSInjector, BSBinder> injector;
    __block id<Theme> theme;
    
    
    beforeEach(^{
        
        injector = [InjectorProvider injector];
        
        theme = nice_fake_for(@protocol(Theme));
        [injector bind:@protocol(Theme) toInstance:theme];
        
        subject = [injector getInstance:[ShiftDetailsPresenter class]];
    });
    
    describe(@"Shift with note but without break", ^{
        
        __block NSArray *presenters;
        beforeEach(^{
            NSDictionary *shiftDetail = @{ @"TimeOffName":[NSNull null],
                                           @"approvalStatus":[NSNull null],
                                           @"breakType":[NSNull null],
                                           @"breakUri":[NSNull null],
                                           @"colorCode":@"F07373",
                                           @"date":@(1501718400),
                                           @"holiday":[NSNull null],
                                           @"holidayUri":[NSNull null],
                                           @"id": @"ac59819233194,72bc2945bd04381668",
                                           @"in_time":@"9:00 AM",
                                           @"in_time_stamp":@(1501731000),
                                           @"note":@"Notes from Manager",
                                           @"out_time":@"6:15 PM",
                                           @"out_time_stamp":@(1501764300),
                                           @"shiftDuration":@" 9:00 AM - 6:15 PM ",
                                           @"shiftIndex":@(0),
                                           @"shiftName":@"Day shift",
                                           @"shiftUri":@"urn:replicon-tenant:repliconiphone-2:shift:919bb35b-b3f1-41fc-94aa-4467ad8b395b",
                                           @"timeOffDayDuration":[NSNull null],
                                           @"timeOffDisplayFormatUri":[NSNull null],
                                           @"timeOffHourDuration":[NSNull null],
                                           @"timeOffUri":[NSNull null],
                                           @"type":@"Shifts"};
            
            NSArray *shiftDetails = @[shiftDetail];
            presenters = [subject shiftSectionItemPresentersForShiftDetailsList:@[shiftDetails]];
        });
        
        it(@"One section should be there in presenters", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 2 items", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(2);
        });
        it(@"Cell Identifier should be correct", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters[0].cellReuseIdentifier should equal(@"ShiftDetailCell");
        
            testSectionPresenter.shiftItemPresenters[1].cellReuseIdentifier should equal(@"ShiftDetailCell");
            
        });
        
        it(@"The presenter structure should be proper", ^{
            // Shift item
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            
            [shiftItemPresenter setupWithCellType:ShiftCellTypeShiftDetail
                             shiftDescriptionText: @"Day shift - 9:00 AM to 6:15 PM"
                      shiftDetailsDescriptionText: @"Total Hours: 09:15\nWork: 09:15 + Break:00:00"
                                            notes: nil
                                    shiftColorHex: @"#F07373"
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: nil
                                    timeOffStatus: nil
                           holidayDescriptionText: nil];
            
            // Notes item
            ShiftItemPresenter *noteItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            
            [noteItemPresenter setupWithCellType:ShiftCellTypeNotes
                            shiftDescriptionText: nil
                     shiftDetailsDescriptionText: nil
                                           notes: @"Notes from Manager"
                                   shiftColorHex: @"#F07373"
                                         udfName: nil
                                        udfValue: nil
                                 timeOffDescText: nil
                                   timeOffStatus: nil
                          holidayDescriptionText: nil];
            
            
         
            ShiftItemsSectionPresenter *sectionPresenter =[[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:nil
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter, noteItemPresenter]];
            
            presenters.count should equal(1);
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
    });
    
    describe(@"Shift with breaks", ^{
        
        __block NSArray *presenters;
        beforeEach(^{
            NSDictionary *shiftDetail = @{ @"TimeOffName":[NSNull null],
                                           @"approvalStatus":[NSNull null],
                                           @"breakType":[NSNull null],
                                           @"breakUri":[NSNull null],
                                           @"colorCode":@"F07373",
                                           @"date":@(1501718400),
                                           @"holiday":[NSNull null],
                                           @"holidayUri":[NSNull null],
                                           @"id": @"ac59819233194,72bc2945bd04381668",
                                           @"in_time":@"9:00 AM",
                                           @"in_time_stamp":@(1501731000),
                                           @"note":[NSNull null],
                                           @"out_time":@"6:15 PM",
                                           @"out_time_stamp":@(1501764300),
                                           @"shiftDuration":@" 9:00 AM - 6:15 PM ",
                                           @"shiftIndex":@(0),
                                           @"shiftName":@"Day shift",
                                           @"shiftUri":@"urn:replicon-tenant:repliconiphone-2:shift:919bb35b-b3f1-41fc-94aa-4467ad8b395b",
                                           @"timeOffDayDuration":[NSNull null],
                                           @"timeOffDisplayFormatUri":[NSNull null],
                                           @"timeOffHourDuration":[NSNull null],
                                           @"timeOffUri":[NSNull null],
                                           @"type":@"Shifts"};
            
            NSDictionary *mealBreak = @{ @"TimeOffName":[NSNull null],
                                         @"approvalStatus":[NSNull null],
                                         @"breakType":@"Meal",
                                         @"breakUri":@"Meal",
                                         @"colorCode":@"F07373",
                                         @"date":@(1501718400),
                                         @"holiday":[NSNull null],
                                         @"holidayUri":[NSNull null],
                                         @"id": @"ac59819233194,72bc2945bd04381668",
                                         @"in_time":@"1:00 PM",
                                         @"in_time_stamp":@(1501745400),
                                         @"note":[NSNull null],
                                         @"out_time":@"2:00 PM",
                                         @"out_time_stamp":@(1501749000),
                                         @"shiftDuration":@" 1:00 PM - 2:00 PM ",
                                         @"shiftIndex":@(0),
                                         @"shiftName":@"Day shift",
                                         @"shiftUri":@"urn:replicon-tenant:repliconiphone-2:shift:919bb35b-b3f1-41fc-94aa-4467ad8b395b",
                                         @"timeOffDayDuration":[NSNull null],
                                         @"timeOffDisplayFormatUri":[NSNull null],
                                         @"timeOffHourDuration":[NSNull null],
                                         @"timeOffUri":[NSNull null],
                                         @"type":@"Break"};
            
            NSArray *shiftDetails = @[shiftDetail,mealBreak];
            presenters = [subject shiftSectionItemPresentersForShiftDetailsList:@[shiftDetails]];
        });
        
        it(@"One section should be there in presenters", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 1 item", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(1);
        });
        
        it(@"Cell Identifier should be correct", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters[0].cellReuseIdentifier should equal(@"ShiftDetailCell");
            
        });
        
        it(@"The presenter structure should be proper", ^{
            // create shift section
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            
            [shiftItemPresenter setupWithCellType:ShiftCellTypeShiftDetail
                             shiftDescriptionText: @"Day shift - 9:00 AM to 6:15 PM"
                      shiftDetailsDescriptionText: @"Total Hours: 09:15\n1:00 PM - 2:00 PM - Meal\nWork: 08:15 + Break:01:00"
                                            notes: nil
                                    shiftColorHex: @"#F07373"
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: nil
                                    timeOffStatus: nil
                           holidayDescriptionText: nil];
            
            
         
            ShiftItemsSectionPresenter *sectionPresenter =[[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:nil
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter]];
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
    });
    
    describe(@"Shift with breaks and Notes, Notes added within Break Data not in Shift Data", ^{
        
        __block NSArray *presenters;
        beforeEach(^{
            NSDictionary *shiftDetail = @{ @"TimeOffName":[NSNull null],
                                           @"approvalStatus":[NSNull null],
                                           @"breakType":[NSNull null],
                                           @"breakUri":[NSNull null],
                                           @"colorCode":@"F07373",
                                           @"date":@(1501718400),
                                           @"holiday":[NSNull null],
                                           @"holidayUri":[NSNull null],
                                           @"id": @"ac59819233194,72bc2945bd04381668",
                                           @"in_time":@"9:00 AM",
                                           @"in_time_stamp":@(1501731000),
                                           @"note":[NSNull null],
                                           @"out_time":@"6:15 PM",
                                           @"out_time_stamp":@(1501764300),
                                           @"shiftDuration":@" 9:00 AM - 6:15 PM ",
                                           @"shiftIndex":@(0),
                                           @"shiftName":@"Day shift",
                                           @"shiftUri":@"urn:replicon-tenant:repliconiphone-2:shift:919bb35b-b3f1-41fc-94aa-4467ad8b395b",
                                           @"timeOffDayDuration":[NSNull null],
                                           @"timeOffDisplayFormatUri":[NSNull null],
                                           @"timeOffHourDuration":[NSNull null],
                                           @"timeOffUri":[NSNull null],
                                           @"type":@"Shifts"};
            
            NSDictionary *mealBreak = @{ @"TimeOffName":[NSNull null],
                                         @"approvalStatus":[NSNull null],
                                         @"breakType":@"Meal",
                                         @"breakUri":@"Meal",
                                         @"colorCode":@"F07373",
                                         @"date":@(1501718400),
                                         @"holiday":[NSNull null],
                                         @"holidayUri":[NSNull null],
                                         @"id": @"ac59819233194,72bc2945bd04381668",
                                         @"in_time":@"1:00 PM",
                                         @"in_time_stamp":@(1501745400),
                                         @"note":@"Note inserted in Break",
                                         @"out_time":@"2:00 PM",
                                         @"out_time_stamp":@(1501749000),
                                         @"shiftDuration":@" 1:00 PM - 2:00 PM ",
                                         @"shiftIndex":@(0),
                                         @"shiftName":@"Day shift",
                                         @"shiftUri":@"urn:replicon-tenant:repliconiphone-2:shift:919bb35b-b3f1-41fc-94aa-4467ad8b395b",
                                         @"timeOffDayDuration":[NSNull null],
                                         @"timeOffDisplayFormatUri":[NSNull null],
                                         @"timeOffHourDuration":[NSNull null],
                                         @"timeOffUri":[NSNull null],
                                         @"type":@"Break"};
            
            NSArray *shiftDetails = @[shiftDetail,mealBreak];
            presenters = [subject shiftSectionItemPresentersForShiftDetailsList:@[shiftDetails]];
        });
        
        it(@"One section should be there in presenters", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 2 item", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(2);
        });
        
        it(@"Cell Identifier should be correct", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters[0].cellReuseIdentifier should equal(@"ShiftDetailCell");
            testSectionPresenter.shiftItemPresenters[1].cellReuseIdentifier should equal(@"ShiftDetailCell");
            
        });
        
        it(@"The presenter structure should be proper", ^{
            // create shift section
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            
            [shiftItemPresenter setupWithCellType:ShiftCellTypeShiftDetail
                             shiftDescriptionText: @"Day shift - 9:00 AM to 6:15 PM"
                      shiftDetailsDescriptionText: @"Total Hours: 09:15\n1:00 PM - 2:00 PM - Meal\nWork: 08:15 + Break:01:00"
                                            notes: nil
                                    shiftColorHex: @"#F07373"
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: nil
                                    timeOffStatus: nil
                           holidayDescriptionText: nil];
            
            ShiftItemPresenter *notesItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            
            [notesItemPresenter setupWithCellType:ShiftCellTypeNotes
                             shiftDescriptionText: nil
                      shiftDetailsDescriptionText: nil
                                            notes: @"Note inserted in Break"
                                    shiftColorHex: @"#F07373"
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: nil
                                    timeOffStatus: nil
                           holidayDescriptionText: nil];
            
            
            
            ShiftItemsSectionPresenter *sectionPresenter =[[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:nil
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter, notesItemPresenter]];
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
    });
    
    describe(@"Shift and Time Off", ^{
        
        __block NSArray *presenters;
        beforeEach(^{
            NSDictionary *timeOff = @{ @"TimeOffName":@"Vacation_Hours",
                                       @"approvalStatus":@"approved",
                                       @"breakType":[NSNull null],
                                       @"breakUri":[NSNull null],
                                       @"colorCode":@"F07373",
                                       @"date":@(1501718400),
                                       @"holiday":[NSNull null],
                                       @"holidayUri":[NSNull null],
                                       @"id": @"ac59819233194,72bc2945bd04381668",
                                       @"in_time":[NSNull null],
                                       @"in_time_stamp":[NSNull null],
                                       @"note":[NSNull null],
                                       @"out_time":[NSNull null],
                                       @"out_time_stamp":[NSNull null],
                                       @"shiftDuration":[NSNull null],
                                       @"shiftIndex":@(0),
                                       @"shiftName":@"Day shift",
                                       @"shiftUri":@"urn:replicon-tenant:repliconiphone-2:shift:919bb35b-b3f1-41fc-94aa-4467ad8b395b",
                                       @"timeOffDayDuration":@"0.668918918918919",
                                       @"timeOffDisplayFormatUri":@"urn:replicon:time-off-measurement-unit:hours",
                                       @"timeOffHourDuration":@"6.1875",
                                       @"timeOffUri":@"urn:replicon-tenant:repliconiphone-2:time-off:20292",
                                       @"type":@"TimeOff"};
            
            NSDictionary *shiftDetail = @{ @"TimeOffName":[NSNull null],
                                           @"approvalStatus":[NSNull null],
                                           @"breakType":[NSNull null],
                                           @"breakUri":[NSNull null],
                                           @"colorCode":@"F07373",
                                           @"date":@(1501718400),
                                           @"holiday":[NSNull null],
                                           @"holidayUri":[NSNull null],
                                           @"id": @"ac59819233194,72bc2945bd04381668",
                                           @"in_time":@"9:00 AM",
                                           @"in_time_stamp":@(1501731000),
                                           @"note":[NSNull null],
                                           @"out_time":@"6:15 PM",
                                           @"out_time_stamp":@(1501764300),
                                           @"shiftDuration":@"9:00 AM - 6:15 PM",
                                           @"shiftIndex":@(0),
                                           @"shiftName":@"Day shift",
                                           @"shiftUri":@"urn:replicon-tenant:repliconiphone-2:shift:919bb35b-b3f1-41fc-94aa-4467ad8b395b",
                                           @"timeOffDayDuration":[NSNull null],
                                           @"timeOffDisplayFormatUri":[NSNull null],
                                           @"timeOffHourDuration":[NSNull null],
                                           @"timeOffUri":[NSNull null],
                                           @"type":@"Shifts"};
            
            
            NSArray *shiftDetails = @[timeOff, @[shiftDetail]];
            presenters = [subject shiftSectionItemPresentersForShiftDetailsList:shiftDetails];
        });
        
        it(@"Two section should be there in presenters", ^{
            presenters.count should equal(2);
        });
        
        it(@"1st section should have 1 item", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(1);
        });
        
        it(@"1st section Cell Identifier should be correct", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters[0].cellReuseIdentifier should equal(@"ShiftScheduleTimeOffCell");
        });
        
        it(@"2nd section should have 1 item", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[1];
            testSectionPresenter.shiftItemPresenters.count should equal(1);
        });
        it(@"2nd Cell Identifier should be correct", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[1];
            testSectionPresenter.shiftItemPresenters[0].cellReuseIdentifier should equal(@"ShiftDetailCell");
            
        });
        
        it(@"The presenter structure should be proper", ^{
            // Time off Section
            ShiftItemPresenter *timeOffItem =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            
            [timeOffItem setupWithCellType:ShiftCellTypeTimeOff
                             shiftDescriptionText: nil
                      shiftDetailsDescriptionText: nil
                                            notes: nil
                                    shiftColorHex: nil
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: @"Vacation_Hours : 6.19 hours"
                                    timeOffStatus: @"approved"
                           holidayDescriptionText: nil];
            
            ShiftItemsSectionPresenter *timeOffSection =[[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [timeOffSection setupWithShiftDayText:nil
                                            subText:nil
                                shiftItemPresenters:@[timeOffItem]];
            
            // shift section
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            
            [shiftItemPresenter setupWithCellType:ShiftCellTypeShiftDetail
                             shiftDescriptionText: @"Day shift - 9:00 AM to 6:15 PM"
                      shiftDetailsDescriptionText: @"Total Hours: 09:15\nWork: 09:15 + Break:00:00"
                                            notes: nil
                                    shiftColorHex: @"#F07373"
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: nil
                                    timeOffStatus: nil
                           holidayDescriptionText: nil];
            
            
            ShiftItemsSectionPresenter *shiftSection =[[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [shiftSection setupWithShiftDayText:nil
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter]];
            
            NSArray *sections = @[timeOffSection, shiftSection];
            
            presenters should equal(sections);
            
        });
    });
    
    describe(@"Holiday", ^{
        
        __block NSArray *presenters;
        beforeEach(^{
            NSDictionary *holiday = @{ @"TimeOffName":[NSNull null],
                                           @"approvalStatus":[NSNull null],
                                           @"breakType":[NSNull null],
                                           @"breakUri":[NSNull null],
                                           @"colorCode":[NSNull null],
                                           @"date":@(1502755200),
                                           @"holiday":@"National Holiday",
                                           @"holidayUri":@"urn:replicon-tenant:repliconiphone-2:holiday:2541",
                                           @"id": @"ac59819233194,72bc2945bd04381668",
                                           @"in_time":[NSNull null],
                                           @"in_time_stamp":[NSNull null],
                                           @"note":[NSNull null],
                                           @"out_time":[NSNull null],
                                           @"out_time_stamp":[NSNull null],
                                           @"shiftDuration":[NSNull null],
                                           @"shiftIndex":@(0),
                                           @"shiftName":[NSNull null],
                                           @"shiftUri":[NSNull null],
                                           @"timeOffDayDuration":[NSNull null],
                                           @"timeOffDisplayFormatUri":[NSNull null],
                                           @"timeOffHourDuration":[NSNull null],
                                           @"timeOffUri":[NSNull null],
                                           @"type":@"Holiday"};

            presenters = [subject shiftSectionItemPresentersForShiftDetailsList:@[holiday]];
        });
        
        it(@"One section should be there in presenters", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 1 item", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(1);
        });
        
        it(@"The presenter structure should be proper", ^{
            // Shift item
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            
            [shiftItemPresenter setupWithCellType:ShiftCellTypeHoliday
                             shiftDescriptionText: nil
                      shiftDetailsDescriptionText: nil
                                            notes: nil
                                    shiftColorHex: nil
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: nil
                                    timeOffStatus: nil
                           holidayDescriptionText: @"National Holiday"];
            
            
            ShiftItemsSectionPresenter *sectionPresenter =[[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:nil
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter]];
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
    });
    
    describe(@"Shift and UDFs", ^{
        
        __block NSArray *presenters;
        beforeEach(^{
            NSDictionary *shiftDetail;
            NSDictionary *udf1;
            NSDictionary *udf2;
            
            shiftDetail = @{ @"TimeOffName":[NSNull null],
                                       @"approvalStatus":[NSNull null],
                                       @"breakType":[NSNull null],
                                       @"breakUri":[NSNull null],
                                       @"colorCode":@"F07373",
                                       @"date":@(1501718400),
                                       @"holiday":[NSNull null],
                                       @"holidayUri":[NSNull null],
                                       @"id": @"ac59819233194,72bc2945bd04381668",
                                       @"in_time":@"9:00 AM",
                                       @"in_time_stamp":@(1501731000),
                                       @"note":[NSNull null],
                                       @"out_time":@"6:15 PM",
                                       @"out_time_stamp":@(1501764300),
                                       @"shiftDuration":@"9:00 AM - 6:15 PM",
                                       @"shiftIndex":@(0),
                                       @"shiftName":@"Day shift",
                                       @"shiftUri":@"urn:replicon-tenant:repliconiphone-2:shift:919bb35b-b3f1-41fc-94aa-4467ad8b395b",
                                       @"timeOffDayDuration":[NSNull null],
                                       @"timeOffDisplayFormatUri":[NSNull null],
                                       @"timeOffHourDuration":[NSNull null],
                                       @"timeOffUri":[NSNull null],
                                       @"type":@"Shifts"};
            
            udf1 = @{ @"in_time_stamp" : @(1502150400),
                      @"shiftIndex" : @(1),
                      @"shiftUri" : @"urn:replicon-tenant:repliconiphone-2:shift:31484e65-dd35-4c9d-9849-22325100ea3b",
                      @"type" : @"UDF",
                      @"udfValue" : @"ABCF",
                      @"udfValue_uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag:31bf9dfd-f784-400c-a4a8-d210965e9c8f",
                      @"udf_name" : @"Job Job Job - Drop Down UDF UDF",
                      @"udf_uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ab526480-8cdf-4c11-a857-e733aa0c1f68"};
            
            udf2 = @{ @"in_time_stamp" : @(1502150400),
                      @"shiftIndex" : @(1),
                      @"shiftUri" : @"urn:replicon-tenant:repliconiphone-2:shift:31484e65-dd35-4c9d-9849-22325100ea3b",
                      @"type" : @"UDF",
                      @"udfValue" : @"56",
                      @"udfValue_uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag:31bf9dfd-f784-400c-a4a8-d210965e9c8f",
                      @"udf_name" : @"Location Drop Down OEF - ROW",
                      @"udf_uri" : @"urn:replicon-tenant:repliconiphone-2:object-extension-tag-definition:ab526480-8cdf-4c11-a857-e733aa0c1f68"};
            
            presenters = [subject shiftSectionItemPresentersForShiftDetailsList:@[@[shiftDetail, udf1, udf2]]];
        });
        
        it(@"One section should be there in presenters", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 3 item", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(3);
        });
        
        it(@"Cell Identifier should be correct", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters[0].cellReuseIdentifier should equal(@"ShiftDetailCell");
            
            testSectionPresenter.shiftItemPresenters[1].cellReuseIdentifier should equal(@"ShiftDetailCell");
            
            testSectionPresenter.shiftItemPresenters[2].cellReuseIdentifier should equal(@"ShiftDetailCell");
            
        });
        
        it(@"The presenter structure should be proper", ^{
            // Shift item
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            
            [shiftItemPresenter setupWithCellType:ShiftCellTypeShiftDetail
                             shiftDescriptionText: @"Day shift - 9:00 AM to 6:15 PM"
                      shiftDetailsDescriptionText: @"Total Hours: 09:15\nWork: 09:15 + Break:00:00"
                                            notes: nil
                                    shiftColorHex: @"#F07373"
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: nil
                                    timeOffStatus: nil
                           holidayDescriptionText: nil];
            
            //udfs
            ShiftItemPresenter *udf1 =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            
            [udf1 setupWithCellType:ShiftCellTypeUdf
                             shiftDescriptionText: nil
                      shiftDetailsDescriptionText: nil
                                            notes: nil
                                    shiftColorHex: @"#F07373"
                                          udfName: @"Job Job Job - Drop Down UDF UDF"
                                         udfValue: @"ABCF"
                                  timeOffDescText: nil
                                    timeOffStatus: nil
                           holidayDescriptionText: nil];
            
            ShiftItemPresenter *udf2 =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            
            [udf2 setupWithCellType:ShiftCellTypeUdf
                             shiftDescriptionText: nil
                      shiftDetailsDescriptionText: nil
                                            notes: nil
                                    shiftColorHex: @"#F07373"
                                          udfName: @"Location Drop Down OEF - ROW"
                                         udfValue: @"56"
                                  timeOffDescText: nil
                                    timeOffStatus: nil
                           holidayDescriptionText: nil];
            
            
            ShiftItemsSectionPresenter *sectionPresenter =[[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:nil
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter, udf1, udf2]];
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
    });
    
    describe(@"No Shifts", ^{
        
        __block NSArray *presenters;
        beforeEach(^{
            
            presenters = [subject shiftSectionItemPresentersForShiftDetailsList:@[@""]];
        });
        
        it(@"One section should be there in presenters", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 1 item", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(1);
        });
        
        it(@"Cell Identifier should be correct", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters[0].cellReuseIdentifier should equal(@"ShiftDetailCell");
        });
        
        it(@"The presenter structure should be proper", ^{
            // Shift item
            ShiftItemPresenter *shiftItemPresenter =  [[ShiftItemPresenter alloc] initWithTheme: theme];
            
            [shiftItemPresenter setupWithCellType:ShiftCellTypeNoShifts
                             shiftDescriptionText: NO_SHIFT
                      shiftDetailsDescriptionText: nil
                                            notes: nil
                                    shiftColorHex: nil
                                          udfName: nil
                                         udfValue: nil
                                  timeOffDescText: nil
                                    timeOffStatus: nil
                           holidayDescriptionText: nil];
            
            
            
            ShiftItemsSectionPresenter *sectionPresenter =[[ShiftItemsSectionPresenter alloc] initWithTheme: theme];
            [sectionPresenter setupWithShiftDayText:nil
                                            subText:nil
                                shiftItemPresenters:@[shiftItemPresenter]];
            
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter should equal(sectionPresenter);
            
        });
    });
    
    describe(@"No proper data - empty dictionary in array", ^{
        
        __block NSArray *presenters;
        beforeEach(^{
            
            presenters = [subject shiftSectionItemPresentersForShiftDetailsList:@[@{}]];
        });
        
        it(@"One section should be there in presenters", ^{
            presenters.count should equal(1);
        });
        
        it(@"Section should have 0 item", ^{
            ShiftItemsSectionPresenter *testSectionPresenter = presenters[0];
            testSectionPresenter.shiftItemPresenters.count should equal(0);
        });
        
    });
    
    describe(@"No proper data - nothing in the array", ^{
        
        __block NSArray *presenters;
        beforeEach(^{
            
            presenters = [subject shiftSectionItemPresentersForShiftDetailsList:@[]];
        });
        
        it(@"No sections should be there in presenters", ^{
            presenters.count should equal(0);
        });
        
        
    });
});

SPEC_END
