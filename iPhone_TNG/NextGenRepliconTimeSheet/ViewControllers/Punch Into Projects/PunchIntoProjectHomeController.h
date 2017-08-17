#import <UIKit/UIKit.h>
#import "ProjectPunchInController.h"
#import "ProjectPunchOutController.h"
#import "ProjectOnBreakController.h"
#import "PunchClock.h"
#import "PunchAssemblyWorkflow.h"
#import "PunchRepository.h"
#import "CameraButtonController.h"
#import "CameraViewController.h"
#import "ServerMostRecentPunchProtocol.h"
#import "AllPunchCardController.h"
#import "MostRecentActivityPunchDetector.h"
#import "PunchIntoProjectHomeController.h"
#import "OEFCollectionPopUpViewController.h"
#import "Punch.h"
#import "BookmarksHomeViewController.h"

@class PunchImagePickerControllerProvider;
@class PunchIntoProjectControllerProvider;
@class MostRecentPunchInDetector;
@class UserPermissionsStorage;
@class AllowAccessAlertHelper;
@class ImageNormalizer;
@class OEFTypeStorage;

@interface PunchIntoProjectHomeController : UIViewController <ProjectPunchInControllerDelegate, ProjectPunchOutControllerDelegate, ProjectOnBreakControllerDelegate, PunchAssemblyWorkflowDelegate, PunchRepositoryObserver,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ServerMostRecentPunchProtocol,AllPunchCardControllerDelegate,SelectionControllerDelegate, OEFCollectionPopUpViewControllerDelegate, BookmarksHomeViewControllerDelegate>

@property (nonatomic, readonly) PunchImagePickerControllerProvider *punchImagePickerControllerProvider;
@property (nonatomic, readonly) PunchIntoProjectControllerProvider *punchControllerProvider;
@property (nonatomic, readonly) AllowAccessAlertHelper *allowAccessAlertHelper;
@property (nonatomic, readonly) ImageNormalizer *imageNormalizer;
@property (nonatomic, readonly) PunchRepository *punchRepository;
@property (nonatomic, readonly) PunchClock *punchClock;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic, readonly) PunchCardStorage *punchCardStorage;
@property (nonatomic, readonly) MostRecentPunchInDetector *mostRecentPunchInDetector;
@property (nonatomic, readonly) MostRecentActivityPunchDetector *mostRecentActivityPunchDetector;
@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic, readonly) OEFTypeStorage *oefTypeStorage;
@property (nonatomic, readonly) DateProvider *dateProvider;
@property (nonatomic, readonly)  NSArray *timelinePunches;
@property (nonatomic, readonly) id <Punch> mostRecentPunch;
@property (nonatomic,assign,readonly) BOOL firstTimeUser;
@property (nonatomic,assign,readonly) BOOL isUserCreatingPunchCard;
@property (nonatomic, readonly) PunchCardObject *punchCardObject;
@property (nonatomic, readonly) TimeLinePunchesStorage *timeLinePunchesStorage;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchImagePickerControllerProvider:(PunchImagePickerControllerProvider *)punchImagePickerControllerProvider mostRecentActivityPunchDetector:(MostRecentActivityPunchDetector *)mostRecentActivityPunchDetector mostRecentPunchInDetector:(MostRecentPunchInDetector *)mostRecentPunchInDetector punchControllerProvider:(PunchIntoProjectControllerProvider *)punchControllerProvider allowAccessAlertHelper:(AllowAccessAlertHelper *)allowAccessAlertHelper userPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage punchCardStorage:(PunchCardStorage *)punchCardStorage imageNormalizer:(ImageNormalizer *)imageNormalizer punchRepository:(PunchRepository *)punchRepository oefTypeStorage:(OEFTypeStorage *)oefTypeStorage userSession:(id <UserSession>)userSession dateProvider:(DateProvider *)dateProvider punchClock:(PunchClock *)punchClock timeLinePunchesStorage:(TimeLinePunchesStorage *)timeLinePunchesStorage;



@end
