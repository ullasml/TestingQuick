#import <Foundation/Foundation.h>


@class LocalPunch;


@interface LocalSQLPunchSerializer : NSObject

- (NSDictionary *)serializePunchForStorage:(LocalPunch *)localPunch;
- (NSDictionary *)serializePunchForDeletion:(LocalPunch *)localPunch;

@end
