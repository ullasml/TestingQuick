#import <Cedar/Cedar.h>
#import "TodaysDateController.h"
#import "DateProvider.h"
#import "Theme.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TodaysDateControllerSpec)

describe(@"TodaysDateController", ^{
    __block TodaysDateController *subject;
    __block DateProvider *dateProvider;
    __block NSDateFormatter *dateFormatter;
    __block id<Theme> theme;

    beforeEach(^{
        dateProvider = nice_fake_for([DateProvider class]);
        dateFormatter = nice_fake_for([NSDateFormatter class]);
        theme = nice_fake_for(@protocol(Theme));
        subject = [[TodaysDateController alloc] initWithDateProvider:dateProvider
                                                       dateFormatter:dateFormatter
                                                               theme:theme];
    });

    describe(@"presenting today's date", ^{
        
        context(@"for scheduled days", ^{
            beforeEach(^{
                [subject setUpWithScheduledDay:YES];
                NSDate *date = nice_fake_for([NSDate class]);
                dateProvider stub_method(@selector(date)).and_return(date);
                dateFormatter stub_method(@selector(stringFromDate:)).with(date).and_return(@"my special date");
                theme stub_method(@selector(timeCardSummaryDateTextColor)).and_return([UIColor redColor]);
                theme stub_method(@selector(timeCardSummaryDateTextFont)).and_return([UIFont systemFontOfSize:14.0f]);
                
                [subject view];
            });
            
            it(@"should display the formatted date correctly on the label", ^{
                subject.dateLabel.text should equal(@"my special date");
            });
            
            it(@"should style the views", ^{
                subject.dateLabel.textColor should equal([UIColor redColor]);
                subject.dateLabel.font should equal([UIFont systemFontOfSize:14.0f]);
                subject.dateLabel.alpha should equal(CGFloat(1.0f));
            });
        });
        
        context(@"for non-scheduled days", ^{
            beforeEach(^{
                [subject setUpWithScheduledDay:NO];
                NSDate *date = nice_fake_for([NSDate class]);
                dateProvider stub_method(@selector(date)).and_return(date);
                dateFormatter stub_method(@selector(stringFromDate:)).with(date).and_return(@"my special date");
                theme stub_method(@selector(timeCardSummaryDateTextColor)).and_return([UIColor redColor]);
                theme stub_method(@selector(timeCardSummaryDateTextFont)).and_return([UIFont systemFontOfSize:14.0f]);
                
                [subject view];
            });
            
            it(@"should display the formatted date correctly on the label", ^{
                subject.dateLabel.text should equal(@"my special date");
            });
            
            it(@"should style the views", ^{
                subject.dateLabel.textColor should equal([UIColor redColor]);
                subject.dateLabel.font should equal([UIFont systemFontOfSize:14.0f]);
                subject.dateLabel.alpha should equal(CGFloat(0.55f));
            });
        });
        
    });
});

SPEC_END
