

#import <Foundation/Foundation.h>

@interface ApplicationVersionValidator : NSObject

-(BOOL)isVersion:(NSString *)olderVersion olderThanVersion:(NSString *)someVersion;
-(BOOL)needsUpdateForUserDetailsAndVersionUpdateFromOlderVersion:(NSString *)olderVersion;

@end
