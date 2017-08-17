#import "TodaysDateController.h"
#import "DateProvider.h"
#import "Theme.h"


@interface TodaysDateController ()

@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) id<Theme> theme;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic) BOOL isScheduledDay;
@end


@implementation TodaysDateController

- (instancetype)initWithDateProvider:(DateProvider *)dateProvider
                       dateFormatter:(NSDateFormatter *)dateFormatter
                               theme:(id<Theme>)theme
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.dateProvider = dateProvider;
        self.dateFormatter = dateFormatter;
        self.theme = theme;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

-(void)setUpWithScheduledDay:(BOOL)isScheduledDay{
    self.isScheduledDay = isScheduledDay;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    NSDate *date = [self.dateProvider date];
    self.dateLabel.text = [self.dateFormatter stringFromDate:date];
    self.dateLabel.font = [self.theme timeCardSummaryDateTextFont];
    self.dateLabel.textColor = [self.theme timeCardSummaryDateTextColor];

    if (!self.isScheduledDay) {
        self.dateLabel.alpha = 0.55;
    }
    
}

@end
