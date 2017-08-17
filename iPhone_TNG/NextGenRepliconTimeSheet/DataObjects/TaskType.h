
#import <Foundation/Foundation.h>
@class Period;
@interface TaskType : NSObject <NSCoding, NSCopying>

@property (nonatomic,readonly,copy) NSString *name;
@property (nonatomic,readonly,copy) NSString *uri;
@property (nonatomic,readonly) Period *taskPeriod;
@property (nonatomic,readonly,copy) NSString *projectUri;



+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithProjectUri:(NSString *)projectUri
                        taskPeriod:(Period *)taskPeriod
                              name:(NSString *)name
                               uri:(NSString *)uri NS_DESIGNATED_INITIALIZER;

@end
