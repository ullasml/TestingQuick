#import "ApprovalsPendingExpenseViewControllerProvider.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "ApprovalsModel.h"

@interface ApprovalsPendingExpenseViewControllerProvider ()

@property (nonatomic) NSNotificationCenter *notificationCenter;

@end

@implementation ApprovalsPendingExpenseViewControllerProvider

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter
{
    self = [super init];
    if(self)
    {
        self.notificationCenter = notificationCenter;
    }

    return self;
}
- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(ApprovalsPendingExpenseViewController *)provideInstance
{
    return [[ApprovalsPendingExpenseViewController alloc] initWithNotificationCenter:self.notificationCenter
                                                                     spinnerDelegate:nil
                                                                    approvalsService:nil
                                                                      approvalsModel:nil
                                                                          loginModel:nil];
}

@end
