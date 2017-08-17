
#import <Foundation/Foundation.h>

@class SQLiteTableStore;
@protocol UserSession;

@interface ReporteePermissionsStorage : NSObject

@property (nonatomic, readonly) SQLiteTableStore *sqliteStore;
@property (nonatomic, readonly) id<UserSession> userSession;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSQLiteStore:(SQLiteTableStore *)sqliteStore userSession:(id<UserSession>)userSession NS_DESIGNATED_INITIALIZER;

- (void)persistCanAccessProject:(NSNumber *)canAccessProject
                canAccessClient:(NSNumber *)canAccessClient
              canAccessActivity:(NSNumber *)canAccessActivity
   projectTaskSelectionRequired:(NSNumber *)projectTaskSelectionRequired
      activitySelectionRequired:(NSNumber *)activitySelectionRequired
         isPunchIntoProjectUser:(NSNumber *)isPunchIntoProjectUser
                        userUri:(NSString *)userUri
                 canAccessBreak:(NSNumber *)canAccessBreak;


- (BOOL)canAccessProjectUserWithUri:(NSString *)userUri;

- (BOOL)canAccessClientUserWithUri:(NSString *)userUri;

- (BOOL)canAccessActivityUserWithUri:(NSString *)userUri;

- (BOOL)isReporteePunchIntoProjectsUserWithUri:(NSString *)userUri;

- (BOOL)isReporteeProjectTaskSelectionRequired:(NSString *)userUri;

- (BOOL)isReporteeActivitySelectionRequired:(NSString *)userUri;

- (BOOL)canAccessBreaksUserWithUri:(NSString *)userUri;

@end
