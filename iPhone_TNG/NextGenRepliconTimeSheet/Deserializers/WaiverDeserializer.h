#import <Foundation/Foundation.h>


@class Waiver;


@interface WaiverDeserializer : NSObject

- (Waiver *)deserialize:(NSDictionary *)waiverDictionary;

@end
