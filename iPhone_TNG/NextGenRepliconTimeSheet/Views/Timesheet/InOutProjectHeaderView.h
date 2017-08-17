#import <UIKit/UIKit.h>
#import "TimesheetEntryObject.h"

@interface InOutProjectHeaderView : UITableViewCell
{
    UILabel *upperLeft;
    UILabel *middleLeft;
    UILabel *lowerLeft;
    UIButton *entryDetailsIconBtn;
    UIButton *addCellsIconBtn;
    UIImageView *addCellsIconIamgeView;
    id __weak delegate;
    NSMutableAttributedString *attributedString;
}

@property (nonatomic, strong) UILabel *upperLeft;
@property (nonatomic, strong) UILabel *middleLeft;
@property (nonatomic, strong) UILabel *lowerLeft;
@property (nonatomic, strong) UIButton *entryDetailsIconBtn, *addCellsIconBtn;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSMutableAttributedString *attributedString;
@property (nonatomic, strong) UIImageView *addCellsIconIamgeView;


- (void)initialiseViewWithProjectName:(TimesheetEntryObject *)tsEntryObject
                      isProjectAccess:(BOOL)isProjectAccess
                       isClientAccess:(BOOL)isClientAccess
                     isActivityAccess:(BOOL)isActivityAccess
                      isBillingAccess:(BOOL)isBillingAccess
                             dataDict:(NSMutableDictionary *)dataDict
                               andTag:(NSInteger)tag;


@end
