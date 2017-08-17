

#import "EventTracker.h"
#import "Flurry.h"

#define MIX_PANEL_TIMESHEET_IOS_RELEASE_TOKEN @"a47c682fe65dc1abe4a4a2e3ac14310f"
#define MIX_PANEL_TIMESHEET_IOS_DEBUG_TOKEN @"21d1e1932457bc6be07bb96fa04e4b75"
#define FLURRY_TOKEN @"PKT94KDMN8GT7SJNGN37"

@interface EventTracker ()

@property (nonatomic) BOOL isRelease;

@end

@implementation EventTracker

+ (EventTracker *)sharedInstance
{
    static EventTracker *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.isRelease = Util.isRelease;
    }
    return self;
}

- (void)start
{


    // Flurry initialization
    if (self.isRelease) {
        [Flurry setShowErrorInLogEnabled:YES];
        [Flurry setCrashReportingEnabled:YES];
        [Flurry startSession:FLURRY_TOKEN];
    }
}

- (void)setUserID:(NSString *)userID
{
    if (self.isRelease) {
        [Flurry setUserID:userID];
    }
}

- (void)log:(NSString *)event
{
    [self log:event withParameters:nil];
}

- (void)log:(NSString *)event withParameters:(NSDictionary *)parameters
{

    
    if (self.isRelease)
    {
        [Flurry logEvent:event withParameters:parameters];
    }
}

- (void)logError:(NSString *)errorID message:(NSString *)message exception:(NSException *)exception
{
        
    if (self.isRelease) {

        [Flurry logError:errorID message:message exception:exception];
    }
}

@end
