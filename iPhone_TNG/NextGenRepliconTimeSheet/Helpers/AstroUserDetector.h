#import <Foundation/Foundation.h>

@interface AstroUserDetector : NSObject

- (BOOL)isAstroUserWithCapabilities:(NSDictionary *)capabilities
              timePunchCapabilities:(NSDictionary *)timePunchCapabilities
          isWidgetPlatformSupported:(BOOL)isWidgetPlatformSupported;

@end
