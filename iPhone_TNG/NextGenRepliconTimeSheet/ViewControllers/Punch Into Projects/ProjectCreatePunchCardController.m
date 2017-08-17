#import "ProjectCreatePunchCardController.h"
#import "Theme.h"
#import <Blindside/BSInjector.h>
#import "ChildControllerHelper.h"
#import "InjectorKeys.h"
#import "PunchCardController.h"
#import "PunchCardObject.h"
#import "Constants.h"

@interface ProjectCreatePunchCardController ()

@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) NSTimer *timer;

@property (weak, nonatomic) id<ProjectCreatePunchCardControllerDelegate> delegate;

@property (weak, nonatomic) id<BSInjector> injector;

@property (weak, nonatomic) IBOutlet UIView *cardContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *punchCardHeightConstraint;
@end


@implementation ProjectCreatePunchCardController

- (instancetype)initWithChildControllerHelper:(ChildControllerHelper *)childControllerHelper
                                        theme:(id <Theme>)theme {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.childControllerHelper = childControllerHelper;
        self.theme = theme;
    }
    return self;
}

- (void)setupWithDelegate:(id <ProjectCreatePunchCardControllerDelegate>)delegate {
    self.delegate = delegate;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = RPLocalizedString(createBookmarksText, createBookmarksText);
    self.cardContainerView.backgroundColor = [self.theme childControllerDefaultBackgroundColor];

    PunchCardController *punchCardController = [self.injector getInstance:[PunchCardController class]];
    [punchCardController setUpWithPunchCardObject:nil punchCardType:DefaultClientProjectTaskPunchCard delegate:self oefTypesArray:nil];
    [self.childControllerHelper addChildController:punchCardController
                                toParentController:self
                                   inContainerView:self.cardContainerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - <PunchCardControllerDelegate>

- (void)punchCardController:(PunchCardController *)punchCardController didChooseToCreatePunchCardWithObject:(PunchCardObject *)punchCardObject
{
    [self.delegate projectCreatePunchCardController:self didChooseToCreatePunchCardWithObject:punchCardObject];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)punchCardController:(PunchCardController *)punchCardController didUpdateHeight:(CGFloat)height
{
    self.punchCardHeightConstraint.constant = height;
}

@end
