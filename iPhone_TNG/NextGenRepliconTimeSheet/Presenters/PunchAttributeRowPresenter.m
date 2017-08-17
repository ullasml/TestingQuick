
#import "PunchAttributeRowPresenter.h"

@interface PunchAttributeRowPresenter ()

@property (nonatomic,copy) NSString *text;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,assign) PunchAttribute punchAttributeType;

@end

@implementation PunchAttributeRowPresenter

- (instancetype)initWithRowType:(PunchAttribute )punchAttributeType
                          title:(NSString *)title
                           text:(NSString *)text
{
    self = [super init];
    if (self) {
        self.text = text;
        self.title = title;
        self.punchAttributeType = punchAttributeType;
    }
    return self;
}

@end
