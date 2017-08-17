#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, ViolationSectionType) {
    ViolationSectionTypeDate,
    ViolationSectionTypeEmployee,
    ViolationSectionTypeTimesheet
};

@interface ViolationSection : NSObject

@property(nonatomic, readonly) id titleObject;
@property(nonatomic, readonly) NSArray *violations;
@property(nonatomic, readonly) ViolationSectionType type;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTitleObject:(id)titleObject
                         violations:(NSArray *)violations
                               type:(ViolationSectionType)type NS_DESIGNATED_INITIALIZER;


@end
