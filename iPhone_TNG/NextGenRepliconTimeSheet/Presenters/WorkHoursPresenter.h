#import <Foundation/Foundation.h>


@interface WorkHoursPresenter : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *value;
@property (nonatomic, readonly) UIColor *textColor;
@property (nonatomic, copy, readonly) NSString *image;


- (instancetype)initWithTitle:(NSString *)title
                    textColor:(UIColor *)color
                        image:(NSString *)image
                        value:(NSString *)value;

@end
