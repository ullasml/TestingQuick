
#import <Foundation/Foundation.h>

@interface HttpErrorSerializer : NSObject

-(NSError *)serializeHTTPError:(NSError *)error;

@end
