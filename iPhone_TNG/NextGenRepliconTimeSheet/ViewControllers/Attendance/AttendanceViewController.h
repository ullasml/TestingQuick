#import <UIKit/UIKit.h>
#import "TimesheetEntryObject.h"
#import "TimeEntryViewController.h"
#import "PunchHistoryCustomCell.h"
#import "PunchMapViewController.h"

@protocol AttendanceLocationUpdatedDelegateProtocol;
@protocol Theme;

@interface AttendanceViewController :UIViewController < PunchTimeCellClickDelegate ,CLLocationManagerDelegate,MKMapViewDelegate>

@property(nonatomic,assign)BOOL                 isCalledFromMenu;

@property(nonatomic,assign)BOOL                 isProjectAccess;
@property(nonatomic,assign)BOOL                 isActivityAccess;
@property(nonatomic,assign)BOOL                 isBillingAccess;
@property(nonatomic,assign)BOOL                 isBreakAccess;
@property(nonatomic,assign)BOOL                 isExtendedInOut;

@property(nonatomic,assign)BOOL                 isUsingAuditImages;
@property(nonatomic,strong)TimesheetEntryObject *tsEntryObject;
@property(nonatomic,strong)UIView               *trackTimeView;
@property(nonatomic,strong)UIView               *buttonView;

@property(nonatomic,strong)UIButton             *timeFormatBtn;

@property(nonatomic,strong)NSMutableDictionary  *timePunchDict;



@property(nonatomic,strong) CLLocationManager   *locationManager;
@property(nonatomic,strong) NSMutableDictionary *locationDict;
@property(nonatomic,strong)UIButton          *locationImgView;
@property(nonatomic,assign)int                 currentServiceCall;
@property(nonatomic,assign)int                 totalServiceCall;
@property(nonatomic,strong) UILabel  *currentDateLabel;
@property(nonatomic,assign)int previousDifferenceOfDays;
@property(nonatomic,strong) UIView              *lastPunchView;;
@property(nonatomic, weak) id <AttendanceLocationUpdatedDelegateProtocol> attendanceLocationUpdatedDelegate;
@property(nonatomic,strong)PunchMapViewController *punchMapViewController;
@property (nonatomic,strong) UIActivityIndicatorView *activityView;
@property(nonatomic,assign)BOOL                 isButtonAction;
@property (nonatomic,strong) NSString *punchActionUri;
//Implementation for MOBI-728//JUHI
@property(nonatomic,strong) UIView *punchInfoView;
@property (nonatomic,strong)UIImage *clockUserImage;
@property (nonatomic,assign)BOOL isClockIn;
@property(nonatomic,strong)NSMutableDictionary  *projectInfoDict;
@property (nonatomic,strong) UIView *okButtonView;
@property (nonatomic,strong)UIActivityIndicatorView *punchInfoActivityView;
@property (nonatomic,strong)UILabel *clockedInOutInfoLbl;
@property (nonatomic,strong)UIImageView *clockedInOutInfoLblBgndView;
@property (nonatomic,strong)MKMapView *mapView;
@property (nonatomic,readonly)id<Theme> theme;
//METHODS
-(void)sendPunchForData:(NSMutableDictionary *)dataDict actionType:(NSString *)action;



-(NSMutableDictionary*)getPunchDataDictionary;




-(void)handlePunchDataReceivedAction:(NSNotification *)notification;
-(void)handleStartNewTaskAction;
-(UIView *)initialiseView:(NSMutableDictionary *)dataDict;
-(void)createButtonViewFromYoffset:(float)headerHeight;

-(void)dismissCameraView;

-(void)getAddress:(CLLocationManager *)locationManger fromDelegate:(id)delegate;
-(void)handleLastPunchResponse:(NSNotification *)notification;

-(void)sendRequestToGetLastPunchData;
-(void)goToMapView;
-(void)handlePunchDataNotification :(NSNotification *)notification;
-(void)showLastPunchDataView;
-(void)addActiVityIndicator;
-(void)removeActiVityIndicator;
//Implementation for MOBI-728//JUHI
-(void)showPunchData:(BOOL)isResponseReceived;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithTheme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;

@end

@protocol AttendanceLocationUpdatedDelegateProtocol <NSObject>

@optional
- (void)handleLocationUpdatedwithlocationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;

@end
