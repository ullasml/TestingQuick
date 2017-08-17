#import "AuditTrailController.h"
#import "PunchLogRepository.h"
#import <KSDeferred/KSPromise.h>
#import "PunchLog.h"
#import "PunchLogCell.h"
#import "RemotePunch.h"
#import "Theme.h"
#import "Constants.h"


@interface AuditTrailController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIView *topLineView;
@property (nonatomic) PunchLogRepository *punchLogsRepository;
@property (nonatomic) id<Theme> theme;

@property (nonatomic) NSArray *punchLogs;
@property (nonatomic) RemotePunch *punch;
@property (nonatomic, weak) id<AuditTrailControllerDelegate> delegate;

@end


static NSString *const PunchLogCellIdentifier = @"¡";
static float const AuditTrailTitleToTableViewPadding = 60.0;


@implementation AuditTrailController

- (instancetype)initWithPunchLogsRepository:(PunchLogRepository *)punchLogsRepository
                                      theme:(id<Theme>)theme
{
    self = [super init];
    if (self)
    {
        self.punchLogsRepository = punchLogsRepository;
        self.theme = theme;
    }
    return self;
}

- (void)setupWithPunch:(RemotePunch *)punch delegate:(id<AuditTrailControllerDelegate>)delegate;
{
    self.punch = punch;
    self.delegate = delegate;
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
    
    self.tableView.estimatedRowHeight = 70.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.delegate auditTrailController:self didUpdateHeight:0.0];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:PunchLogCellIdentifier];

    self.titleLabel.text = RPLocalizedString(AuditHistoryTitle, AuditHistoryTitle);
    self.titleLabel.font = [self.theme auditTrailTitleLabelFont];
    self.titleLabel.textColor = [self.theme auditTrailTitleLabelTextColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    KSPromise *promise = [self.punchLogsRepository fetchPunchLogsForPunchURI:self.punch.uri];
    [promise then:^id(NSArray *punchLogs) {
        self.punchLogs = punchLogs;
       [self.tableView reloadData];

        CGFloat height = self.tableView.contentSize.height;
        [self.delegate auditTrailController:self didUpdateHeight:height + AuditTrailTitleToTableViewPadding];
        self.topLineView.hidden = NO;

        return nil;
    } error:^id(NSError *error) {
        return error;
    }];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.tableView layoutIfNeeded];
    CGFloat height = self.tableView.contentSize.height;
    [self.delegate auditTrailController:self didUpdateHeight:height + AuditTrailTitleToTableViewPadding];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.punchLogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PunchLogCellIdentifier];
    cell.textLabel.textColor = [self.theme auditTrailLogLabelTextColor];
    cell.textLabel.font = [self.theme auditTrailLogLabelFont];
    
    PunchLog *punchLog = self.punchLogs[indexPath.row];
    cell.textLabel.text = [punchLog text];
    cell.textLabel.numberOfLines = 0;
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

@end
