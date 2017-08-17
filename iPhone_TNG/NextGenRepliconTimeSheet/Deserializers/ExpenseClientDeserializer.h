
#import <Foundation/Foundation.h>

@interface ExpenseClientDeserializer : NSObject

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary;


@end
