
#import <Foundation/Foundation.h>

@protocol DatabaseConnection <NSObject>

- (void)openOrCreateDatabase:(NSString *)databaseName;
- (void)executeUpdate:(NSString *)updateQuery;
- (void)executeUpdate:(NSString *)updateQuery args:(NSArray *)args;
- (NSArray *)executeQuery:(NSString *)updateQuery;

@end
