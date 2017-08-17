//
//  TimesheetApprovalHistoryObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 12/04/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimesheetApprovalHistoryObject : NSObject{
    NSString				*approvalTimesheetURI;
    NSString                *approvalActionStatus;
    NSDate                  *approvalActionDate;
    //Implementation for MOBI-261//JUHI
     NSString                *approvalActingForUser;
     NSString                *approvalActingUser;
     NSString                *approvalComments;
     NSString                *approvalActionStatusUri;
}
@property (nonatomic,strong)	NSString    *approvalTimesheetURI;
@property (nonatomic,strong)	NSString    *approvalActionStatus;
@property(nonatomic,strong)     NSDate      *approvalActionDate;
//Implementation for MOBI-261//JUHI
@property(nonatomic,strong)     NSString                *approvalActingForUser;
@property(nonatomic,strong)     NSString                *approvalActingUser;
@property(nonatomic,strong)     NSString                *approvalComments;
@property(nonatomic,strong)     NSString                *approvalActionStatusUri;

@end
