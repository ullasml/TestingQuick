#import <Foundation/Foundation.h>


@class BookedTimeOff;

@interface BookedTimeOffDeserializer : NSObject

- (BookedTimeOff *) deserialize:(NSDictionary *)jsonDictionary;

@end
