#import "AstroAwareTimesheet.h"


@interface AstroAwareTimesheet ()

@property (nonatomic) TimesheetAstroUserType astroUserType;
@property (nonatomic, copy) NSString *format;
@property (nonatomic, copy) NSString *uri;
@property (nonatomic, copy) NSDictionary *timesheetDictionary;
@property (nonatomic) BOOL hasPayrollSummary;

@end


@implementation AstroAwareTimesheet

- (instancetype)initWithTimesheetAstroUserType:(TimesheetAstroUserType)astroUserType format:(NSString *)format uri:(NSString *)uri timesheetDictionary:(NSDictionary *)timesheetDictionary hasPayRollSummary:(BOOL)hasPayRollSummary{
    self = [super init];
    if (self) {
        self.astroUserType = astroUserType;
        self.format = format;
        self.uri = uri;
        self.timesheetDictionary=timesheetDictionary;
        self.hasPayrollSummary = hasPayRollSummary;
    }
    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
