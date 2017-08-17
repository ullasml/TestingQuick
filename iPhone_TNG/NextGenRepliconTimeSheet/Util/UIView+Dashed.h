

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,LineType)
{
    Dashed,
    Filled,
};

@interface UIView (Dashed)

-(void)lineWithColor:(UIColor *)color type:(LineType)type;

@end
