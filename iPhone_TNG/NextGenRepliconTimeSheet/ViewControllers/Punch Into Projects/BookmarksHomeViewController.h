
#import <UIKit/UIKit.h>
#import "RepliconBaseController.h"
#import "SelectBookmarksViewController.h"

@class ChildControllerHelper;
@protocol BookmarksHomeViewControllerDelegate;
@class PunchCardObject;
@class KSPromise;
@class LocalPunch;

@interface BookmarksHomeViewController : RepliconBaseController <SelectBookmarksViewControllerDelegate>


@property (weak, nonatomic,readonly) UIView *bookmarksListContainerView;

@property (nonatomic,readonly) ChildControllerHelper *childControllerHelper;

@property (weak, nonatomic, readonly) id<BookmarksHomeViewControllerDelegate>delegate;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper;


- (void)setupWithDelegate:(id <BookmarksHomeViewControllerDelegate>)delegate;
@end

@protocol BookmarksHomeViewControllerDelegate <NSObject>

- (void)bookmarksHomeViewController:(BookmarksHomeViewController *)bookmarksHomeViewController
  willEventuallyFinishIncompletePunch:(LocalPunch *)incompletePunch
                assembledPunchPromise:(KSPromise *)assembledPunchPromise
          serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise;

- (void)bookmarksHomeViewController:(BookmarksHomeViewController *)bookmarksHomeViewController
                      updatePunchCard:(PunchCardObject*)punchCardObject;

@end
