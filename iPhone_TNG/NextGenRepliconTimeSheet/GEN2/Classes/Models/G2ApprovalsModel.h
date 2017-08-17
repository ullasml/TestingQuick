//
//  ApprovalsModel.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/23/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2SQLiteDB.h"

@interface G2ApprovalsModel : NSObject
{
    
}
-(NSMutableArray *) getTimesheetsFromDB ;
-(void) saveApprovalsTimesheetsFromApiToDB : (NSMutableArray *)responseArray : (BOOL)isFromTimesheets ;
-(NSMutableArray*)getTimeSheetInfoForSheetIdentity:(id)sheetIdentity;
-(void) saveTimeEntriesForSheetFromApiToDB:(NSArray *)timeEntriesArray :(NSNumber *)sheetIdentity;
-(void) saveTimeOffEntriesForSheetFromApiToDB: timeOffsArray :sheetIdentity;
-(void) savetimesheetSheetUdfsFromApiToDB: (NSDictionary *)userDefinedFieldsDict withSheetIdentity: (NSNumber *)sheetIdentity andModuleName:(NSString *)moduleName;
/*-(void) saveTaskForTimeEntryWithProject:(NSDictionary *)taskDict withProject:(NSString *)projectIdentity;*/
-(NSMutableArray *) getTimeEntryForSheetWithSheetIdentity:(NSString *)identity :(NSString *)sheetIdentity;
-(NSMutableArray *) getTimeOffEntryWithEntryIdentityForSheetWithSheetIdentity:(NSString *)timeOffEntryIdentity :(NSString *)sheetIdentity;
-(NSMutableArray *)getUdfDetailsForName: (NSString *)udfName andModuleName:(NSString *)moduleName;
-(BOOL) checkUDFExistsForSheet: (NSNumber *)sheetIdentity andModuleName:(NSString *)moduleName andUDFName:(NSString *)udfName;
-(NSMutableArray*)getAllSheetIdentitiesFromDB;
-(NSMutableArray *)getTimeSheetsStartAndEndDates;
-(void)deleteUnmModifiedTimesheets;
-(void)saveBookedTimeOffEntriesIntoDB:(NSMutableArray *)timeOffEntries forSheetId:(NSString *)_sheetId;
-(NSMutableArray*)getTimeOffBookingsForBookingId:(id)bookingIdentity;
-(void)saveBookingsForEachBooking:(NSMutableArray *)entriesArray attributes:(NSMutableDictionary *)detailsDict;
-(NSMutableArray *)getBookedTimeOffEntryForSheetWithSheetIdentity:(NSString *)_sheetId 
														  entryId:(NSString *)_entryIdentity bookingId:(NSString *)_bookingId;
-(void)removeWtsDeletedSheetsFromDB:(id)responseArray;
-(NSMutableArray *)getAllTimeSheetsGroupedByDueDates;
-(NSString*) getSheetTotalTimeHoursForSheetFromDB: (NSString *) sheetIdentity withFormat:(NSString *)format;
-(NSDictionary *)getTimeSheetPeriodforSheetId:(NSString *)sheetIdentity;
-(NSString *)getTotalBookedTimeOffHoursForSheetWith:(NSString *)_startDate endDate:(NSString *)_endDate withFormat:(NSString *)format;
-(NSMutableArray *)getUserPermissionsForUserID:(NSString *)userID;
- (void) insertUserPermissionsInToDataBase:(NSArray *) permissionsArr andUserIdArr:(NSArray *)userIDArr;
-(NSString *)getUSerIDByTimeSheetID:(NSString *)sheetID;
-(NSMutableArray *)getAllEnabledUserPermissionsByUserID:(NSString *)userID;
-(void)savePermissionBasedTimesheetUDFsToDBForUserID:(NSDictionary *)responseDict;
-(void)insertTimesheetDropDownOptionsToDatabase:(NSArray *)dropDownOptionsArray : (NSString *)udfIdentity;
-(NSMutableArray *)getAllUserPreferencesForUserID:(NSString *)userID;
-(NSMutableArray *) getTimesheetsFromDBForUserID:(NSString *)userID forApprovalDueDate:(NSString *)approvalDueDate;
-(NSString *)getTotalHoursforBookedEntryWithDate:(NSString *)_entryDate withformat:(NSString *)format withSheetIdentity:(NSString *)sheetIdentity;

