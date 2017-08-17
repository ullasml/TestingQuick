#import <Foundation/Foundation.h>

@class ButtonStylist;
@class TimesheetButtonController;
@protocol TimesheetButtonControllerDelegate;
@protocol PreviousApprovalsButtonControllerDelegate;
@protocol Theme;
@class  PreviousApprovalsButtonViewController;
@class UserPermissionsStorage;

@interface TimesheetButtonControllerProvider : NSObject

@property (nonatomic, readonly) ButtonStylist *buttonStylist;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) UserPermissionsStorage *userPermissionStorage;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserPermissionStorage:(UserPermissionsStorage *)userPermissionStorage
                                buttonStylist:(ButtonStylist *) buttonStylist
                                        theme:(id<Theme>) theme NS_DESIGNATED_INITIALIZER;

- (TimesheetButtonController *)provideInstanceWithDelegate:(id<TimesheetButtonControllerDelegate>)delegate;

- (PreviousApprovalsButtonViewController *)provideInstanceForApprovalsButtonWithDelegate:(id<PreviousApprovalsButtonControllerDelegate>)delegate;
@end
