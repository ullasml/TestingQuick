
#import <UIKit/UIKit.h>

@interface TimesheetValidationViewController : UIViewController

@property(nonatomic,strong) NSMutableArray *dataArray;
@property(nonatomic,strong) NSString       *selectedSheet;
@property(nonatomic,strong) UIScrollView   *scrollView;

@end
