#import <Foundation/Foundation.h>
#import "DatabaseConnection.h"


@class FMDatabase;

@interface RepliconSQLiteDatabaseConnection : NSObject <DatabaseConnection>

@property (nonatomic, readonly) FMDatabase *database;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

@end