
#import <Foundation/Foundation.h>

@interface PayCodeDuration : NSObject
@property (nonatomic, readonly) NSString *textValue;
@property (nonatomic, readonly) NSString *titleText;

- (instancetype)initWithAmount:(NSString *)textValue
                         title:(NSString *)titleText;

@end
