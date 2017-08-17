#import <UIKit/UIKit.h>
#import "TimeOffDetailsViewController.h"
#import "TimeOffDetailsObject.h"
#import "TimeOffBookingsViewController.h"

@protocol Theme;

@interface ListOfBookedTimeOffViewController : UIViewController <BookedTimeOffBookingsViewCtrl>
{
    UIBarButtonItem *leftButton;
    
    UISegmentedControl *segmentedCtrl;
    int setViewTag;
    BOOL isCalledFromMenu;
    CGPoint currentContentOffset;
}
@property (nonatomic,assign) CGPoint currentContentOffset;
@property (nonatomic,assign) BOOL isCalledFromMenu;
@property(nonatomic,strong) UIBarButtonItem *leftButton;


@property(nonatomic,strong) UISegmentedControl *segmentedCtrl;
@property(nonatomic,assign) int setViewTag;
@property (nonatomic,readonly)id<Theme> theme;

-(void)viewWillAppear:(BOOL)animated;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithTheme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;
- (void)launchBookTimeOff;

@end
