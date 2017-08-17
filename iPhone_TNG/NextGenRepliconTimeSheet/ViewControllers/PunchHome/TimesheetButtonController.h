#import <UIKit/UIKit.h>


@protocol Theme;
@protocol TimesheetButtonControllerDelegate;
@class ButtonStylist;


@interface TimesheetButtonController : UIViewController

@property (nonatomic, readonly) ButtonStylist *buttonStylist;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, weak, readonly) id <TimesheetButtonControllerDelegate>delegate;
@property (weak, nonatomic, readonly) UIButton *viewTimeSheetPeriodButton;
@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;



+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserPermissionStorage:(UserPermissionsStorage *)userPermissionStorage
                                buttonStylist:(ButtonStylist *)buttonStylist
                                     delegate:(id <TimesheetButtonControllerDelegate>)delegate
                                        theme:(id <Theme>)theme NS_DESIGNATED_INITIALIZER;

@end


@protocol TimesheetButtonControllerDelegate <NSObject>

- (void) timesheetButtonControllerWillNavigateToTimesheetDetailScreen:(TimesheetButtonController *) timesheetButtonController;

- (void) timesheetButtonControllerWillNavigateToWidgetTimesheetDetailScreen:(TimesheetButtonController *) timesheetButtonController;


@end
