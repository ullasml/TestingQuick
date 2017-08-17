#import <UIKit/UIKit.h>
#import "RepliconBaseController.h"
#import "ProjectCreatePunchCardController.h"
#import "AllPunchCardController.h"

@protocol SelectBookmarksViewControllerDelegate;
@protocol UserSession;

@class PunchCardStorage;
@class PunchCardObject;
@class KSPromise;
@class UserPermissionsStorage;
@class TimeLinePunchesStorage;
@protocol Theme;
@class BookmarkValidationRepository;


@interface SelectBookmarksViewController : UIViewController <UITableViewDelegate,UITableViewDataSource, ProjectCreatePunchCardControllerDelegate, AllPunchCardControllerDelegate>

@property (weak, nonatomic, readonly) id<SelectBookmarksViewControllerDelegate>delegate;

@property (weak, nonatomic,readonly) UITableView                          *tableView;
@property (weak, nonatomic,readonly) UILabel                              *noBookmarksTitleLabel;
@property (weak, nonatomic,readonly) UILabel                              *noBookmarksDescriptionLabel;

@property (nonatomic,readonly) PunchCardStorage                           *punchCardStorage;
@property (nonatomic,readonly) UserPermissionsStorage                     *userPermissionsStorage;
@property (nonatomic,readonly) TimeLinePunchesStorage                     *timeLinePunchStorage;
@property (nonatomic, readonly) id<Theme>                                 theme ;
@property (nonatomic, readonly) BookmarkValidationRepository              *bookmarkValidationRepository;
@property (nonatomic, readonly) NSMutableArray                            *tableRows;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (void)setupWithDelegate:(id <SelectBookmarksViewControllerDelegate>)delegate;

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                          timeLinePunchStorage:(TimeLinePunchesStorage *)timeLinePunchStorage
                              punchCardStorage:(PunchCardStorage *)punchCardStorage
                                         theme:(id <Theme>)theme
                  bookmarkValidationRepository:(BookmarkValidationRepository *)bookmarkValidationRepository;

-(void)navigateToCreateBookmarksView;
@end

@protocol SelectBookmarksViewControllerDelegate <NSObject>

- (void)selectBookmarksViewController:(SelectBookmarksViewController *)selectBookmarksViewController
  willEventuallyFinishIncompletePunch:(LocalPunch *)incompletePunch
                assembledPunchPromise:(KSPromise *)assembledPunchPromise
          serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise;

- (void)selectBookmarksViewController:(SelectBookmarksViewController *)selectBookmarksViewController
                      updatePunchCard:(PunchCardObject*)punchCardObject;

- (void)selectBookmarksViewControllerUpdateCardList:(SelectBookmarksViewController *)selectBookmarksViewController;


@end
