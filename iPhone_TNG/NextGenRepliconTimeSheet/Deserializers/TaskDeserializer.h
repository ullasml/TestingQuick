
#import <Foundation/Foundation.h>

@interface TaskDeserializer : NSObject

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary forProjectWithUri:(NSString *)projectUri;

@end
