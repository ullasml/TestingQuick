

#import <Foundation/Foundation.h>

@interface EventTracker : NSObject

+ (EventTracker *)sharedInstance;
- (void)start;
- (void)setUserID:(NSString *)userID;
- (void)log:(NSString *)event;
- (void)log:(NSString *)event withParameters:(NSDictionary *)parameters;
- (void)logError:(NSString *)errorID message:(NSString *)message exception:(NSException *)exception;

@end
