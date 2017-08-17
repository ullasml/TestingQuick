#import "DayTimeSummaryController.h"
#import <KSDeferred/KSPromise.h>
#import "Theme.h"
#import "DurationCollectionCell.h"
#import "WorkHoursPresenter.h"
#import "TimePeriodSummary.h"
#import "WorkHoursDeferred.h"
#import "TimeSummaryPresenter.h"
#import "WorkHours.h"
#import "WorkHoursStorage.h"
#import "DayTimeSummary.h"
#import "TodaysDateController.h"
#import "TodaysDateControllerProvider.h"
#import "ChildControllerHelper.h"
#import "TodaysDateController.h"

@interface DayTimeSummaryController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *todaysDateHeightConstraint;

@property (nonatomic) KSPromise *workHoursPromise;
@property (nonatomic) NSArray *summaryItems;
@property (nonatomic) id<WorkHours> workHours;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) TimeSummaryPresenter *timeSummaryPresenter;
@property (nonatomic) NSDateComponents *breakHoursOffset;
@property (nonatomic) NSDateComponents *regularHoursOffset;
@property (nonatomic) id <DayTimeSummaryUpdateDelegate> delegate;
@property (nonatomic) BOOL hasBreakAccess;
@property (nonatomic) BOOL isScheduledDay;
@property (weak, nonatomic) IBOutlet UIView *todaysDateContainer;
@property (nonatomic) TodaysDateControllerProvider *todaysDateControllerProvider;
@property (nonatomic) ChildControllerHelper *childControllerHelper;
@property (nonatomic) CGFloat todaysDateContainerHeight;
@property (nonatomic) TodaysDateController *todaysDateController;
@property (nonatomic) UIEdgeInsets sectionInsets;

@end


static NSString *const DurationCollectionCellReuseIdentifier = @"!";

@implementation DayTimeSummaryController

- (instancetype)initWithWorkHoursPresenterProvider:(TimeSummaryPresenter *)timeSummaryPresenter
                                             theme:(id<Theme>)theme
                      todaysDateControllerProvider:(TodaysDateControllerProvider *)todaysDateControllerProvider
                             childControllerHelper:(ChildControllerHelper *)childControllerHelper{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.timeSummaryPresenter = timeSummaryPresenter;
        self.theme = theme;
        self.todaysDateControllerProvider = todaysDateControllerProvider;
        self.childControllerHelper = childControllerHelper;
        
    }
    
    return self;
}

- (void)setupWithDelegate:(id <DayTimeSummaryUpdateDelegate>)delegate
                   placeHolderWorkHours:(id <WorkHours>)placeHolderWorkHours
                       workHoursPromise:(KSPromise *)workHoursPromise
                         hasBreakAccess:(BOOL)hasBreakAccess
           isScheduledDay:(BOOL)isScheduledDay
todaysDateContainerHeight:(CGFloat)todaysDateContainerHeight{
    self.workHoursPromise = workHoursPromise;
    self.workHours = placeHolderWorkHours;
    self.hasBreakAccess = hasBreakAccess;
    self.delegate = delegate;
    self.isScheduledDay = isScheduledDay;
    self.todaysDateContainerHeight = todaysDateContainerHeight;
}

- (void)updateRegularHoursLabelWithOffset:(NSDateComponents *)offsetDateComponents
{
    self.regularHoursOffset = offsetDateComponents;
    if (self.workHours) {
        self.workHours = [self provideUpdatedWorkHoursWithRegularTimeOffsetComponents:offsetDateComponents];
        [self.delegate dayTimeSummaryController:self didUpdateWorkHours:self.workHours];
        [self updateSummaryItems];
    }
    
}

- (void)updateBreakHoursLabelWithOffset:(NSDateComponents *)offsetDateComponents
{
    self.breakHoursOffset = offsetDateComponents;
    if (self.workHours) {
        self.workHours = [self provideUpdatedWorkHoursWithBreakTimeOffsetComponents:offsetDateComponents];
        [self.delegate dayTimeSummaryController:self didUpdateWorkHours:self.workHours];
        [self updateSummaryItems];
    }
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sectionInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    self.view.backgroundColor = [self.theme timeCardSummaryBackgroundColor];
    self.todaysDateContainer.backgroundColor = [self.theme timeCardSummaryBackgroundColor];
    
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([DurationCollectionCell class]) bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:DurationCollectionCellReuseIdentifier];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumInteritemSpacing:1.0f];
    [flowLayout setMinimumLineSpacing:1.0f];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
    [self.timeSummaryPresenter setUpWithBreakPermission:self.hasBreakAccess];
    self.summaryItems = [self.timeSummaryPresenter placeholderSummaryItemsWithoutTimeOffHours];
    
    [self.collectionView reloadData];
    [self updateSummaryItems];
    
    TodaysDateController *todaysDateController = [self.todaysDateControllerProvider provideInstance];
    [todaysDateController setUpWithScheduledDay:self.isScheduledDay];
    [self.childControllerHelper addChildController:todaysDateController
                                toParentController:self
                                   inContainerView:self.todaysDateContainer];
    self.todaysDateController = todaysDateController;
    self.todaysDateHeightConstraint.constant = self.todaysDateContainerHeight;

    
    [self.workHoursPromise then:^id(id<WorkHours> workHours) {
        [self.delegate dayTimeSummaryController:self didUpdateWorkHours:workHours];
        self.workHours = workHours;
        self.isScheduledDay = workHours.isScheduledDay;
        [self updateSummaryItems];
        [self updateTodaysDateBasedOnScheduledDay];
        return nil;
    } error:nil];
    
    [self.collectionView setAccessibilityIdentifier:@"uia_work_break_overtime_hours_collectionview_identifier"];
    
    
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.summaryItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DurationCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DurationCollectionCellReuseIdentifier
                                                                      forIndexPath:indexPath];
    
    WorkHoursPresenter *presenter = self.summaryItems[indexPath.row];
    
    cell.durationHoursLabel.text = presenter.value;
    cell.durationHoursLabel.font = [self.theme timeDurationValueLabelFont];
    cell.durationHoursLabel.textColor = presenter.textColor;
    
    cell.nameLabel.text = presenter.title;
    cell.nameLabel.font = [self.theme timeDurationNameLabelFont];
    cell.nameLabel.textColor = presenter.textColor;
    
    cell.typeImageView.image = [UIImage imageNamed:presenter.image];
    cell.typeImageView.backgroundColor = [UIColor clearColor];
    cell.nameLabel.backgroundColor = [UIColor clearColor];
    cell.durationHoursLabel.backgroundColor = [UIColor clearColor];
    
    if (!self.isScheduledDay)
    {
        cell.durationHoursLabel.alpha = 0.55;
        cell.nameLabel.alpha = 0.55;
        cell.typeImageView.alpha = 0.55;
    }
    
    cell.rightItemDivider.hidden =  true;
    return cell;
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat availableWidth =  self.view.frame.size.width;
    CGFloat widthPerItem = availableWidth/self.summaryItems.count;
    return CGSizeMake(widthPerItem, 65);
}
 - (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return self.sectionInsets;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return self.sectionInsets.left;
}

