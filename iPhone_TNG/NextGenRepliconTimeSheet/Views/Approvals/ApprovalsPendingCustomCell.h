#import <UIKit/UIKit.h>

@protocol approvalSelectedUserDelegate;

@interface ApprovalsPendingCustomCell : UITableViewCell {
    UILabel *leftLbl;
    UILabel *rightLbl;
    UIButton *radioButton;
    BOOL userSelected;
    id<approvalSelectedUserDelegate> __weak delegate;
    UILabel *leftLowerLb;
    id __weak tableDelegate;
    BOOL hasComment;
    UIImageView *commentsImageView;
}

@property (nonatomic, strong) UILabel *leftLbl;
@property (nonatomic, strong) UILabel *rightLbl;
@property (nonatomic, strong) UIButton *radioButton;
@property (nonatomic, assign) BOOL userSelected;
@property (nonatomic, weak) id<approvalSelectedUserDelegate> delegate;
@property (nonatomic, strong) UILabel *leftLowerLb;
@property (nonatomic, weak) id tableDelegate;

- (void)createCellLayoutWithParams:(NSString *)leftString
                   leftLowerString:(NSString *)lowerLeftString
                          rightstr:(NSString *)rightString
                    radioButtonTag:(NSInteger)tagValue
                       overTimeStr:(NSString *)overTimeString
                           mealStr:(NSString *)mealString
                        timeOffStr:(NSString *)timeOffString
                        regularStr:(NSString *)regularString
                    projectHourStr:(NSString *)projectHourString
           displaySummaryByPayCode:(BOOL)displaySummaryByPayCode;

- (void)selectTaskRadioButton:(id)sender;

- (void)createCellLayoutWithParams:(NSString *)leftString
                   leftLowerString:(NSString *)lowerLeftString
                          rightstr:(NSString *)rightString
                  rightLowerString:(NSString *)lowerRightString
                    radioButtonTag:(NSInteger)tagValue;


@end

@protocol approvalSelectedUserDelegate<NSObject>

@optional
- (void)handleButtonClickforSelectedUser:(NSIndexPath *)indexPath
                              isSelected:(BOOL)isSelected;

@end
