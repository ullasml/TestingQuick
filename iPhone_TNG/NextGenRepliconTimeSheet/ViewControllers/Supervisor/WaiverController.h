#import <UIKit/UIKit.h>


@class SelectedWaiverOptionPresenter;
@class ViolationSeverityPresenter;
@class WaiverRepository;
@class Violation;
@class WaiverOption;
@class Waiver;
@protocol Theme;
@protocol SpinnerDelegate;
@protocol WaiverControllerDelegate;



@interface WaiverController : UIViewController

@property (nonatomic, weak, readonly) UILabel *waiverDisplayTextLabel;
@property (nonatomic, weak, readonly) UIImageView *severityImageView;
@property (nonatomic, weak, readonly) UILabel *violationTitleLabel;
@property (nonatomic, weak, readonly) UIView *bottomSeparatorView;
@property (nonatomic, weak, readonly) UILabel *sectionTitleLabel;
@property (nonatomic, weak, readonly) UIView *topSeparatorView;
@property (nonatomic, weak, readonly) UIButton *responseButton;
@property (nonatomic, weak, readonly) UIView *separatorView;

@property (nonatomic, weak, readonly) id<SpinnerDelegate> spinnerDelegate;
@property (nonatomic, weak, readonly) id<WaiverControllerDelegate> delegate;

@property (nonatomic, readonly) WaiverRepository *waiverRepository;

@property (nonatomic, readonly) ViolationSeverityPresenter *violationSeverityPresenter;
@property (nonatomic, readonly) SelectedWaiverOptionPresenter *selectedWaiverOptionPresenter;
@property (nonatomic, readonly) id<Theme> theme;

@property (nonatomic, readonly) Violation *violation;
@property (nonatomic, copy, readonly) NSString *sectionTitle;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSelectedWaiverOptionPresenter:(SelectedWaiverOptionPresenter *)selectedWaiverOptionPresenter
                           violationSeverityPresenter:(ViolationSeverityPresenter *)violationSeverityPresenter
                                     waiverRepository:(WaiverRepository *)waiverRepository
                                      spinnerDelegate:(id <SpinnerDelegate>)spinnerDelegate
                                                theme:(id <Theme>)theme;

- (void)setupWithSectionTitle:(NSString *)sectionTitle
                    violation:(Violation *)violation
                     delegate:(id<WaiverControllerDelegate>)delegate;

@end


@protocol WaiverControllerDelegate <NSObject>

@required

- (void)waiverController:(WaiverController *)waiverController
   didSelectWaiverOption:(WaiverOption *)waiverOption
               forWaiver:(Waiver *)waiver;

@end
