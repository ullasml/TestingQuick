#import <UIKit/UIKit.h>


@protocol ApprovalsPendingTimeOffTableViewHeaderDelegate;


@interface ApprovalsPendingTimeOffTableViewHeader : UITableViewHeaderFooterView

@property (weak, nonatomic, readonly) UIButton *rejectButton;
@property (weak, nonatomic, readonly) UIButton *approveButton;
@property (weak, nonatomic, readonly) UIView *separatorView;
@property (weak, nonatomic, readonly)  UIButton *toggleButton;

@property (weak, nonatomic) id<ApprovalsPendingTimeOffTableViewHeaderDelegate> delegate;

- (IBAction)didToggleButtonForSelectOrClearAll:(id)sender;

@end


@protocol ApprovalsPendingTimeOffTableViewHeaderDelegate <NSObject>

- (void)approvalsPendingTimeOffTableViewHeaderDidSignalIntentToApprove:(ApprovalsPendingTimeOffTableViewHeader *)approvalsPendingTimeOffTableViewHeader;
- (void)approvalsPendingTimeOffTableViewHeaderDidSignalIntentToReject:(ApprovalsPendingTimeOffTableViewHeader *)approvalsPendingTimeOffTableViewHeader;
- (void)approvalsPendingTimeOffTableViewHeaderDidSignalIntentToSelectAll:(ApprovalsPendingTimeOffTableViewHeader *)approvalsPendingTimeOffTableViewHeader;
- (void)approvalsPendingTimeOffTableViewHeaderDidSignalIntentToClearAll:(ApprovalsPendingTimeOffTableViewHeader *)approvalsPendingTimeOffTableViewHeader;
@end