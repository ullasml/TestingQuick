#import "TimesheetButtonControllerProvider.h"
#import "TimesheetButtonController.h"
#import "Theme.h"
#import "PreviousApprovalsButtonViewController.h"
#import "UserPermissionsStorage.h"


@interface TimesheetButtonControllerProvider()

@property (nonatomic) ButtonStylist *buttonStylist;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) UserPermissionsStorage *userPermissionStorage;


@end


@implementation TimesheetButtonControllerProvider

- (instancetype)initWithUserPermissionStorage:(UserPermissionsStorage *)userPermissionStorage
                                buttonStylist:(ButtonStylist *) buttonStylist
                                        theme:(id<Theme>) theme
{
    self = [super init];
    if (self) {
        self.buttonStylist = buttonStylist;
        self.theme = theme;
        self.userPermissionStorage = userPermissionStorage;
    }
    return self;
}

- (TimesheetButtonController *)provideInstanceWithDelegate:(id<TimesheetButtonControllerDelegate>)delegate
{
    return [[TimesheetButtonController alloc] initWithUserPermissionStorage:self.userPermissionStorage
                                                              buttonStylist:self.buttonStylist
                                                                   delegate:delegate
                                                                      theme:self.theme];
}


- (PreviousApprovalsButtonViewController *)provideInstanceForApprovalsButtonWithDelegate:(id<PreviousApprovalsButtonControllerDelegate>)delegate
{
    return [[PreviousApprovalsButtonViewController alloc] initWithDelegate:delegate
                                                             buttonStylist:self.buttonStylist
                                                                     theme:self.theme];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


@end
