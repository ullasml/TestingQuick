#import <Foundation/Foundation.h>
#import "PunchActionTypes.h"


@interface PunchActionTypeDeserializer : NSObject

- (PunchActionType)deserialize:(NSString *)actionURI;
- (NSString *)getPunchActionTypeString:(PunchActionType)punchActiontype;

@end
