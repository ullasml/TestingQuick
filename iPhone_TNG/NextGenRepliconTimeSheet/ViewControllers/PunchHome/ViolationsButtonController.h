#import <UIKit/UIKit.h>


@class KSPromise;
@class ButtonStylist;
@class AllViolationSections;
@protocol Theme;
@protocol ViolationsButtonControllerDelegate;


@interface ViolationsButtonController : UIViewController

@property (weak, nonatomic, readonly) UIButton *violationsButton;

@property (nonatomic, readonly) id<Theme> theme;
@property (weak, nonatomic, readonly) id<ViolationsButtonControllerDelegate> delegate;

@property (nonatomic, readonly) ButtonStylist *buttonStylist;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithButtonStylist:(ButtonStylist *)buttonStylist
                                theme:(id<Theme>)theme;

- (void)setupWithDelegate:(id<ViolationsButtonControllerDelegate>)delegate showViolations:(BOOL)showViolations;

- (void)reloadData;

@end


@protocol ViolationsButtonControllerDelegate <NSObject>

- (NSLayoutConstraint *)violationsButtonHeightConstraint;

- (KSPromise *)violationsButtonControllerDidRequestUpdatedViolationSectionsPromise:(ViolationsButtonController *)violationsButtonController;

- (void) violationsButtonController:(ViolationsButtonController *)violationsButtonController
didSignalIntentToViewViolationSections:(AllViolationSections *)allViolationSections;

@end
