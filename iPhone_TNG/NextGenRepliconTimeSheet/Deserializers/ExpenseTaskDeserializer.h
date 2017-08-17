
#import <Foundation/Foundation.h>

@interface ExpenseTaskDeserializer : NSObject

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary forProjectWithUri:(NSString *)projectUri;
@end
