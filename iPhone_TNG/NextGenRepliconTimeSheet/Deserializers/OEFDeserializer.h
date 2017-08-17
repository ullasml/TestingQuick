

#import <Foundation/Foundation.h>


@interface OEFDeserializer : NSObject

-(NSMutableArray *)deserializeHomeFlowService:(NSDictionary *)jsonDictionary;
-(NSMutableArray *)deserializeMostRecentPunch:(NSDictionary *)extensionFieldsDictionary punchActionType:(NSString *)punchActionType;
-(NSMutableArray *)deserializeGetObjectExtensionFieldBindingsForUsersServiceWithJson:(NSDictionary *)jsonDictionary;
@end
