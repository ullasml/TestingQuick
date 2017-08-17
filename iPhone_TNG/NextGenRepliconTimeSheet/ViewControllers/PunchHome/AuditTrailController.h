#import <UIKit/UIKit.h>


@class RemotePunch;
@class PunchLogRepository;
@protocol Theme;
@protocol AuditTrailControllerDelegate;


@interface AuditTrailController : UIViewController

@property (nonatomic, weak, readonly) UITableView *tableView;

@property (nonatomic, readonly) PunchLogRepository *punchLogsRepository;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic,weak, readonly) UIView *topLineView;
@property (nonatomic, readonly) RemotePunch *punch;
@property (nonatomic, weak, readonly) id<AuditTrailControllerDelegate> delegate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;


- (instancetype)initWithPunchLogsRepository:(PunchLogRepository *)punchLogsRepository
                                      theme:(id<Theme>)theme;

- (void)setupWithPunch:(RemotePunch *)punch delegate:(id<AuditTrailControllerDelegate>)delegate;

@end


@protocol AuditTrailControllerDelegate

- (void) auditTrailController:(AuditTrailController *)auditTrailController didUpdateHeight:(CGFloat)height;

@end
