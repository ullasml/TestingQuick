
#import <UIKit/UIKit.h>
#import "PunchActionTypes.h"
#import "OEFCardViewController.h"
#import "RepliconBaseController.h"

@class    ChildControllerHelper;
@class    OEFTypeStorage;
@class    AppDelegate;

@protocol OEFCollectionPopUpViewControllerDelegate;
@protocol UserSession;
@protocol Theme;


@interface OEFCollectionPopUpViewController : UIViewController <OEFCardViewControllerDelegate>

@property (weak, nonatomic, readonly) id<OEFCollectionPopUpViewControllerDelegate>delegate;

@property (weak, nonatomic,readonly)  UIView                    *backgroundView;
@property (weak, nonatomic,readonly)  UIView                    *cardContainerView;
@property (weak, nonatomic,readonly)  UIView                    *containerView;
@property (weak, nonatomic,readonly)  UIScrollView              *scrollView;

@property (nonatomic, readonly) ChildControllerHelper           *childControllerHelper;
@property (nonatomic, readonly) UIApplication                   *sharedApplication;
@property (nonatomic,readonly)  NSNotificationCenter            *notificationCenter;
@property (nonatomic, readonly) OEFTypeStorage                  *oefTypeStorage;
@property (nonatomic, readonly) id<UserSession>                 userSession;

@property (weak, nonatomic,readonly)  NSLayoutConstraint        *widthConstraint;
@property (weak, nonatomic,readonly)  NSLayoutConstraint        *oefCardHeightConstraint;
@property (nonatomic, readonly) id<Theme>                       theme ;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                         nsNotificationCenter:(NSNotificationCenter *)nsNotificationCenter
                               oefTypeStorage:(OEFTypeStorage *)oefTypeStorage
                                uiApplication:(UIApplication *)uiApplication
                                  userSession:(id <UserSession>)userSession
                                        theme:(id <Theme>)theme;

- (void)setupWithOEFCollectionPopUpViewControllerDelegate:(id<OEFCollectionPopUpViewControllerDelegate>)delegate
                                          punchActionType:(PunchActionType)punchActionType;
@end

@protocol OEFCollectionPopUpViewControllerDelegate <NSObject>

- (void)oefCollectionPopUpViewController:(OEFCollectionPopUpViewController *)punchCardController
                       didIntendToUpdate:(PunchCardObject *)punchCardObject
                         punchActionType:(PunchActionType)punchActionType;

@end
