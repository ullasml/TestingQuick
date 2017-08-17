//
//  SupportDataModel.h
//  Replicon
//
//  Created by Devi Malladi on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "G2SQLiteDB.h"
#import "G2Util.h"
#import "G2Constants.h"
@interface G2SupportDataModel : NSObject {

}
-(void)insertSystemCurrenciesToDatabase:(NSArray *) currencyArray;
-(NSMutableArray *)getSystemCurrenciesFromDatabase;
-(void)insertBaseCurrencyToDatabase:(NSDictionary *) currencyDict;
-(NSMutableArray *)getBaseCurrencyFromDatabase;
-(void)insertSystemPreferencesToDatabase:(NSArray *)preferencesArr;
-(NSMutableArray*)getSystemPreferencesFromDatabase;
-(NSMutableArray*)getEnabledSystemPreferences;
- (void)insertTaxCodesAllInToDatabase:(NSArray *) expenseTypeArray;
-(void)insertPaymentMethodsAll:(NSArray*)paymentArr;
-(NSMutableArray *)getPaymentMethodsAllFromDatabase;

-(NSMutableArray*)getAmountTaxCodesForSelectedProjectID:(NSString*)projectId withExpenseType:(NSString*)expenseType;
-(void)insertDropDownOptionsToDatabase:(NSArray *)dropDownOptionsArray;
-(void)insertUserDefinedFieldsToDatabase:(NSArray *)userDefinedFieldArr moduleName:(NSString *)module;
-(NSMutableArray *)getUserDefineFieldOFType:(NSString *)type;
-(NSMutableArray *)getDropDownOptionsForUDFIdentity:(NSString *)udfIdentity;
-(BOOL)checkExpensePermissionWithPermissionName:(NSString*)permissionName;
-(NSMutableArray *)getUserDefineFieldsFromDatabase;
-(NSMutableArray *)getTaxCodesAllFromDatabase;

-(NSMutableArray *)getIdentityForSelectedCurrency:(NSString*)selectedCurrency;
-(NSMutableArray *)getDropDownOptionsForSelectedUDFIdentity:(NSString *)udfIdentity;
-(NSString*)getSystemCurrencyIdFromDBUsingCurrencySymbol:(NSString*)currencySymbol;
-(NSMutableArray*)getExpenseUnitLabelsFromDB:(NSString*)projectId withExpenseType:(NSString*)expenseType;
-(BOOL)getBillingInfoFromSystemPreferences:(NSString*)billingInfoString;
-(void)saveUserPreferencesFromApiToDB: (NSArray *)preferencesArray;
-(NSMutableArray *)getDropDownOptionsFromDatabase;
-(void)saveUserProjectsAndClientsFromApiToDB :(NSArray *)userProjectsArray; 
-(void)insertClientFromApiToDB:(NSDictionary *)clientDict;
-(BOOL)checkClientExistsInDBWithIdentity: identity;

-(NSMutableArray *)getUserDefineFieldsExpensesFromDatabase;
-(NSMutableArray *)getEnabledUserDefineFieldsExpensesFromDatabase;

-(BOOL)checkforUserPreferenceWithPreferenceName:(NSString*)preferenceName;
-(NSString *)getUserTimeFormat;
-(void)saveProjectBillingOptionsFromApiToDB:(NSDictionary *)userBillingOptionsDict :(NSString *)projectIdentity;
-(void)saveUserActivitiesFromApiToDB:(NSArray *)activityArray;
-(void)saveTimeOffCodesFromApiToDB:(NSArray *)timeOffCodesArray;
-(NSMutableArray *)getUserActivitiesFromDatabase;
-(NSMutableArray *)getProjectBillingOptionsFromDatabase;
-(NSMutableArray *)getTimeOffCodesFromDatabase;
//-(void)saveTimesheetUDFSettingsFromApiToDB:(NSArray *)responseArray;
-(void)insertTimesheetDropDownOptionsToDatabase:(NSArray *)dropDownOptionsArray : (NSString *)udfIdentity;
-(NSMutableArray *)getAllUserPreferences;
//-(NSMutableArray *)getAllUserProjects;
-(NSUInteger)getUserProjectsCount;

