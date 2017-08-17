
#import <UIKit/UIKit.h>
#import "SelectionController.h"
#import "RepliconBaseController.h"
#import "DynamicTextTableViewCell.h"

@protocol Theme;
@protocol PunchCardControllerDelegate;
@protocol UserSession;


@class PunchCardObject;
@class PunchCardStylist;
@class UserPermissionsStorage;
@class DefaultActivityStorage;

@interface PunchCardController : RepliconBaseController<UITableViewDataSource,UITableViewDelegate,SelectionControllerDelegate,DynamicTextTableViewCellDelegate>

@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, weak, readonly) UIButton *createPunchCardButton;
@property (nonatomic, weak, readonly) UIButton *punchActionButton;
@property (nonatomic,readonly) SelectionController *selectionController;
@property (nonatomic,readonly) PunchCardStylist *punchCardStylist;
@property (nonatomic,readonly) UserPermissionsStorage *userPermissionStorage;
@property (nonatomic,readonly) DefaultActivityStorage *defaultActivityStorage;

@property (nonatomic,weak,readonly) id <PunchCardControllerDelegate> delegate;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic, readonly) NSArray *oefTypesArray;
@property (nonatomic, readonly) PunchCardObject *punchCardObject;
@property (nonatomic, readonly) NSString *selectedDropDownOEFUri;

@property (weak, nonatomic, readonly) NSLayoutConstraint *tableViewTopPaddingConstraint;
@property (nonatomic, assign, readonly) BOOL                                   alertViewVisible;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSelectionController:(SelectionController *)selectionController
                      userPermissionStorage:(UserPermissionsStorage *)userPermissionStorage
                     defaultActivityStorage:(DefaultActivityStorage *)defaultActivityStorage
                           punchCardStylist:(PunchCardStylist *)punchCardStylist
                                userSession:(id <UserSession>)userSession;

- (void)setUpWithPunchCardObject:(PunchCardObject *)punchCardObject punchCardType:(PunchCardType)punchCardType delegate:(id <PunchCardControllerDelegate>)delegate oefTypesArray:(NSArray *)oefTypesArray;

@end

@protocol PunchCardControllerDelegate<NSObject>

@optional

- (void)punchCardController:(PunchCardController *)punchCardController didChooseToCreatePunchCardWithObject:(PunchCardObject *)punchCardObject;

- (void)punchCardController:(PunchCardController *)punchCardController didIntendToPunchWithObject:(PunchCardObject *)punchCardObject;


- (void)punchCardController:(PunchCardController *)punchCardController didUpdatePunchCardWithObject:(PunchCardObject *)punchCardObject;

- (void)punchCardController:(PunchCardController *)punchCardController didUpdateHeight:(CGFloat)height;

- (void)punchCardController:(PunchCardController *)punchCardController didScrolltoSubview:(id)subview;

@end
