
#import <Foundation/Foundation.h>

@interface AuditHistory : NSObject


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

@property (nonatomic, copy, readonly) NSString *uri;
@property (nonatomic, copy, readonly) NSArray *history;

- (instancetype)initWithHistory:(NSArray*)history uri:(NSString *)uri;

@end
