//
//  PunchClockViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 12/19/11.
//  Copyright (c) 2011 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface G2PunchClockViewController : UIViewController

{
    IBOutlet UIImageView *bgImageView;
    IBOutlet UILabel *currentDateLbl;
    IBOutlet UILabel *hourLbl,*hourLbl1;
    IBOutlet UILabel *minsLbl,*minsLbl1;
    IBOutlet UILabel *colonLbl;
    IBOutlet UILabel *am_pm_Lbl;
    IBOutlet UILabel *punchInOutHeaderLbl;
    IBOutlet UILabel *punchInOutValueLbl,*punchInOutValueLbl1;
    IBOutlet UILabel *clockOnOffHeaderLbl;
    IBOutlet UILabel *clockOnOffValueLbl,*clockOnOffValueLbl1;
    IBOutlet UIButton *punchButton;
    IBOutlet UIImageView *clockImageView;
    NSTimer *timer;
    NSTimer *autotTimer;
    NSTimer *hiddentimer,*visibleTimer;
    BOOL isAutoPunchOut;
    NSInteger hrsValue,minsValue;
    int pasthrsValue,pastminsValue;
    BOOL isFromPunchButton,isErrorAlert;
    BOOL isStop;
    //    BOOL isZeroTimeEntries;
    NSDate *temporarySelectedDate;
    BOOL isNotRunAutoRefresh;
    BOOL isPreviousTimeSheetPeriodFetched;
}
@property(nonatomic,assign) BOOL isStop,isNotRunAutoRefresh;
//@property(nonatomic,assign) BOOL isZeroTimeEntries;
@property(nonatomic,assign) BOOL isAutoPunchOut,isErrorAlert,isFromPunchButton;
@property(nonatomic,strong) IBOutlet UIImageView *bgImageView;
@property(nonatomic,strong) IBOutlet UILabel *currentDateLbl;
@property(nonatomic,strong) IBOutlet UILabel *hourLbl,*hourLbl1;
@property(nonatomic,strong) IBOutlet UILabel *minsLbl,*minsLbl1;
@property(nonatomic,strong) IBOutlet UILabel *colonLbl;
@property(nonatomic,strong) IBOutlet UILabel *am_pm_Lbl;
@property(nonatomic,strong) IBOutlet UILabel *punchInOutHeaderLbl;
@property(nonatomic,strong) IBOutlet UILabel *punchInOutValueLbl,*punchInOutValueLbl1;
@property(nonatomic,strong) IBOutlet UILabel *clockOnOffHeaderLbl;
@property(nonatomic,strong) IBOutlet UILabel *clockOnOffValueLbl,*clockOnOffValueLbl1;
@property(nonatomic,strong) IBOutlet UIButton *punchButton;
@property(nonatomic,strong) IBOutlet UIImageView *clockImageView;
@property(nonatomic,strong) NSTimer *timer;
@property(nonatomic,strong) NSTimer *autotTimer;
@property(nonatomic,strong) NSTimer *hiddentimer,*visibleTimer;
@property(nonatomic,strong) NSDate *temporarySelectedDate;

-(IBAction)punchBtnClicked:(id)sender;
-(void)refreshPunchDetails;
-(void)updateClockOnOffLabelForPunchIn:(NSDate *)selectedDate andTime:(NSString *)timeIn;
- (void)timeEntryActionForPunchDetails;
- (void)timeEntryActionForPunchDetailsFromLoadOrTimer;
-(void)editEntryForFetchedSheet;
-(void) handleProcessCompleteActions;
-(void)updateClockOnOffLabelForTimeIn:(NSString *)timeIn;
-(void)hideSecondsColon;
@end
