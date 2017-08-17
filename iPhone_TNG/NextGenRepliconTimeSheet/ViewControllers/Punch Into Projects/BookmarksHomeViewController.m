#import "BookmarksHomeViewController.h"
#import <Blindside/BSInjector.h>
#import "ChildControllerHelper.h"

@interface BookmarksHomeViewController ()

@property (weak, nonatomic) IBOutlet UIView *bookmarksListContainerView;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) id <BookmarksHomeViewControllerDelegate> delegate;
@property (nonatomic) SelectBookmarksViewController *selectBookmarksViewController;

@property (weak, nonatomic) id<BSInjector> injector;

@end

@implementation BookmarksHomeViewController

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        self.childControllerHelper = childControllerHelper;
    }
    return self;
}

- (void)setupWithDelegate:(id <BookmarksHomeViewControllerDelegate>)delegate
{
    self.delegate = delegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = RPLocalizedString(selectFromBookmarksText, nil);
    self.navigationItem.rightBarButtonItem = [self focusCreateBookmarkButton];

    self.selectBookmarksViewController = [self.injector getInstance:[SelectBookmarksViewController class]];
    [self.selectBookmarksViewController setupWithDelegate:self];
    [self.childControllerHelper addChildController:self.selectBookmarksViewController
                                toParentController:self
                                   inContainerView:self.bookmarksListContainerView];
}

-(UIBarButtonItem*)focusCreateBookmarkButton
{
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                       target:self
                                                                                       action:@selector(focusCreatePunchCardAction:)];
    return  rightBarButtonItem;
}

-(IBAction)focusCreatePunchCardAction:(id)sender
{
    [self.selectBookmarksViewController navigateToCreateBookmarksView];
}

#pragma mark <SelectBookmarksViewControllerDelegate>

- (void)selectBookmarksViewController:(SelectBookmarksViewController *)selectBookmarksViewController
  willEventuallyFinishIncompletePunch:(LocalPunch *)incompletePunch
                assembledPunchPromise:(KSPromise *)assembledPunchPromise
          serverDidFinishPunchPromise:(KSPromise *)serverDidFinishPunchPromise
{
    [self.delegate bookmarksHomeViewController:self willEventuallyFinishIncompletePunch:incompletePunch
                         assembledPunchPromise:assembledPunchPromise
                   serverDidFinishPunchPromise:serverDidFinishPunchPromise];
}

- (void)selectBookmarksViewController:(SelectBookmarksViewController *)selectBookmarksViewController
                      updatePunchCard:(PunchCardObject*)punchCardObject
{
    [self.delegate bookmarksHomeViewController:self updatePunchCard:punchCardObject];
}

- (void)selectBookmarksViewControllerUpdateCardList:(SelectBookmarksViewController *)selectBookmarksViewController
{
    SelectBookmarksViewController *bookmarksViewController = [self.injector getInstance:[SelectBookmarksViewController class]];
    [bookmarksViewController setupWithDelegate:self];
    [self.childControllerHelper replaceOldChildController:self.selectBookmarksViewController
                                   withNewChildController:bookmarksViewController
                                       onParentController:self
                                          onContainerView:self.bookmarksListContainerView];
    self.selectBookmarksViewController = bookmarksViewController;
}

@end