-(NSMutableArray *)getProjectsForClientWithClientId:(NSString *)clientIdentity;
-(NSString *)getClientIdentityForClientName:(NSString *)clientName;
-(NSMutableArray *)getAllClientNames;
-(NSString *)getProjectIdentityWithProjectName: (NSString *)selectedProjectName;
-(void)saveTasksForProjectWithProjectIdentity: (NSString *)projectIdentity :(NSArray *)valueArray;
-(BOOL)checkTaskExistsForProjectAndParent:(NSString *)identity :(NSString *) projectIdentity :(NSString *)parentTaskIdentity;
-(NSMutableArray *)getTasksForProjectWithParentTask :(NSString *) projectIdentity : (NSString *)parentTaskIdentity;
-(void)saveSubTasksForProjectWithParentTask: (NSString *)projectIdentity :(NSString *)parentTaskIdentity :(NSArray *)valueArray;
//......................
-(NSMutableArray*)getExpenseLocalTaxcodesFromDB:(NSString*)projectId withExpenseType:(NSString*)expenseType;
-(NSString *)getTaskBillableStatus:(NSString *)taskIdentity;
-(NSMutableArray *)getBillingRatesForProject:(NSString *)selectedProjectIdentity;
-(NSNumber *)getProjectRoleIdForBilling: (NSString *)billingIdentity : (NSString *) projectIdentity;
-(NSNumber *)getDepartmentIdForBilling: (NSString *)billingIdentity : (NSString *)projectIdentity;

+(void)addNoneClientToDB:(BOOL)_expensesPermission withBool:(BOOL)_timentryPermission;
+(void)addNoneProjectToDB:(BOOL)_expensesPermission timeEntryAllowed:(BOOL)_timeAllowed;

//inserting TaxCodes in entries DB

-(NSMutableArray*)getExpenseLocalTaxcodesForEntryFromDB:(NSString*)entryId;
-(NSMutableArray*)getTaxCodesForSavedEntry:(NSString*)projectId withExpenseType:(NSString*)expenseType andId:(NSString*)entryId;

+(id)getLastSyncDateForServiceId:(NSString *)serviceName;
+(void)updateLastSyncDateForServiceId:(NSString *)serviceName;
+(void)deleteAddNoneProjectAndClient;
-(NSString*)getExpenseModeOfTypeForTaxesFromDB:(NSString*)projectId withType:(NSString*)expType andColumnName:(NSString*)colomnName;
-(BOOL)checkProjectHasTasksForSelection:(NSString *)projectIdentity client:(NSString *)_clientIdentity;
-(NSString *)getProjectBillableStatus:(NSString *)projectIdentity;
-(NSString *)getProjectTaskBillableStatus:(NSString *)taskIdentity;
-(NSString *)getProjectRootTaskIdentity :(NSString *)projectIdentity;

+(NSString *) getBillingTypeByProjRoleName: (NSString *)projRoleName;
//-(NSString *)getTimeSheetFormatPreferences;
-(NSMutableArray *)getUserTimeSheetFormats;

//-(NSMutableArray *)getEnabledAndRequiredTimeSheetLevelUDFs;

-(NSString *)getClientAllocationId :(NSString *)clientId projectIdentity:(NSString *)projectId;
-(NSMutableArray *)getEnabledUserDefineFieldsFromDatabase;

-(NSNumber *)get_role_billing_identity: (NSString *)billingIdentity; 
-(NSNumber *)get_role_billing_identityForBillingName: (NSString *)billingName forProjectIdentity:(NSString *)projectIdentity; 
-(NSString *)getUserHourFormat;
-(BOOL)getPaymnetMethodInfoFromSystemPreferences:(NSString*)paymentMethod;
-(void)saveUserDisclaimersFromApiToDB: (NSArray *)preferencesArray;
-(NSMutableArray*)getDisclaimerPreferencesforType:(NSString *)typeName foriSOName:(NSString *)isoName;
-(NSMutableArray *)getValidTimeOffCodesFromDatabaseForTimeOff;
-(NSString*)getExpenseModeOfTypeForTaxesFromDBwithType:(NSString*)expType andColumnName:(NSString*)colomnName;
-(NSMutableArray *)getAllClientsForTimesheets;
-(void)insertProjectsFromApiToDB:(NSArray *)userProjectsArray forRecent:(BOOL)isRecent;
-(NSMutableArray *)getRecentProjectsForClientWithClientId:(NSString *)clientIdentity;
-(void)saveTimesheetUDFSettingsFromApiToDB:(NSArray *)responseArray;
@end
