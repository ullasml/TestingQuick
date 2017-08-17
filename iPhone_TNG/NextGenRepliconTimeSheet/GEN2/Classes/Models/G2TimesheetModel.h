//
//  TimesheetModel.h
//  Replicon
//
//  Created by enl4macbkpro on 5/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "G2SQLiteDB.h"
#import "G2Util.h"
#import "G2Constants.h"
#import "G2TimeSheetEntryObject.h"
#import "G2TimeOffEntryObject.h"
@interface G2TimesheetModel : NSObject {

}

-(void) saveTimesheetsFromApiToDB : (NSMutableArray *)responseArray;
-(void) saveTimeEntriesForSheetFromApiToDB:(NSArray *)timeEntriesArray :(NSNumber *)sheetIdentity;
-(void) saveTimeOffEntriesForSheetFromApiToDB:(NSArray *)timeOffsArray :(NSNumber *)sheetIdentity;
-(void) updateTimesheetApprovalStatusFromAPIToDB: (NSDictionary *)timeSheetDict;
-(void) savetimesheetSheetUdfsFromApiToDB: (NSDictionary *)userDefinedFieldsDict withSheetIdentity: (NSNumber *)sheetIdentity andModuleName:(NSString *)moduleName ;
-(void) saveTaskForTimeEntryWithProject:(NSDictionary *)taskDict withProject:(NSString *)projectIdentity;
-(BOOL)checkTaskExistsForProjectAndParent:(NSString *)identity :(NSString *) projectIdentity :(NSString *)parentTaskIdentity;
-(NSMutableArray *) getTimesheetsFromDB;
-(NSMutableArray *) getTimeOffsForSheetFromDB:(NSString *)sheetIdentity;
-(NSMutableArray *) getTimeEntriesForSheetFromDB: (NSString *)sheetIdentity;
-(NSMutableArray *) getTimeEntryForSheetWithSheetIdentity:(NSString *)identity :(NSString *)sheetIdentity;
-(NSMutableArray *) getEntryProjectNamesForSheetFromDB: (NSString *)sheetIdentity;
-(NSMutableArray *) getEntryActivitiesForSheetFromDB: (NSString *) sheetIdentity;
-(NSString *) getSheetTotalTimeHoursForSheetFromDB: (NSString *) sheetIdentity withFormat:(NSString *)format;
-(NSMutableArray *)getDistinctEntryDatesForSheet:(NSString *)sheetidentity;
-(NSMutableArray*)getTimeSheetInfoForSheetIdentity:(id)sheetIdentity;
-(NSMutableArray *)getUdfDetailsForName: (NSString *)udfName andModuleName:(NSString *)moduleName;
-(BOOL) checkUDFExistsForSheet: (NSNumber *)sheetIdentity andModuleName:(NSString *)moduleName andUDFName:(NSString *)udfName ;
//-(NSMutableArray *)getEnabledAndRequiredSheetLevelUDFs;
-(NSMutableArray *)getUDFsforTimesheetEntry : (NSString *)entryId : (NSString *)moduleName;
-(NSNumber *)getDefaultOptionForDropDownUDF:(NSString *)udfIdentity;

-(void)updateEditedTimeEntry:(G2TimeSheetEntryObject *)_timeEntryObject andStatus:(NSString *)_status;
-(NSMutableArray *) getTimeOffEntryWithEntryIdentityForSheetWithSheetIdentity:(NSString *)timeOffEntryIdentity :(NSString *)sheetIdentity;
-(NSMutableArray *)getTimeSheetForEntryDate:(NSDate *)entryDate;
-(void)saveTimeEntryForSheetWithObject:(G2TimeSheetEntryObject *)_timeEntryObject editStatus:(NSString *)_editStatus;
-(void)updateSheetModifyStatus:(NSString *)sheetIdentity status:(BOOL)_status;
-(NSMutableArray *)getModifiedTimesheets;
-(NSMutableArray *)getOfflineCreatedTimeEntries:(NSString *)sheetIdentity;
-(NSMutableArray *)getOfflineEditedTimeEntries:(NSString *)sheetIdentity;
-(NSMutableArray *)getOfflineDeletedTimeEntries:(NSString *)sheetIdentity;
-(NSMutableArray *)getOfflineCreatedTimeEntriesWithoutSheet;
- (void) removeOfflineCreatedEntries: (NSString *)sheetId;
-(void)resetEntriesModifyStatus:(NSString *)sheetId;
-(void)deleteUnmModifiedTimesheets;

-(NSMutableArray *)getTimeSheetsStartAndEndDates;
-(void)saveBookedTimeOffEntriesIntoDB:(NSMutableArray *)_entries;
-(NSMutableArray *)getBookedTimeOffsForSheetId:(NSString *)_sheetIdentity;
-(NSMutableArray *)getAllBookedTimeOffEntries;
-(NSString *)getTotalBookedTimeOffHoursForSheetWith:(NSString *)_startDate endDate:(NSString *)_endDate withFormat:(NSString *)format;
//-(NSMutableArray *)getBookedTimeOffDistinctDatesForSheet:(NSString *)sheetidentity;
-(NSMutableArray *)getBookedTimeOffEntryForSheetWithSheetIdentity:(NSString *)_sheetId 
														  entryId:(NSString *)_entryIdentity bookingId:(NSString *)_bookingId;