#pragma mark - Private

- (void)updateSummaryItems
{
    if (self.workHours) {
        if (self.regularHoursOffset == nil && self.breakHoursOffset) {
            if (self.hasBreakAccess) {
                self.summaryItems = [self.timeSummaryPresenter summaryItemsWithWorkHours:self.workHours
                                                                            regularHoursOffset:self.workHours.regularTimeOffsetComponents
                                                                              breakHoursOffset:self.breakHoursOffset];
            }
            else{
                self.summaryItems = [self.timeSummaryPresenter summaryItemsWithWorkHours:self.workHours
                                                                            regularHoursOffset:self.workHours.regularTimeOffsetComponents];
            }
        }
        else if (self.breakHoursOffset == nil && self.regularHoursOffset) {
            if (self.hasBreakAccess) {
                self.summaryItems = [self.timeSummaryPresenter summaryItemsWithWorkHours:self.workHours
                                                                            regularHoursOffset:self.regularHoursOffset
                                                                              breakHoursOffset:self.workHours.breakTimeOffsetComponents];
            }
            else{
                self.summaryItems = [self.timeSummaryPresenter summaryItemsWithWorkHours:self.workHours
                                                                            regularHoursOffset:self.regularHoursOffset];
            }
        }
        else{
            if (self.hasBreakAccess) {
                self.summaryItems = [self.timeSummaryPresenter summaryItemsWithWorkHours:self.workHours
                                                                            regularHoursOffset:self.regularHoursOffset
                                                                              breakHoursOffset:self.breakHoursOffset];
            }
            else{
                self.summaryItems = [self.timeSummaryPresenter summaryItemsWithWorkHours:self.workHours
                                                                            regularHoursOffset:self.regularHoursOffset];
            }
        }
        [self.collectionView reloadData];
    }
}

-(id <WorkHours>)provideUpdatedWorkHoursWithRegularTimeOffsetComponents:(NSDateComponents *)regularTimeOffsetComponents
{
    return [[DayTimeSummary alloc] initWithRegularTimeOffsetComponents:regularTimeOffsetComponents
                                             breakTimeOffsetComponents:self.workHours.breakTimeOffsetComponents
                                                 regularTimeComponents:self.workHours.regularTimeComponents
                                                   breakTimeComponents:self.workHours.breakTimeComponents
                                                     timeOffComponents:self.workHours.timeOffComponents
                                                        dateComponents:self.workHours.dateComponents
                                                        isScheduledDay:YES];
}

-(id <WorkHours>)provideUpdatedWorkHoursWithBreakTimeOffsetComponents:(NSDateComponents *)breakTimeOffsetComponents
{
    return [[DayTimeSummary alloc] initWithRegularTimeOffsetComponents:self.workHours.regularTimeOffsetComponents
                                             breakTimeOffsetComponents:breakTimeOffsetComponents
                                                 regularTimeComponents:self.workHours.regularTimeComponents
                                                   breakTimeComponents:self.workHours.breakTimeComponents
                                                     timeOffComponents:self.workHours.timeOffComponents
                                                        dateComponents:self.workHours.dateComponents
                                                        isScheduledDay:YES];
}

-(void)updateTodaysDateBasedOnScheduledDay{
    TodaysDateController *todaysDateController = [self.todaysDateControllerProvider provideInstance];
    [todaysDateController setUpWithScheduledDay:self.isScheduledDay];
    [self.childControllerHelper replaceOldChildController:self.todaysDateController withNewChildController:todaysDateController onParentController:self onContainerView:self.todaysDateContainer];
    self.todaysDateController = todaysDateController;
}

#pragma mark - NSObject

- (void)dealloc
{
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

@end
