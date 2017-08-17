
#import <UIKit/UIKit.h>
#import "RepliconBaseController.h"
#import "PunchRepository.h"
#import "PunchAssemblyWorkflow.h"

@class PunchCardStorage;
@class PunchCardObject;
@class KSPromise;
@class UserPermissionsStorage;

@protocol PunchCardsListControllerDelegate;
@protocol UserSession;
@class PunchClock;
@class PunchImagePickerControllerProvider;
@class AllowAccessAlertHelper;
@class ImageNormalizer;
@class ChildControllerHelper;
@class TimeLinePunchesStorage;
@class BookmarkValidationRepository;

@interface PunchCardsListController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic,readonly) UITableView *tableView;
@property (nonatomic,readonly) id<Theme> theme;


@property (nonatomic,readonly) id <PunchCardsListControllerDelegate> delegate;

@property (nonatomic,readonly) PunchCardStorage *punchCardStorage;
@property (nonatomic,readonly) TimeLinePunchesStorage *timeLinePunchStorage;
@property (nonatomic,readonly) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic,readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic, readonly) BookmarkValidationRepository *bookmarkValidationRepository;
@property (nonatomic, readonly) NSMutableArray *tableRows;



+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                       userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                             punchCardStorage:(PunchCardStorage *)punchCardStorage
                         timeLinePunchStorage:(TimeLinePunchesStorage *)timeLinePunchStorage
                                        theme:(id <Theme>)theme
                 bookmarkValidationRepository:(BookmarkValidationRepository*)bookmarkValidationRepository NS_DESIGNATED_INITIALIZER;

- (void)setUpWithDelegate:(id <PunchCardsListControllerDelegate>)delegate;

@end

@protocol PunchCardsListControllerDelegate <NSObject>


-(void)punchCardsListController:(PunchCardsListController *)punchCardsListController didIntendToTransferUsingPunchCard:(PunchCardObject *)punchCard;

-(void)punchCardsListController:(PunchCardsListController *)punchCardsListController didIntendToPunchInUsingPunchCard:(PunchCardObject *)punchCard;

-(void)punchCardsListController:(PunchCardsListController *)punchCardsListController didUpdateHeight:(CGFloat)height;

@optional

-(void)punchCardsListController:(PunchCardsListController *)punchCardsListController
     didIntendToUpdatePunchCard:(PunchCardObject *)punchCardObject;

- (void)punchCardsListController:(PunchCardsListController *)punchCardsListController
didFindPunchCardAsInvalidPunchCard:(PunchCardObject *)punchCardObject;

@end
