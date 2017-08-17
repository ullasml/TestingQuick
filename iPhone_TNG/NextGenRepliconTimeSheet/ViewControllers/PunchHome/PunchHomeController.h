#import <UIKit/UIKit.h>
#import "PunchInController.h"
#import "PunchOutController.h"
#import "OnBreakController.h"
#import "PunchClock.h"
#import "PunchAssemblyWorkflow.h"
#import "PunchRepository.h"
#import "ServerMostRecentPunchProtocol.h"


@class PunchImagePickerControllerProvider;
@class PunchControllerProvider;
@class AllowAccessAlertHelper;
@class ImageNormalizer;
@class OEFTypeStorage;


@interface PunchHomeController : UIViewController <PunchInControllerDelegate, PunchOutControllerDelegate, OnBreakControllerDelegate, PunchAssemblyWorkflowDelegate, PunchRepositoryObserver,ServerMostRecentPunchProtocol,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, readonly) PunchImagePickerControllerProvider *punchImagePickerControllerProvider;
@property (nonatomic, readonly) PunchControllerProvider *punchControllerProvider;
@property (nonatomic, readonly) AllowAccessAlertHelper *allowAccessAlertHelper;
@property (nonatomic, readonly) ImageNormalizer *imageNormalizer;
@property (nonatomic, readonly) PunchRepository *punchRepository;
@property (nonatomic, readonly) PunchClock *punchClock;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic, readonly) OEFTypeStorage *oefTypeStorage;
@property (nonatomic, readonly) id <Punch> mostRecentPunch;
@property (nonatomic, readonly) NSArray *timelinePunches;
@property (nonatomic,assign,readonly) BOOL firstTimeUser;
@property (nonatomic, readonly) TimeLinePunchesStorage *timeLinePunchesStorage;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchImagePickerControllerProvider:(PunchImagePickerControllerProvider *)punchImagePickerControllerProvider punchControllerProvider:(PunchControllerProvider *)punchControllerProvider allowAccessAlertHelper:(AllowAccessAlertHelper *)allowAccessAlertHelper imageNormalizer:(ImageNormalizer *)imageNormalizer punchRepository:(PunchRepository *)punchRepository oefTypeStorage:(OEFTypeStorage *)oefTypeStorage userSession:(id <UserSession>)userSession punchClock:(PunchClock *)punchClock timeLinePunchesStorage:(TimeLinePunchesStorage *)timeLinePunchesStorage;


@end
