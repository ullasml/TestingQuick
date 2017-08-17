#import <Foundation/Foundation.h>


@interface PunchLogDeserializer : NSObject

- (NSArray *)deserialize:(NSArray *)jsonDictionary;

@end
