#import <UIKit/UIKit.h>

@protocol Theme;

@interface DefaultTableViewCellStylist : NSObject

@property(nonatomic, readonly) id<Theme> theme;

- (instancetype)initWithTheme:(id<Theme>)theme;
- (void)applyThemeToCell:(UITableViewCell *)cell;
- (void)styleCell:(UITableViewCell *)cell separatorOffset:(CGFloat)offset;

@end
