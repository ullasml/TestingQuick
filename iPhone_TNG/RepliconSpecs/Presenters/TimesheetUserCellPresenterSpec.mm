#import <Cedar/Cedar.h>
#import "TimesheetUserCellPresenter.h"
#import "TimesheetForUserWithWorkHours.h"
#import "Theme.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


void assertColorAttribute(NSAttributedString *string, NSUInteger location, NSUInteger length, id attribute) {
    NSRange inRange = NSMakeRange(location, length);
    NSRange longestEffectiveRange;
    id appliedAttribute = [string attribute:NSForegroundColorAttributeName
                                    atIndex:location
                      longestEffectiveRange:&longestEffectiveRange
                                    inRange:inRange];
    longestEffectiveRange.location should equal(location);
    longestEffectiveRange.length should equal(length);
    appliedAttribute should equal(attribute);
};

SPEC_BEGIN(TimesheetUserCellPresenterSpec)

describe(@"TimesheetUserCellPresenter", ^{
    __block TimesheetUserCellPresenter *subject;
    __block id<Theme> theme;
    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        subject = [[TimesheetUserCellPresenter alloc] initWithTheme:theme];
    });

    describe(@"presenting the user name for a timesheet user", ^{
        __block TimesheetForUserWithWorkHours *user;
        __block NSString *username;

        beforeEach(^{
            user = nice_fake_for([TimesheetForUserWithWorkHours class]);
            user stub_method(@selector(userName)).and_return(@"my special name");
            username = [subject userNameLabelTextWithTimesheetUser:user];
        });

        it(@"should return the user's name", ^{
            username should equal(@"my special name");
        });
    });

    describe(@"presenting the work hours for a timesheet user", ^{
        __block TimesheetForUserWithWorkHours *user;
        __block NSString *workHoursText;
        __block NSDateComponents *dateComponents;

        beforeEach(^{
            user = nice_fake_for([TimesheetForUserWithWorkHours class]);
            dateComponents = [[NSDateComponents alloc] init];
            dateComponents.hour = 10;
            dateComponents.second = 59;
            user stub_method(@selector(totalWorkHours)).and_return(dateComponents);
        });

        context(@"when there are exactly 0 minutes", ^{
            beforeEach(^{
                dateComponents.minute = 0;
                workHoursText = [subject workHoursLabelTextWithTimesheetUser:user];
            });
            it(@"should return the correctly formatted work hours summary", ^{
                workHoursText should equal(@"10h:00m");
            });
        });

        context(@"when there are less than 10 minutes", ^{
            beforeEach(^{
                dateComponents.minute = 9;
                workHoursText = [subject workHoursLabelTextWithTimesheetUser:user];
            });

            it(@"should return the correctly formatted work hours summary", ^{
                workHoursText should equal(@"10h:09m");
            });
        });

        context(@"when there are 10 or more minutes", ^{
            beforeEach(^{
                dateComponents.minute = 10;
                workHoursText = [subject workHoursLabelTextWithTimesheetUser:user];
            });

            it(@"should return the correctly formatted work hours summary", ^{
                workHoursText should equal(@"10h:10m");
            });
        });
        
        context(@"when there are negative hours and minutes", ^{
            beforeEach(^{
                dateComponents.minute = -10;
                dateComponents.hour = -2;
                workHoursText = [subject workHoursLabelTextWithTimesheetUser:user];
            });
            
            it(@"should return the correctly formatted work hours summary", ^{
                workHoursText should equal(@"-2h:10m");
            });
        });
    });

    describe(@"presenting the Break hours, Overtime and Violations Count for a timesheet user", ^{
        __block TimesheetForUserWithWorkHours *user;
        __block NSAttributedString *attributedString;
        __block NSDateComponents *breakHoursDateComponents;
        __block NSDateComponents *overtimeDateComponents;

        beforeEach(^{
            theme stub_method(@selector(timesheetUserOvertimeAndViolationsColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(timesheetUserBreakHoursColor)).and_return([UIColor greenColor]);
            user = nice_fake_for([TimesheetForUserWithWorkHours class]);
            breakHoursDateComponents = [[NSDateComponents alloc] init];
            breakHoursDateComponents.hour = 10;
            breakHoursDateComponents.second = 59;

            overtimeDateComponents = [[NSDateComponents alloc] init];
            overtimeDateComponents.hour = 0;
            overtimeDateComponents.minute = 0;
            overtimeDateComponents.second = 0;

            user stub_method(@selector(violationsCount)).and_return(@0);
            user stub_method(@selector(totalBreakHours)).and_return(breakHoursDateComponents);
            user stub_method(@selector(totalOvertimeHours)).and_return(overtimeDateComponents);
        });

        context(@"when there are exactly 0 minutes of break time", ^{
            __block NSString *breakStr;
            beforeEach(^{
                breakHoursDateComponents.minute = 0;
                attributedString = [subject regularHoursLabelTextWithTimesheetUser:user];
                breakStr = [NSString stringWithFormat:@"10h:00m %@",RPLocalizedString(@"Break", @"")];
            });

            it(@"should return the correctly formatted work hours summary", ^{

                [attributedString string] should equal(breakStr);
            });

            it(@"should color the string appropriately", ^{
                assertColorAttribute(attributedString, 0, [breakStr length], [UIColor greenColor]);
            });
        });

        context(@"when there are less than 10 minutes of break time", ^{
            __block NSString *breakStr;
            beforeEach(^{
                breakHoursDateComponents.minute = 9;
                attributedString = [subject regularHoursLabelTextWithTimesheetUser:user];
                breakStr = [NSString stringWithFormat:@"10h:09m %@",RPLocalizedString(@"Break", @"")];
            });

            it(@"should return the correctly formatted work hours summary", ^{
                [attributedString string] should equal(breakStr);
            });

            it(@"should color the string appropriately", ^{
                assertColorAttribute(attributedString, 0, [breakStr length], [UIColor greenColor]);
            });
        });

        context(@"when there are less than 10 hours and less than 10 minutes of break time", ^{
            __block NSString *breakStr;
            beforeEach(^{
                breakHoursDateComponents.hour = 9;
                breakHoursDateComponents.minute = 9;
                attributedString = [subject regularHoursLabelTextWithTimesheetUser:user];
                breakStr = [NSString stringWithFormat:@"09h:09m %@",RPLocalizedString(@"Break", @"")];
            });

            it(@"should return the correctly formatted work hours summary", ^{
                [attributedString string] should equal(breakStr);
            });

            it(@"should color the string appropriately", ^{
                assertColorAttribute(attributedString, 0, [breakStr length], [UIColor greenColor]);
            });
        });

        context(@"when there are 10 or more minutes of break time", ^{
            __block NSString *breakStr;
            beforeEach(^{
                breakHoursDateComponents.minute = 10;
                attributedString = [subject regularHoursLabelTextWithTimesheetUser:user];
                breakStr = [NSString stringWithFormat:@"10h:10m %@",RPLocalizedString(@"Break", @"")];
            });

            it(@"should return the correctly formatted work hours summary", ^{
                [attributedString string] should equal(breakStr);
            });

            it(@"should color the string appropriately", ^{
                assertColorAttribute(attributedString, 0, [breakStr length], [UIColor greenColor]);
            });
        });

        context(@"when there are 10 or more minutes of break time, 10 hours and 10 minutes of OT", ^{
            beforeEach(^{
                breakHoursDateComponents.minute = 10;

                overtimeDateComponents.hour = 10;
                overtimeDateComponents.minute = 10;

                attributedString = [subject regularHoursLabelTextWithTimesheetUser:user];
            });

            it(@"should return the correctly formatted work hours summary", ^{
                NSString *workHours = [NSString stringWithFormat:@"10h:10m %@ + 10h:10m %@",RPLocalizedString(@"Break", @""),RPLocalizedString(@"OT", @"")];
                [attributedString string] should equal(workHours);
            });

            it(@"should color the string appropriately", ^{
                NSString *breakString = [NSString stringWithFormat:@"10h:10m %@",RPLocalizedString(@"Break", @"")];
                NSString *otString = [NSString stringWithFormat:@"10h:10m %@",RPLocalizedString(@"OT", @"")];
                assertColorAttribute(attributedString, 0,  [breakString length], [UIColor greenColor]);
                assertColorAttribute(attributedString, [breakString length], [@" + " length], [UIColor greenColor]);
                assertColorAttribute(attributedString, [breakString length]+[@" + " length], [otString length],    [UIColor orangeColor]);
            });
        });

        context(@"when there are 10 or more minutes of regular time, 10 hours and 10 minutes of OT, 1 violation", ^{
            beforeEach(^{
                breakHoursDateComponents.minute = 10;
                overtimeDateComponents.hour = 10;
                overtimeDateComponents.minute = 10;

                user stub_method(@selector(violationsCount)).again().and_return(@1);

                attributedString = [subject regularHoursLabelTextWithTimesheetUser:user];
            });

            it(@"should return the correctly formatted work hours summary", ^{
                NSString *workHours = [NSString stringWithFormat:@"10h:10m %@ + 10h:10m %@ + 1 %@",RPLocalizedString(@"Break", @""),RPLocalizedString(@"OT", @""),RPLocalizedString(@"Violation", @"")];
                [attributedString string] should equal(workHours);
            });

            it(@"should color the string appropriately", ^{
                NSString *breakString = [NSString stringWithFormat:@"10h:10m %@",RPLocalizedString(@"Break", @"")];
                NSString *otString = [NSString stringWithFormat:@"10h:10m %@",RPLocalizedString(@"OT", @"")];
                NSString *violationString = [NSString stringWithFormat:@"1 %@",RPLocalizedString(@"Violation", @"")];
                assertColorAttribute(attributedString, 0,  [breakString length], [UIColor greenColor]);
                assertColorAttribute(attributedString, [breakString length], [@" + " length],           [UIColor greenColor]);
                assertColorAttribute(attributedString, [breakString length]+[@" + " length], [otString length],    [UIColor orangeColor]);
                assertColorAttribute(attributedString, [breakString length]+[@" + " length]+[otString length], [@" + " length],           [UIColor greenColor]);
                assertColorAttribute(attributedString, [breakString length]+[@" + " length]+[otString length]+[@" + " length], [violationString length],   [UIColor orangeColor]);
            });
        });

        context(@"when there are 10 or more minutes of regular time, 10 hours and 10 minutes of OT, 2 violation", ^{
            beforeEach(^{
                breakHoursDateComponents.minute = 10;

                overtimeDateComponents.hour = 10;
                overtimeDateComponents.minute = 10;

                user stub_method(@selector(violationsCount)).again().and_return(@2);

                attributedString = [subject regularHoursLabelTextWithTimesheetUser:user];
            });

            it(@"should return the correctly formatted work hours summary", ^{
                NSString *workHours = [NSString stringWithFormat:@"10h:10m %@ + 10h:10m %@ + 2 %@",RPLocalizedString(@"Break", @""),RPLocalizedString(@"OT", @""),RPLocalizedString(@"Violations", @"")];
                [attributedString string] should equal(workHours);
            });

            it(@"should color the string appropriately", ^{
                NSString *breakString = [NSString stringWithFormat:@"10h:10m %@",RPLocalizedString(@"Break", @"")];
                NSString *otString = [NSString stringWithFormat:@"10h:10m %@",RPLocalizedString(@"OT", @"")];
                NSString *violationString = [NSString stringWithFormat:@"2 %@",RPLocalizedString(@"Violations", @"")];

                assertColorAttribute(attributedString, 0,  [breakString length], [UIColor greenColor]);
                assertColorAttribute(attributedString, [breakString length], [@" + " length], [UIColor greenColor]);
                assertColorAttribute(attributedString, [breakString length]+[@" + " length], [otString length], [UIColor orangeColor]);
                assertColorAttribute(attributedString, [breakString length]+[@" + " length]+[otString length], [@" + " length], [UIColor greenColor]);
                assertColorAttribute(attributedString, [breakString length]+[@" + " length]+[otString length]+[@" + " length], [violationString length], [UIColor orangeColor]);
            });
        });

        context(@"when there are 10 or more minutes of break time, 0 hours and 0 minutes of OT, 2 violations", ^{
            beforeEach(^{
                breakHoursDateComponents.minute = 10;

                user stub_method(@selector(violationsCount)).again().and_return(@2);

                attributedString = [subject regularHoursLabelTextWithTimesheetUser:user];
            });

            it(@"should return the correctly formatted work hours summary", ^{
                
                NSString *workHours = [NSString stringWithFormat:@"10h:10m %@ + 2 %@",RPLocalizedString(@"Break", @""),RPLocalizedString(@"Violations", @"")];
                [attributedString string] should equal(workHours);
            });

            it(@"should color the string appropriately", ^{
                NSString *breakString = [NSString stringWithFormat:@"10h:10m %@",RPLocalizedString(@"Break", @"")];
                NSString *violationString = [NSString stringWithFormat:@"2 %@",RPLocalizedString(@"Violations", @"")];
                assertColorAttribute(attributedString, 0, [breakString length], [UIColor greenColor]);
                assertColorAttribute(attributedString, [breakString length], [@" + " length], [UIColor greenColor]);
                assertColorAttribute(attributedString, [breakString length]+[@" + " length], violationString.length, [UIColor orangeColor]);
            });
        });
    });
});

SPEC_END
