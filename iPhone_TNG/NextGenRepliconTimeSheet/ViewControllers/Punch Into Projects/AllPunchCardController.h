
#import <UIKit/UIKit.h>
#import "RepliconBaseController.h"
#import "PunchCardsListController.h"
#import "TransferPunchCardController.h"

@class PunchCardObject;
@class KSPromise;

@protocol AllPunchCardControllerDelegate;
@class ChildControllerHelper;
@class OEFTypeStorage;
@class TransferPunchCardController;

@interface AllPunchCardController : RepliconBaseController <PunchCardsListControllerDelegate,TransferPunchCardControllerDelegate,PunchAssemblyWorkflowDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic,readonly) UIView *transferCardContainerView;
@property (weak, nonatomic,readonly) UIView *punchCardsListContainerView;
@property (weak, nonatomic,readonly) NSLayoutConstraint *punchCardsListHeightConstraint;
@property (weak, nonatomic,readonly) NSLayoutConstraint *transferPunchCardHeightConstraint;
@property (weak, nonatomic,readonly) UIScrollView *scrollView;

@property (nonatomic,readonly) PunchImagePickerControllerProvider *punchImagePickerControllerProvider;
@property (nonatomic,readonly) TransferPunchCardController *transferPunchCardController;
@property (nonatomic,readonly) id <AllPunchCardControllerDelegate> delegate;
@property (nonatomic,readonly) AllowAccessAlertHelper *allowAccessAlertHelper;
@property (nonatomic,readonly) ChildControllerHelper *childControllerHelper;
@property (nonatomic,readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic,readonly) PunchCardStylist *punchCardStylist;
@property (nonatomic,readonly) ImageNormalizer *imageNormalizer;
@property (nonatomic,readonly) OEFTypeStorage *oefTypeStorage;
@property (nonatomic,readonly) PunchClock *punchClock;
@property (nonatomic, readonly, assign) WorkFlowType flowType;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchImagePickerControllerProvider:(PunchImagePickerControllerProvider *)punchImagePickerControllerProvider
                               transferPunchCardController:(TransferPunchCardController *)transferPunchCardController
                                    allowAccessAlertHelper:(AllowAccessAlertHelper *)allowAccessAlertHelper
                                     childControllerHelper:(ChildControllerHelper *)childControllerHelper
                                      nsNotificationCenter:(NSNotificationCenter *)nsNotificationCenter
                                          punchCardStylist:(PunchCardStylist *)punchCardStylist
                                           imageNormalizer:(ImageNormalizer *)imageNormalizer
                                            oefTypeStorage:(OEFTypeStorage *)oefTypeStorage
                                                punchClock:(PunchClock *)punchClock;


- (void)setUpWithDelegate:(id <AllPunchCardControllerDelegate>)delegate
           controllerType:(PunchCardsControllerType)controllerType
          punchCardObject:(PunchCardObject *)punchCardObject
                 flowType:(WorkFlowType)flowType;

@end

@protocol AllPunchCardControllerDelegate <NSObject>

-(void)allPunchCardController:(AllPunchCardController *)allPunchCardController
willEventuallyFinishIncompletePunch:(LocalPunch *)incompletePunch
       assembledPunchPromise:(KSPromise *)assembledPunchPromise
 serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise;


@end
