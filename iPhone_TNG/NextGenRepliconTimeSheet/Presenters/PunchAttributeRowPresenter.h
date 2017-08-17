
#import <Foundation/Foundation.h>
#import "Constants.h"


@interface PunchAttributeRowPresenter : NSObject

@property (nonatomic,copy,readonly) NSString *text;
@property (nonatomic,copy,readonly) NSString *title;
@property (nonatomic,assign,readonly) PunchAttribute punchAttributeType;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithRowType:(PunchAttribute )punchAttributeType
                          title:(NSString *)title
                           text:(NSString *)text NS_DESIGNATED_INITIALIZER;

@end
