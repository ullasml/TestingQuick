#import <UIKit/UIKit.h>


@class PunchPresenter;
@protocol Theme;
@protocol Punch;
@protocol PunchDetailsControllerDelegate;
@class UserPermissionsStorage;

@interface PunchDetailsController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak, readonly) UIImageView *selfieImageView;
@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, weak, readonly) UIView *topBorderLineView;
@property (nonatomic, weak, readonly) UIView *bottomBorderLineView;
@property (nonatomic, weak, readonly) UIView *contentView;

@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic, readonly) id<PunchDetailsControllerDelegate> delegate;
@property (nonatomic, readonly) PunchPresenter *punchPresenter;
@property (nonatomic, readonly) id<Punch> punch;
@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                punchPresenter:(PunchPresenter *)punchPresenter
                                         theme:(id<Theme>)theme;
- (void) setUpWithTableViewDelegate:(id<PunchDetailsControllerDelegate>)delegate;


- (void)updateWithPunch:(id<Punch>)punch;

@end


@protocol PunchDetailsControllerDelegate <NSObject>

- (void)punchDetailsController:(PunchDetailsController *)punchDetailsController
  didUpdateTableViewWithHeight:(CGFloat)height;

@optional
- (void)punchDetailsControllerWantsToChangeBreakType:(PunchDetailsController *)punchDetailsController;
- (void)punchDetailsController:(PunchDetailsController *)punchDetailsController
  didIntendToChangeDateOrTimeOfPunch:(id <Punch>)punch;


@end



