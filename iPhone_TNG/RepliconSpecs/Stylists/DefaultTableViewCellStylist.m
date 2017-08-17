#import "DefaultTableViewCellStylist.h"
#import "Theme.h"


@interface DefaultTableViewCellStylist ()

@property(nonatomic) id<Theme> theme;

@end


@implementation DefaultTableViewCellStylist

- (instancetype)initWithTheme:(id<Theme>)theme
{
    self = [super init];
    if (self)
    {
        self.theme = theme;
    }

    return self;
}

- (void)applyThemeToCell:(UITableViewCell *)cell
{
    [self styleCell:cell separatorOffset:0.0f];
}

- (void)styleCell:(UITableViewCell *)cell separatorOffset:(CGFloat)offset
{
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    cell.separatorInset = UIEdgeInsetsMake(0.0f, offset, 0.0f, 0.0f);
    cell.textLabel.font = [self.theme defaultTableViewCellFont];
}

@end