-(NSMutableArray *) getTimeEntriesForSheetFromDB: (NSString *)sheetIdentity;
-(NSMutableArray *) getTimeOffsForSheetFromDB:(NSString *)sheetIdentity;
-(NSMutableArray *)getDistinctEntryDatesForSheet:(NSString *)sheetidentity;
-(NSMutableArray *)getBookedTimeOffforTimeSheetPeriod:(NSString *)_startDate _endDate:(NSString *)endDate andSheetIdentity:(NSString *)sheetIdentity;
-(NSString *)getTotalHoursforEntryWithDate:(NSString *)_entryDate withformat:(NSString *)format withSheetIdentity:(NSString *)sheetIdentity;

-(void)deleteAllRowsForApprovalTimesheetsTable;
-(void)deleteAllRowsForApprovalUserDefinedFieldsTable;
-(void)saveUserPreferencesFromApiToDB: (NSArray *)preferencesArray andUserIdArr:(NSArray *)userIDsArray;
-(NSMutableArray *)getEnabledOnlyTimeSheetLevelUDFsForCellAndRow;
-(NSMutableDictionary*) getSelectedUdfsForEntry:(NSString *)entryId andType:(NSString*)entryType andUDFName:(NSString *)udfName;
-(NSMutableArray *) getTimeEntriesFromDB;
-(void)deleteAllRowsForApprovalTimesheetsEntriesTable;
-(void)deleteRowsForApprovalTimesheetsEntriesTableForSheetIdentity:(NSString *)sheetIdentity;
-(void) updateTimesheetApprovalStatusFromAPIToDB: (NSString *)status : (NSString *)sheetIdentity;
-(BOOL)checkUserPermissionWithPermissionName:(NSString*)permissionName andUserId:(NSString *)userID;
-(NSMutableArray*)getTimeSheetInfoForSheetIdentityAndUser:(id)sheetIdentity andUserIdentity:(NSString *)userIdentity;
-(NSMutableArray*)getSystemPreferencesApprovalDueDate;
-(NSMutableArray *)getTimeSheetsStartAndEndDates:(NSString *)sheetID;
-(NSMutableArray *)getBookedTimeOffEntryForSheetWithOnlySheetIdentity:(NSString *)_sheetId ;
-(void)deleteAllRowsForApprovalBookedTimeOffEntriesTable;
-(NSMutableArray *)getDropDownOptionsForUDFIdentityForApprovals:(NSString *)udfIdentity;
-(NSMutableArray *)getAllUdfDetails;
-(NSNumber *) getSumTimeEntriesDuration:(NSString *)sheetIdentity;
-(NSMutableArray *)getAllMealViolationsbyDate:(NSString *)violationDate forISOName:(NSString *)isoName forSheetidentity:(NSString *)sheetIdentity;
-(NSMutableArray *)getAllMealViolationsforSheetidentity:(NSNumber *)sheetIdentity;
-(void) savebreakRuleViolationsEntriesForSheetFromApiToDB:(NSArray *) breakRuleViolationsArray : (NSNumber *)sheetIdentity;
-(NSString*) getSheetTotalTimeOffHoursForSheetFromDB: (NSString *) sheetIdentity withFormat:(NSString *)format;
-(NSString*) getSheetTotalOverTimeHoursForSheetFromDB: (NSString *) sheetIdentity withFormat:(NSString *)format;
-(NSDictionary*) getSheetVariousHoursForSheetFromDB: (NSString *) sheetIdentity withFormat:(NSString *)format;
-(NSMutableArray *)getEnabledOnlyTimeOffsUDFsForCellAndRow;
//DE5784
-(void)deleteRowsForApprovalTimesheetsTableForSheetIdentity:(NSString *)sheetIdentity;
-(void)deleteAllRowsForApprovalUserPermissionsTable;
-(void)deleteAllRowsForApprovalPreferencesTable;
-(void)deleteDeletedApprovalTimesheetWithSheetIdentity:(NSString *)sheetIdentity;
-(NSMutableArray *) getTimesheetsFromDBForApprovalStatus:(NSString *)statusString;
@end
