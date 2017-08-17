#import <Foundation/Foundation.h>

@class URLStringProvider;

@interface ForgotPasswordRequestProvider : NSObject

@property (nonatomic, readonly) NSUserDefaults *defaults;

-(instancetype)initWithDefaults:(NSUserDefaults *)defaults;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (NSURLRequest *)provideRequestWithCompanyName:(NSString *)company andemail:(NSString *)email;

- (NSURLRequest *)provideRequestWithPasswordResetRequestUri:(NSString *)passwordResetRequestUri;

@end
