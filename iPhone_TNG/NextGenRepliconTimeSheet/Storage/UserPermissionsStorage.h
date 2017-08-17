#import <Foundation/Foundation.h>


@class SQLiteTableStore;
@protocol UserSession;


@interface UserPermissionsStorage : NSObject

@property (nonatomic, readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic, readonly) id<UserSession> userSession;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSQLiteStore:(SQLiteTableStore *)sqliteStore userSession:(id<UserSession>)userSession NS_DESIGNATED_INITIALIZER;

- (void)persistIsExpensesProjectMandatory:(NSNumber *)isExpensesProjectMandatory
                isWidgetPlatformSupported:(NSNumber *)isWidgetPlatformSupported
                     canApproveTimesheets:(NSNumber *)canApproveTimesheets
                     canEditNonTimeFields:(NSNumber *)canEditNonTimeFields
                      geolocationRequired:(NSNumber *)geolocationRequired
                       canApproveExpenses:(NSNumber *)canApproveExpenses
                       canApproveTimeoffs:(NSNumber *)canApproveTimeoffs
                      isActivityMandatory:(NSNumber *)isActivityMandatory
                       isProjectMandatory:(NSNumber *)isProjectMandatory
                       hasTimesheetAccess:(NSNumber *)hasTimesheetAccess
                        hasActivityAccess:(NSNumber *)hasActivityAccess
                         hasProjectAccess:(NSNumber *)hasProjectAccess
                          hasClientAccess:(NSNumber *)hasClientAccess
                         canEditTimePunch:(NSNumber *)canEditTimePunch
                         isAstroPunchUser:(NSNumber *)isAstroPunchUser
                        canViewPayDetails:(NSNumber *)canViewPayDetails
                         canViewTeamPunch:(NSNumber *)canViewTeamPunch
                           breaksRequired:(NSNumber *)breaksRequired
                           selfieRequired:(NSNumber *)selfieRequired
                       hasTimePunchAccess:(NSNumber *)hasTimePunchAccess
                     canViewTeamTimesheet:(NSNumber *)canViewTeamTimesheet
                         canEditTimesheet:(NSNumber *)canEditTimesheet
                     canEditTeamTimePunch:(NSNumber *)canEditTeamTimePunch 
                      isSimpleInOutWidget:(NSNumber *)isSimpleInOutWidget
                 hasManualTimePunchAccess:(NSNumber *)hasManualTimePunchAccess;

- (BOOL)geolocationRequired;

- (BOOL)breaksRequired;

- (BOOL)selfieRequired;

- (BOOL)canEditTimePunch;

- (BOOL)isAstroPunchUser;

- (BOOL)canViewPayDetails;

- (BOOL)canApproveTimesheets;

- (BOOL)canApproveExpenses;

- (BOOL)canApproveTimeoffs;

- (BOOL)canViewTeamPunch;

- (BOOL)hasProjectAccess;

- (BOOL)hasClientAccess;

- (BOOL)hasActivityAccess;

- (BOOL)isProjectTaskSelectionRequired;

- (BOOL)hasTimesheetAccess;

- (BOOL)canEditNonTimeFields;

- (BOOL)isExpensesProjectMandatory;

- (BOOL)isActivitySelectionRequired;

- (BOOL)hasTimePunchAccess;

- (BOOL)canViewTeamTimesheet;

- (BOOL)isSimpleInOutWidget;

- (BOOL)canEditTimesheet;

- (BOOL)canEditTeamTimePunch;

- (BOOL)isWidgetPlatformSupported;

- (BOOL)hasManualTimePunchAccess;
@end
