
#import <UIKit/UIKit.h>
#import "Enum.h"


@class CurrencyValue;
@protocol Theme;
@protocol GrossPayCollectionViewControllerDelegate;
@protocol GrossPayHours;


@interface GrossPayCollectionViewViewController : UIViewController <UICollectionViewDataSource>
@property (nonatomic, readonly) CurrencyValue *grossPay;
@property (nonatomic, readonly) NSArray *actualsByPayCodeArray;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, readonly) NSString *scriptCalculationDate;
@property (nonatomic, weak, readonly) UICollectionView *collectionView;
@property (weak, nonatomic, readonly) IBOutlet UIButton *viewItemsButton;
@property (weak, nonatomic, readonly)  NSLayoutConstraint *viewMoreButtonHeightConstraint;
@property (weak, nonatomic, readonly)  NSLayoutConstraint *lastUpdatedLabelHeightConstraint;
@property (weak, nonatomic, readonly)  NSLayoutConstraint *asterixHeightConstraint;
@property (nonatomic,weak,readonly) IBOutlet UILabel *lastUpdateTimeLabel;
@property (nonatomic, readonly) id <GrossPayHours> grossPayHours;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (void)setupWithActualsByPayCodeDetails:(NSArray *)actualsByPayCodeArray
                                   theme:(id <Theme>)theme
                                delegate:(id <GrossPayCollectionViewControllerDelegate>)delegate
                   scriptCalculationDate:(NSString *)scriptCalculationDate;

@end

@protocol GrossPayCollectionViewControllerDelegate <NSObject>

-(void)grossPayTimeHomeViewControllerIntendsToUpdateHeight:(CGFloat)height viewItem:(ViewItemsAction)action;


-(id <GrossPayHours> )grossPayCollectionControllerNeedsGrossPay;


@end

