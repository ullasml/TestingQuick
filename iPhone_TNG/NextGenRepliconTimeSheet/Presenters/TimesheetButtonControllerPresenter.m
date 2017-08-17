#import "TimesheetButtonControllerPresenter.h"
#import "TimesheetButtonController.h"
#import "TimesheetButtonControllerProvider.h"
#import "PreviousApprovalsButtonViewController.h"


@interface TimesheetButtonControllerPresenter ()

@property (nonatomic) TimesheetButtonControllerProvider *timesheetButtonControllerProvider;

@end


@implementation TimesheetButtonControllerPresenter

- (instancetype)initWithTimesheetButtonControllerProvider:(TimesheetButtonControllerProvider *)timesheetButtonControllerProvider
{
    self = [super init];
    if (self) {
        self.timesheetButtonControllerProvider = timesheetButtonControllerProvider;
    }

    return self;
}

- (void)presentTimesheetButtonControllerInContainer:(UIView *)containerView
                                 onParentController:(UIViewController *)parentController
                                           delegate:(id<TimesheetButtonControllerDelegate>)delegate
                                              title:(NSString *)title
{

    TimesheetButtonController *timesheetButtonController = [self.timesheetButtonControllerProvider provideInstanceWithDelegate:delegate];
    timesheetButtonController.title = title;

    [parentController addChildViewController:timesheetButtonController];
    timesheetButtonController.view.frame = containerView.bounds;
    [containerView addSubview:timesheetButtonController.view];

    [timesheetButtonController didMoveToParentViewController:parentController];
}

- (void)presentTimesheetButtonControllerInContainer:(UIView *)containerView
                                 onParentController:(UIViewController *)parentController
                                           delegate:(id<TimesheetButtonControllerDelegate>)delegate
{

    TimesheetButtonController *timesheetButtonController = [self.timesheetButtonControllerProvider provideInstanceWithDelegate:delegate];
    [parentController addChildViewController:timesheetButtonController];
    timesheetButtonController.view.frame = containerView.bounds;
    [containerView addSubview:timesheetButtonController.view];

    [timesheetButtonController didMoveToParentViewController:parentController];
}

- (void)presentPreviousApprovalsButtonControllerInContainer:(UIView *)containerView
                                         onParentController:(UIViewController *)parentController
                                                   delegate:(id<PreviousApprovalsButtonControllerDelegate>)delegate
{
    
    PreviousApprovalsButtonViewController *previousApprovalsButtonViewController = [self.timesheetButtonControllerProvider provideInstanceForApprovalsButtonWithDelegate:delegate];
    [parentController addChildViewController:previousApprovalsButtonViewController];
    previousApprovalsButtonViewController.view.frame = containerView.bounds;
    [containerView addSubview:previousApprovalsButtonViewController.view];
    
    [previousApprovalsButtonViewController didMoveToParentViewController:parentController];
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
