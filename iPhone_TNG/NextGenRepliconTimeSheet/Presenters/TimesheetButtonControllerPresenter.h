#import <Foundation/Foundation.h>

@class TimesheetButtonController;
@class TimesheetButtonControllerProvider;
@protocol TimesheetButtonControllerDelegate;
@protocol PreviousApprovalsButtonControllerDelegate;

@interface TimesheetButtonControllerPresenter : NSObject

@property (nonatomic, readonly) TimesheetButtonControllerProvider *timesheetButtonControllerProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTimesheetButtonControllerProvider:(TimesheetButtonControllerProvider *)timesheetButtonControllerProvider NS_DESIGNATED_INITIALIZER;

- (void)presentTimesheetButtonControllerInContainer:(UIView *)viewContainer
                                 onParentController:(UIViewController *)parentController
                                           delegate:(id<TimesheetButtonControllerDelegate>)delegate
                                              title:(NSString *)title;

- (void)presentTimesheetButtonControllerInContainer:(UIView *)containerView
                                 onParentController:(UIViewController *)parentController
                                           delegate:(id<TimesheetButtonControllerDelegate>)delegate;

- (void)presentPreviousApprovalsButtonControllerInContainer:(UIView *)containerView
                                         onParentController:(UIViewController *)parentController
                                                   delegate:(id<PreviousApprovalsButtonControllerDelegate>)delegate;
@end
