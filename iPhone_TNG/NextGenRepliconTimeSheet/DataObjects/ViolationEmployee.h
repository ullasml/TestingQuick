#import <Foundation/Foundation.h>


@interface ViolationEmployee : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *uri;
@property (nonatomic, copy, readonly) NSArray *violations;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithName:(NSString *)name
                         uri:(NSString *)uri
                  violations:(NSArray *)violations;

@end
