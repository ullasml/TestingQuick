
#import <Foundation/Foundation.h>

@interface ExpenseProjectDeserializer : NSObject

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary;

@end
