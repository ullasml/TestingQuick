
#import <UIKit/UIKit.h>

@interface BookmarkThreeEntriesCell : UITableViewCell

@property (weak, nonatomic,readonly) UILabel *firstEntryLabel;
@property (weak, nonatomic,readonly) UILabel *secondEntryLabel;
@property (weak, nonatomic,readonly) UILabel *thirdEntryLabel;
@property (weak, nonatomic,readonly) UIView  *borderView;
@property (weak, nonatomic,readonly) UIImageView *chevronImage;

@end
