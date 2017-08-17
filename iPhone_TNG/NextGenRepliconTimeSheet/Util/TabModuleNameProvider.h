#import <Foundation/Foundation.h>

@class AstroUserDetector;

@interface TabModuleNameProvider : NSObject

@property (nonatomic,readonly) AstroUserDetector *astroUserDetector;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithAstroUserDetector:(AstroUserDetector *)astroUserDetector NS_DESIGNATED_INITIALIZER;


- (NSArray *)tabModuleNamesWithHomeSummaryResponse:(NSDictionary *)homeSummaryResponse userDetails:(NSArray *)userDetails isWidgetPlatformSupported:(BOOL)isWidgetPlatformSupported;

@end
