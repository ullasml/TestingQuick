//
//  SupportDataModel.h
//  Replicon
//
//  Created by Devi Malladi on 3/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SQLiteDB.h"
#import "Util.h"
#import "Constants.h"
@interface SupportDataModel : NSObject
{

}

-(NSMutableArray *)getUserDetailsFromDatabase;
-(NSMutableArray *)getUserDetailsFromLightWeightHomeFlowDatabase;
-(void)saveTimesheetPermittedApprovalActionsDataToDB:(NSDictionary *)dataDict;
-(NSDictionary *)getTimesheetPermittedApprovalActionsDataToDBWithUri:(NSString *)uri;
-(void)saveExpensePermittedApprovalActionsDataToDB:(NSDictionary *)dataDict;
-(NSDictionary *)getExpensePermittedApprovalActionsDataToDBWithUri:(NSString *)uri;
-(void)updateTimesheetPermission:(int)hasTimesheetAccess;
@end
