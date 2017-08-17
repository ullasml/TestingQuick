#import <Foundation/Foundation.h>

@interface RepliconSpecHelper : NSObject

+ (NSDictionary *)jsonWithFixture:(NSString *)fixtureResourceFilename;
+ (NSString *)specialCharsEscapedString:(NSString *)string;
+ (NSArray *)jsonArrayWithFixture:(NSString *)fixtureResourceFilename;

@end
