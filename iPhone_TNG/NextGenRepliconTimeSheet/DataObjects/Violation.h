#import <Foundation/Foundation.h>

@class Waiver;

typedef NS_ENUM(NSUInteger, ViolationSeverity) {
    ViolationSeverityError = 0,
    ViolationSeverityWarning = 1,
    ViolationSeverityInfo  = 2,
    ViolationSeverityUnknown  = 3
};


@interface Violation : NSObject

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) ViolationSeverity severity;
@property (nonatomic, readonly) Waiver *waiver;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSeverity:(ViolationSeverity)severity
                          waiver:(Waiver *)waiver
                           title:(NSString *)title;

@end
