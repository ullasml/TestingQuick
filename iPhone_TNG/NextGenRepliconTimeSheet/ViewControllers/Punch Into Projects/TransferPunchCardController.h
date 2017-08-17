
#import <UIKit/UIKit.h>
#import "SelectionController.h"
#import "RepliconBaseController.h"
#import "UserPermissionsStorage.h"
#import "DynamicTextTableViewCell.h"

@protocol Theme;
@protocol TransferPunchCardControllerDelegate;
@protocol UserSession;

@class PunchCardObject;
@class PunchCardStylist;
@class GUIDProvider;


@interface TransferPunchCardController : RepliconBaseController<UITableViewDataSource,UITableViewDelegate,SelectionControllerDelegate, DynamicTextTableViewCellDelegate>

@property (nonatomic, weak, readonly) UITableView *tableView;
@property (nonatomic, weak, readonly) UIButton *transferPunchCardButton;
@property (nonatomic,readonly) SelectionController *selectionController;
@property (nonatomic,readonly) PunchCardStylist *punchCardStylist;
@property (nonatomic,weak,readonly) id <TransferPunchCardControllerDelegate> delegate;
@property (nonatomic,readonly) PunchCardObject *punchCardObject;
@property (nonatomic, readonly) PunchCardObject *localPunchCardObject;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic,readonly) UserPermissionsStorage *userPermissionStorage;
@property (nonatomic, readonly) NSArray *oefTypesArray;
@property (nonatomic, readonly) GUIDProvider *guidProvider;
@property (nonatomic, readonly) NSString  *selectedDropDownOEFUri;
@property (nonatomic, assign, readonly) BOOL                                   alertViewVisible;
@property (nonatomic, assign, readonly)WorkFlowType                           flowType;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSelectionController:(SelectionController *)selectionController
                      userPermissionStorage:(UserPermissionsStorage *)userPermissionStorage
                           punchCardStylist:(PunchCardStylist *)punchCardStylist
                               guidProvider:(GUIDProvider *)guidProvider
                                userSession:(id <UserSession>)userSessiont;

- (void)setUpWithDelegate:(id <TransferPunchCardControllerDelegate>)delegate
          punchCardObject:(PunchCardObject *)punchCardObject
                 oefTypes:(NSArray *)oefTypes
                 flowType:(WorkFlowType)flowType;

- (void)updatePunchCardObject:(PunchCardObject *)punchCardObject;
@end

@protocol TransferPunchCardControllerDelegate<NSObject>

- (void)transferPunchCardController:(TransferPunchCardController *)transferPunchCardController didIntendToTransferPunchWithObject:(PunchCardObject *)punchCardObject;

- (void)transferPunchCardController:(TransferPunchCardController *)punchCardController didUpdateHeight:(CGFloat)height;

- (void)transferPunchCardController:(TransferPunchCardController *)transferPunchCardController didScrolltoSubview:(id)subview;

- (void)transferPunchCardController:(TransferPunchCardController *)transferPunchCardController didIntendToResumeWorkForProjectPunchWithObject:(PunchCardObject *)punchCardObject;

- (void)transferPunchCardController:(TransferPunchCardController *)transferPunchCardController didIntendToResumeWorkForActivityPunchWithObject:(PunchCardObject *)punchCardObject;

@end
