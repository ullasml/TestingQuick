#import "ApplicationVersionValidator.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"

@interface ApplicationVersionValidator()

@property (nonatomic,weak) id <BSInjector> injector;

@end


@implementation ApplicationVersionValidator


-(BOOL)isVersion:(NSString *)olderVersion olderThanVersion:(NSString *)someVersion{

    NSArray *olderVersionComponents = [olderVersion componentsSeparatedByString:@"."];
    NSArray *someVersionComponents = [someVersion componentsSeparatedByString:@"."];
    NSInteger pos = 0;

    while ([olderVersionComponents count] > pos || [someVersionComponents count] > pos) {
        NSInteger v1 = [olderVersionComponents count] > pos ? [[olderVersionComponents objectAtIndex:pos] integerValue] : 0;
        NSInteger v2 = [someVersionComponents count] > pos ? [[someVersionComponents objectAtIndex:pos] integerValue] : 0;
        if (v1 < v2) {
            return YES;
        }
        else if (v1 > v2) {
            return NO;
        }
        pos++;
    }
    //for same versions
    return NO;

}

-(BOOL)needsUpdateForUserDetailsAndVersionUpdateFromOlderVersion:(NSString *)olderVersion
{
    NSBundle *mainBundle = [self.injector getInstance:InjectorKeyMainBundle];
    NSString *version = [[mainBundle infoDictionary] objectForKey:@"CFBundleVersion"];
    if (olderVersion == nil || ![olderVersion isEqualToString:version] )
    {
        return YES;
    }

    return NO;
}

@end
