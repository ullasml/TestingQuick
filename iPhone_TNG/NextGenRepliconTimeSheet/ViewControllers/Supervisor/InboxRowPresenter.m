#import "InboxRowPresenter.h"

@interface InboxRowPresenter ()

@property (nonatomic) NSString *text;
@property (nonatomic) UIViewController *controller;

@end

@implementation InboxRowPresenter

- (instancetype)initWithText:(NSString *)text controller:(UIViewController *)controller
{
    self = [super init];
    if (self) {
        self.text = text;
        self.controller = controller;
    }
    return self;
}

@end