-(void)saveBookingsForEachBooking:(NSMutableArray *)entriesArray attributes:(NSMutableDictionary *)detailsDict;
-(NSMutableArray*)getTimeOffBookingsForBookingId:(id)bookingIdentity;
-(void)deleteTimeEntryWithIdentityForSheet: (NSString *)entryIdentity sheetId: (NSString *)sheetIdentity;

-(NSDictionary *)getTimeSheetPeriodforSheetId:(NSString *)sheetIdentity;
-(NSMutableArray *)getBookedTimeOffforTimeSheetPeriod:(NSString *)_startDate _endDate:(NSString *)endDate;
-(NSMutableArray *)getBookedTimeOffEntryWithIdentity:(NSString *)_entryIdentity;
-(NSString *)getTotalHoursforEntryWithDate:(NSString *)_entryDate withformat:(NSString *)format;
-(NSString *)getTotalHoursforBookedEntryWithDate:(NSString *)_entryDate withformat:(NSString *)format;
-(NSMutableArray*)getAllSheetIdentitiesFromDB;
-(void)removeWtsDeletedSheetsFromDB:(id)responseArray;


-(void)insertTimesheetDropDownOptionsToDatabase:(NSArray *)dropDownOptionsArray : (NSString *)udfIdentity;
-(NSMutableArray *)getEnabledAndRequiredTimeSheetLevelUDFs;
-(void)savePermissionBasedTimesheetUDFsToDB:(NSArray *)responseArray;

-(void)deleteTasksFromDB;

-(NSMutableArray *)getEnabledAndRequiredTimeSheetLevelUDFsFieldIndexes:(NSString *)moduleName;
-(NSMutableArray *)getEnabledOnlyTimeSheetLevelUDFsForCellAndRow;
-(NSMutableDictionary*) getSelectedUdfsForEntry:(NSString *)entryId andType:(NSString*)entryType andUDFName:(NSString *)udfName;
-(void) saveTimesheetsFromApiToDBForPunchClock : (NSMutableArray *)responseArray ;
-(void) saveTimeEntriesForSheetFromApiToDBFForPunchClock:(NSArray *)timeEntriesArray andSheetIdentity:(NSNumber *)sheetIdentity andStatus:(NSString *)approvalStatus;
-(NSMutableArray *) getTimeEntryForWithDate:(id)entryDate;
-(void)updatePunchClockPunchData:(NSString *)sheetIdentity andEntryIdentity:(NSString *)entryIdentity status:(BOOL)_status;
-(NSMutableArray *)getPunchClockTimeentries;
-(void) updateTimesheetDisclaimerStatusFromAPIToDB: (NSDictionary *)timeSheetDict;
-(BOOL)checkWhetherEntryDateFalssInTimeSheetPeriod:(NSDate *)entryDate :(NSNumber *)sheetIdentity;
-(NSMutableArray *)getEnabledOnlyTimeOffsUDFsForCellAndRow;
-(void)updateEditedTimeOffEntry:(G2TimeOffEntryObject *)_timeOffEntryObject andStatus:(NSString *)_status;
-(void)saveTimeOffEntryForSheetWithObject:(G2TimeOffEntryObject *)_timeOffEntryObject editStatus:(NSString *)_editStatus;
-(void)deleteTimeOffEntryWithIdentityForSheet: (NSString *)entryIdentity sheetId: (NSString *)sheetIdentity;
-(void) savebreakRuleViolationsEntriesForSheetFromApiToDB:(NSArray *) breakRuleViolationsArray : (NSNumber *)sheetIdentity;
-(NSMutableArray *)getAllMealViolationsbyDate:(NSString *)violationDate forISOName:(NSString *)isoName forSheetidentity:(NSString *)sheetIdentity;
//US4591//Juhi
-(NSMutableArray*)getTimeOffUdfsWithIdentity:(id)identity moduleName:(NSString *)module;
//US4805
-(NSMutableArray *) getTimesheetsForSheetFromDB: (NSString *)sheetIdentity;
-(NSDictionary *)fetchQueryHandlerAndStartIndexForClientID:(NSString *)clientId;
- (void) updateQueryHandleByClientId:(NSString*)clientId andQueryHandle:(NSString *)queryHandle  andStartIndex:(NSString *)startIndex;
-(float)getTotalBookedTimeOffHoursForSheetIdsFromTimeEntries:(NSMutableArray *)sheetIds;
-(float)getTotalBookedTimeOffHoursForSheetIdsFromTimeSheets:(NSMutableArray *)sheetIds;
-(NSArray *)getEnabledOnlyCellLevelUDFsForGPSTracking;
@end
