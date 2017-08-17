//
//  SyncTimesheets.h
//  Replicon
//
//  Created by vijaysai on 7/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2TimesheetModel.h"
#import "G2SupportDataModel.h"
#import "G2TimeSheetEntryObject.h"
#import "G2RepliconServiceManager.h"
#import "G2Constants.h"
#import "FrameworkImport.h"
#import "G2Util.h"

@interface G2SyncTimesheets : NSObject {

	G2TimesheetModel *timesheetModel;
	G2SupportDataModel *supportDataModel;
	//NSMutableArray *modifiedEntriesArray;
}

-(void) syncModifiedTimesheets :(id)_delegate;
- (NSMutableArray *) buildEntryObjects: (NSMutableArray *) editedEntries;
-(void)checkAndStopSync;
-(NSNumber *)getBillingRoleIdentity:(NSString *)billingIdentity :(NSString *)_projectIdentity;
@end
