
#import <UIKit/UIKit.h>


@protocol AddPunchTimeLineCellDelegate;

@interface AddPunchTimeLineCell : UITableViewCell

@property (weak, nonatomic, readonly) UIButton *addPunchBtn;
@property (nonatomic, readonly) id <AddPunchTimeLineCellDelegate>delegate;
@property (weak, nonatomic, readonly) NSLayoutConstraint *addPunchTopConstraint;
- (void)setUpWithDelegate:(id<AddPunchTimeLineCellDelegate>)delegate topConstraint:(CGFloat)topPadding;

@end

@protocol AddPunchTimeLineCellDelegate <NSObject>

- (void)addPunchTimeLineCell:(AddPunchTimeLineCell *)addPunchTimeLineCell
    intendedToAddManualPunch:(UIButton *)addPunchButton;

@end
