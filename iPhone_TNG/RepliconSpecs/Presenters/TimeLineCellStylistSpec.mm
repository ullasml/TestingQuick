#import <Cedar/Cedar.h>
#import "TimeLineCellStylist.h"
#import "Theme.h"
#import "TimeLineCell.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(TimeLineCellStylistSpec)

describe(@"TimeLineCellStylist", ^{
    __block TimeLineCellStylist *subject;
    __block id<Theme> theme;

    beforeEach(^{
        theme = nice_fake_for(@protocol(Theme));
        subject = [[TimeLineCellStylist alloc] initWithTheme:theme];
    });

    describe(NSStringFromSelector(@selector(applyStyleToCell:hidesDescendingLine:)), ^{
        __block TimeLineCell *cell;
        beforeEach(^{
            theme stub_method(@selector(timeLineCellTimeLabelFont)).and_return([UIFont systemFontOfSize:10.0f]);
            theme stub_method(@selector(timeLineCellDescriptionLabelFont)).and_return([UIFont systemFontOfSize:20.0f]);
            theme stub_method(@selector(timeLineCellTimeLabelTextColor)).and_return([UIColor orangeColor]);
            theme stub_method(@selector(timeLineCellDescriptionLabelTextColor)).and_return([UIColor greenColor]);
            theme stub_method(@selector(timeLineCellVerticalLineColor)).and_return([UIColor magentaColor]);
            theme stub_method(@selector(transparentBackgroundColor)).and_return([UIColor magentaColor]);
            UINib *timeLineCell = [UINib nibWithNibName:@"TimeLineCell"
                                                 bundle:nil];
            cell = [[timeLineCell instantiateWithOwner:nil
                                               options:nil] firstObject];
        });

        context(@"when showing both the ascending and descending lines", ^{
            beforeEach(^{
                [subject applyStyleToCell:cell
                      hidesDescendingLine:NO];
            });

            it(@"should style the time label", ^{
                cell.timeLabel.font should equal([UIFont systemFontOfSize:10.0f]);
                cell.timeLabel.textColor should equal([UIColor blackColor]);
            });
            
            it(@"should set the separator inset", ^{
                cell.separatorInset should equal(UIEdgeInsetsMake(0.0f, 114.0f, 0.0f, 0.0f));
            });

            it(@"should style the description label", ^{

                cell.descriptionLabel.backgroundColor should equal([UIColor magentaColor]);
            });

            it(@"should show the ascending line", ^{
                cell.ascendingLineView.hidden should_not be_truthy;
            });

            it(@"should show the descending line", ^{
                cell.descendingLineView.hidden should_not be_truthy;
            });

            it(@"should style the color of the lines", ^{
                cell.descendingLineView.backgroundColor should equal([UIColor magentaColor]);
            });
        });

        context(@"when showing just the ascending line (and hiding the descending line)", ^{
            beforeEach(^{
                [subject applyStyleToCell:cell
                      hidesDescendingLine:YES];
            });

            it(@"should style the time label", ^{
                cell.timeLabel.font should equal([UIFont systemFontOfSize:10.0f]);
                cell.timeLabel.textColor should equal([UIColor blackColor]);
            });

            it(@"should style the description label", ^{
                
                cell.descriptionLabel.backgroundColor should equal([UIColor magentaColor]);
            });

            it(@"should set the separator inset", ^{
                cell.separatorInset.right should equal(CGRectGetWidth(cell.bounds));
            });

            it(@"should show the ascending line", ^{
                cell.ascendingLineView.hidden should_not be_truthy;
            });

            it(@"should not show the descending line", ^{
                cell.descendingLineView.hidden should be_truthy;
            });
        });
    });
});

SPEC_END
