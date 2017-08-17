
#import "GrossPayCollectionViewViewController.h"
#import "GrossPayHoursCell.h"
#import "Paycode.h"
#import "Theme.h"
#import "Util.h"
#import "GrossPayHours.h"


@interface GrossPayCollectionViewViewController ()<UICollectionViewDelegateFlowLayout>
@property (nonatomic,weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic) NSArray *actualsByPayCodeArray;
@property (nonatomic) NSNumberFormatter *numberFormatter;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) NSMutableArray *colorCodeArray;
@property (nonatomic) NSMutableArray *actualsArray;
@property (weak, nonatomic) IBOutlet UIButton *viewItemsButton;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *asterixValueLabel;
@property (nonatomic,weak) id <GrossPayCollectionViewControllerDelegate> delegate;
@property (nonatomic) NSString *scriptCalculationDate;
@property (nonatomic) id<GrossPayHours> grossPayHours;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMoreButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lastUpdatedLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *asterixHeightConstraint;

@end


static NSString *const GrossPayCellReuseIdentifier = @"!";

@implementation GrossPayCollectionViewViewController

- (void)setupWithActualsByPayCodeDetails:(NSArray *)actualsByPayCodeArray
                                   theme:(id <Theme>)theme
                                delegate:(id <GrossPayCollectionViewControllerDelegate>)delegate
                   scriptCalculationDate:(NSString *)scriptCalculationDate
{
    self.actualsByPayCodeArray = actualsByPayCodeArray;
    self.actualsArray = [self getItemsListToViewMoreOrLess:self.actualsByPayCodeArray];
    self.theme = theme;
    self.colorCodeArray = [Util getColorList:(int)self.actualsByPayCodeArray.count];
    self.delegate = delegate;
    self.scriptCalculationDate = scriptCalculationDate;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.numberFormatter = [[NSNumberFormatter alloc] init];
    self.grossPayHours = [self.delegate grossPayCollectionControllerNeedsGrossPay];
    self.asterixHeightConstraint.constant = 0.0f;
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([GrossPayHoursCell class]) bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:GrossPayCellReuseIdentifier];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(120.0f, 45.0f)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView setCollectionViewLayout:flowLayout];
    [self.collectionView reloadData];

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];

    BOOL shouldHideViewMoreButton = (self.actualsByPayCodeArray.count <=4);
    if (shouldHideViewMoreButton) {
        self.viewItemsButton.hidden = TRUE;
        self.viewMoreButtonHeightConstraint.constant = 0.0f;
    }


    if ([self.grossPayHours checkForViewMore]) {
        [self updateCollectionView:self.actualsByPayCodeArray viewAction:More];
    }
    else
    {
        [self updateCollectionView:self.actualsByPayCodeArray viewAction:Less];
    }
    
    if(self.actualsByPayCodeArray.count<=4 || [self.grossPayHours checkForViewMore])
    {
        [self showHideLastUpdateTime:YES];
    }
    else
    {
        [self showHideLastUpdateTime:NO];
    }
    
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.actualsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GrossPayHoursCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GrossPayCellReuseIdentifier
                                                                        forIndexPath:indexPath];
    
    Paycode *payCode = self.actualsByPayCodeArray[indexPath.row];
    cell.valueLabel.text = payCode.textValue;
    cell.valueLabel.font = [self.theme legendsGrossPayFont];
    
    cell.colorView.cornerRadius = cell.colorView.frame.size.height/2;
    cell.colorView.backgroundColor = self.colorCodeArray[indexPath.row];
    cell.titleLabel.text = payCode.titleText;
    cell.titleLabel.font = [self.theme legendsGrossPayHeaderFont];
    
    return cell;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 25, 5, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return 5.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect screenRect = [self.collectionView bounds];
    CGFloat screenWidth = screenRect.size.width;
    float cellWidth = screenWidth / 2.0;
    CGSize size = CGSizeMake((cellWidth-20), 45);
    
    return size;
}

#pragma mark ViewMore action

- (IBAction)viewItemsAction:(id)sender
{
    if ([sender tag] == More)
    {
        self.viewItemsButton.tag = Less;
        [self updateCollectionView:self.actualsByPayCodeArray viewAction:More];
        [self.delegate grossPayTimeHomeViewControllerIntendsToUpdateHeight:0.0f viewItem:More];
    }
    else
    {
        [self updateCollectionView:self.actualsByPayCodeArray viewAction:Less];
        [self.delegate grossPayTimeHomeViewControllerIntendsToUpdateHeight:0.0f viewItem:Less];
    }
    
}

#pragma mark - NSObject

- (void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Private

-(void)updateCollectionView:(NSArray *)actualsByPayCodeArray
                 viewAction:(ViewItemsAction)action
{
    NSMutableArray *viewMoreItemsArray = [NSMutableArray array];
    if (action==More) {
        self.viewItemsButton.tag = Less;
        [self showHideLastUpdateTime:YES];
        [self.viewItemsButton setTitle:RPLocalizedString(@"Show Less",@"Show Less") forState:UIControlStateNormal];
        viewMoreItemsArray = [NSMutableArray arrayWithArray:self.actualsByPayCodeArray];
    }
    else
    {
        self.viewItemsButton.tag = More;
        [self showHideLastUpdateTime:NO];
        [self.viewItemsButton setTitle:RPLocalizedString(@"Show More",@"Show More") forState:UIControlStateNormal];
        viewMoreItemsArray = [self getItemsListToViewMoreOrLess:self.actualsByPayCodeArray];
    }
    [self.actualsArray removeAllObjects];
    self.actualsArray = viewMoreItemsArray;
    [self.collectionView reloadData];
}

-(void)showHideLastUpdateTime:(BOOL)shouldShowLabel
{
    if (shouldShowLabel && self.scriptCalculationDate!=nil && self.scriptCalculationDate!=(id)[NSNull null]) {
        self.lastUpdateTimeLabel.text = self.scriptCalculationDate;
        self.lastUpdateTimeLabel.font = [self.theme lastUpdateTimeFont];
        self.lastUpdatedLabelHeightConstraint.constant = 25.0f; ///should set to dynamic
        self.asterixHeightConstraint.constant = 21.0f;
    }
    else
    {
        self.lastUpdatedLabelHeightConstraint.constant = 0.0f;
        self.asterixHeightConstraint.constant = 0.0f;
    }
    
}

-(NSMutableArray *)getItemsListToViewMoreOrLess:(NSArray *)payCodeArray
{
    NSMutableArray *viewMoreItemsInfoPaycode = [NSMutableArray array];
    for (int k =0 ; k < self.actualsByPayCodeArray.count ; k++) {
        if (k < 4) {
            [viewMoreItemsInfoPaycode addObject:self.actualsByPayCodeArray[k]];
        }
    }
    return viewMoreItemsInfoPaycode;
}


@end
