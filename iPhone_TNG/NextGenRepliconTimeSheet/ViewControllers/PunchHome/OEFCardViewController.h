#import <UIKit/UIKit.h>
#import "RepliconBaseController.h"
#import "DynamicTextTableViewCell.h"
#import "ButtonStylist.h"
#import "PunchActionTypes.h"
#import "SelectionController.h"

@protocol Theme;
@protocol UserSession;
@protocol OEFCardViewControllerDelegate;

@class UserPermissionsStorage;
@class DefaultActivityStorage;
@class TimeLinePunchesStorage;
@class BreakTypeRepository;
@class PunchCardStylist;
@class PunchCardObject;
@class GUIDProvider;

@interface OEFCardViewController : RepliconBaseController <UITableViewDataSource, UITableViewDelegate, DynamicTextTableViewCellDelegate, SelectionControllerDelegate>

@property (nonatomic, weak, readonly) UIButton                  *punchActionButton;
@property (nonatomic, weak, readonly) UIButton                  *cancelButton;
@property (nonatomic, weak, readonly) UITableView               *tableView;

@property (nonatomic, readonly) DefaultActivityStorage          *defaultActivityStorage;
@property (nonatomic, readonly) TimeLinePunchesStorage          *timeLinePunchesStorage;
@property (nonatomic, readonly) NSString                        *selectedDropDownOEFUri;
@property (nonatomic, readonly) UserPermissionsStorage          *userPermissionStorage;
@property (nonatomic, readonly) BreakTypeRepository             *breakTypeRepository;
@property (nonatomic,readonly)  PunchCardStylist                *punchCardStylist;
@property (nonatomic, readonly) PunchCardObject                 *punchCardObject;
@property (nonatomic, readonly) NSArray                         *oefTypesArray;
@property (nonatomic, readonly) GUIDProvider                    *guidProvider;
@property (nonatomic, readonly) id<UserSession>                 userSession;
@property (nonatomic, assign, readonly) BOOL                                   alertViewVisible;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                        defaultActivityStorage:(DefaultActivityStorage *)defaultActivityStorage
                        timeLinePunchesStorage:(TimeLinePunchesStorage *)timeLinePunchesStorage
                           breakTypeRepository:(BreakTypeRepository *)breakTypeRepository
                              punchCardStylist:(PunchCardStylist *)punchCardStylist
                                 buttonStylist:(ButtonStylist *)buttonStylist
                                  guidProvider:(GUIDProvider *)guidProvider
                                   userSession:(id <UserSession>)userSession;

- (void)setUpWithDelegate:(id <OEFCardViewControllerDelegate>)delegate
                        punchActionType:(PunchActionType)punchActionType
                          oefTypesArray:(NSArray *)oefTypesArray;
@end

@protocol OEFCardViewControllerDelegate<NSObject>

@optional

- (void)oefCardViewController:(OEFCardViewController *)oefCardViewController didIntendToSave:(PunchCardObject *)punchCardObject;

- (void)oefCardViewController:(OEFCardViewController *)oefCardViewController didUpdateHeight:(CGFloat)height;

- (void)oefCardViewController:(OEFCardViewController *)oefCardViewController didScrolltoSubview:(id)subview;

- (void)oefCardViewController:(OEFCardViewController *)oefCardViewController cancelButton:(id)button;

@end
