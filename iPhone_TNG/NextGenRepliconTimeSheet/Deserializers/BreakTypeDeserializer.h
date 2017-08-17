#import <Foundation/Foundation.h>


@interface BreakTypeDeserializer : NSObject

- (NSArray *) deserialize: (NSDictionary *) responseDictionary;

@end
