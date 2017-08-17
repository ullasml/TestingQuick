#import "PunchDetailsController.h"
#import "LocalPunch.h"
#import "PunchPresenter.h"
#import "Theme.h"
#import <Blindside/BSInjector.h>
#import "UserPermissionsStorage.h"
#import "BreakType.h"


typedef NS_ENUM(NSUInteger, PunchDetailRowType) {
    PunchDetailRowTypeTitle,
    PunchDetailRowTypeTime,
    PunchDetailRowCount
};


@interface PunchDetailsController ()

@property (nonatomic, weak) IBOutlet UIImageView *selfieImageView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *topBorderLineView;
@property (nonatomic, weak) IBOutlet UIView *bottomBorderLineView;
@property (nonatomic, weak) IBOutlet UIView *contentView;

@property (nonatomic) UserPermissionsStorage *userPermissionsStorage;
@property (nonatomic) id<PunchDetailsControllerDelegate> delegate;
@property (nonatomic) id<Theme> theme;
@property (nonatomic) id<Punch> punch;
@property (nonatomic) PunchPresenter *punchPresenter;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (nonatomic, weak) id<BSInjector> injector;

@end


static NSString *const CellIdentifier = @"¡";


@implementation PunchDetailsController

- (instancetype)initWithUserPermissionsStorage:(UserPermissionsStorage *)userPermissionsStorage
                                punchPresenter:(PunchPresenter *)punchPresenter
                                         theme:(id<Theme>)theme {
    self = [super init];
    if (self)
    {
        self.userPermissionsStorage = userPermissionsStorage;
        self.punchPresenter = punchPresenter;
        self.theme = theme;
    }
    return self;
}

- (void) setUpWithTableViewDelegate:(id<PunchDetailsControllerDelegate>)delegate
{
    self.delegate = delegate;
}
- (void)updateWithPunch:(id<Punch>)punch
{
    self.punch = punch;
    [self.tableView reloadData];

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

    self.topBorderLineView.backgroundColor = [self.theme punchDetailsBorderLineColor];
    self.bottomBorderLineView.backgroundColor = [self.theme punchDetailsBorderLineColor];
    self.contentView.backgroundColor = [self.theme punchDetailsContentViewBackgroundColor];
    [self.punchPresenter presentImageForPunch:self.punch inImageView:self.selfieImageView];

    self.automaticallyAdjustsScrollViewInsets = YES;
    self.navigationItem.title = RPLocalizedString(@"Punch Details", nil);
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    [self.tableView setAccessibilityIdentifier:@"punch_details_table_view"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGFloat containerHeight = self.tableView.contentSize.height;
    [self.delegate punchDetailsController:self didUpdateTableViewWithHeight:containerHeight];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return PunchDetailRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = self.theme.timeLineCellTimeLabelTextColor;
    cell.textLabel.font = [self.theme timeLineCellTimeLabelFont];
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01f;
}
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PunchDetailRowType rowType = indexPath.row;
    switch (rowType) {
        case PunchDetailRowTypeTitle:
        {
            NSString *text = @"";
            if (self.punch.actionType == PunchActionTypeStartBreak){
                text = self.punch.breakType.name ?: @"";
            }
            else{
                text = [self.punchPresenter descriptionLabelTextWithPunch:self.punch];
            }

            UIImage *image = [self.punchPresenter punchActionIconImageWithPunch:self.punch];
            
            cell.textLabel.text = text;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.imageView.image = image;
            cell.imageView.contentMode = UIViewContentModeScaleAspectFit;

            if (self.punch.actionType == PunchActionTypeStartBreak  && ![self.userPermissionsStorage canEditNonTimeFields] && ![self.userPermissionsStorage canEditTimePunch])
            {
                cell.textLabel.textColor = [self.theme attributeDisabledValueLabelColor];
            }
            
            break;
        }

        case PunchDetailRowTypeTime:
        {
            NSString *text = [self.punchPresenter dateTimeLabelTextWithPunch:self.punch];
            cell.textLabel.text = text;
            if ([self.userPermissionsStorage canEditTimePunch])
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            }
            else
            {
                cell.textLabel.textColor = [self.theme attributeDisabledValueLabelColor];
            }
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(tableView.bounds));
            break;
        }

        case PunchDetailRowCount:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == PunchDetailRowTypeTitle && self.punch.actionType == PunchActionTypeStartBreak  && ([self.userPermissionsStorage canEditNonTimeFields] || [self.userPermissionsStorage canEditTimePunch]))
    {
        [self.delegate punchDetailsControllerWantsToChangeBreakType:self];
    }
    else if (indexPath.row == PunchDetailRowTypeTime && [self.userPermissionsStorage canEditTimePunch])
    {
        [self.delegate punchDetailsController:self didIntendToChangeDateOrTimeOfPunch:self.punch];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

#pragma mark - NSObject

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

@end
