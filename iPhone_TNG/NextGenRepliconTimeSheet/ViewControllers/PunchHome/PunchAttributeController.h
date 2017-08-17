#import <UIKit/UIKit.h>
#import "RepliconBaseController.h"
#import "SelectionController.h"
#import "Enum.h"
#import "DynamicTextTableViewCell.h"

@protocol Punch;
@protocol Theme;
@protocol PunchAttributeControllerDelegate;

@class UserPermissionsStorage;
@class ReporteePermissionsStorage;
@class AstroClientPermissionStorage;
@class DefaultActivityStorage;
@class OEFType;

typedef enum {
    OEFTypeNone = 0,
    OEFTypeNumeric = 1,
    OEFTypeText = 2,
    OEFTypeDropDown = 3
} OEFTypes;


@interface PunchAttributeController : RepliconBaseController<UITableViewDelegate,UITableViewDataSource,SelectionControllerDelegate,DynamicTextTableViewCellDelegate,UITextViewDelegate>

@property (weak, nonatomic, readonly) UITableView *tableView;
@property (nonatomic, readonly) UserPermissionsStorage *punchRulesStorage;
@property (nonatomic, readonly) id <PunchAttributeControllerDelegate> delegate;
@property (nonatomic, readonly) ReporteePermissionsStorage *reporteePunchRulesStorage;
@property (nonatomic, readonly) AstroClientPermissionStorage *astroClientPermissionStorage;
@property (nonatomic, readonly) DefaultActivityStorage *defaultActivityStorage;
@property (nonatomic, readonly) id<Punch> punch;
@property (nonatomic,assign,readonly) BOOL alertViewVisible;
@property (nonatomic, readonly) NSString *selectedDropDownOEFUri;

- (instancetype)initWithReporteePermissionsStorage:(ReporteePermissionsStorage *)reporteePermissionsStorage
                      astroClientPermissionStorage:(AstroClientPermissionStorage *)astroClientPermissionStorage
                            defaultActivityStorage:(DefaultActivityStorage *)defaultActivityStorage
                                 punchRulesStorage:(UserPermissionsStorage *)punchRulesStorage;

- (void)setUpWithNeedLocationOnUI:(BOOL)locationRequired
                         delegate:(id<PunchAttributeControllerDelegate>)delegate
                         flowType:(FlowType)flowType
                          userUri:(NSString *)userUri
                            punch:(id<Punch>)punch
         punchAttributeScreentype:(PunchAttributeScreentype)punchAttributeScreentype;

@end


@protocol PunchAttributeControllerDelegate <NSObject>

- (void)punchAttributeController:(PunchAttributeController *)punchAttributeController
  didUpdateTableViewWithHeight:(CGFloat)height;

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
        didIntendToUpdateClient:(ClientType *)client;

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
       didIntendToUpdateProject:(ProjectType *)project;

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
          didIntendToUpdateTask:(TaskType *)task;

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
        didIntendToUpdateActivity:(Activity *)activity;

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
      didIntendToUpdateDropDownOEFTypes:(NSArray *)oefTypesArray;

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
didIntendToUpdateTextOrNumericOEFTypes:(NSArray *)oefTypesArray;

- (void)punchAttributeController:(PunchAttributeController *)punchAttributeController didScrolltoSubview:(id)subview;

@optional

-(void)punchAttributeController:(PunchAttributeController *)punchAttributeController
didIntendToUpdateDefaultActivity:(Activity *)activity;


@end
