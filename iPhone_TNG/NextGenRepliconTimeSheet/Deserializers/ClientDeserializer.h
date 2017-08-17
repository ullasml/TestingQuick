

#import <Foundation/Foundation.h>

@interface ClientDeserializer : NSObject

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary;

@end
