#import "TodaysDateControllerProvider.h"
#import "DateProvider.h"
#import "TodaysDateController.h"
#import "Theme.h"


@interface TodaysDateControllerProvider ()

@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) id<Theme> theme;

@end


@implementation TodaysDateControllerProvider

- (instancetype)initWithDateProvider:(DateProvider *)dateProvider
                       dateFormatter:(NSDateFormatter *)dateFormatter
                               theme:(id<Theme>)theme
{
    self = [super init];
    if (self) {
        self.dateProvider = dateProvider;
        self.dateFormatter = dateFormatter;
        self.theme = theme;
    }
    return self;
}

- (TodaysDateController *)provideInstance
{
    return [[TodaysDateController alloc] initWithDateProvider:self.dateProvider
                                                dateFormatter:self.dateFormatter
                                                        theme:self.theme];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
