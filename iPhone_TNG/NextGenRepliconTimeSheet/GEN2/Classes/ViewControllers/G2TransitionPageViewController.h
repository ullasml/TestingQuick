//
//  TransitionPageViewController.h
//  Replicon
//
//  Created by Ravi Shankar on 7/30/11.
//  Copyright 2011 enl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FrameworkImport.h"
#import "G2URLReader.h"


typedef enum ProcessType {
	ProcessType_Login,
	ProcessType_Logout,
	ProcessType_ExpenseSheets,
	ProcessType_ExpenseEntries,
	ProcessType_Timesheets,
	ProcessType_TimesheetsSupportData,
	ProcessType_ExpenseSupportData,
	ProcessType_SystemPreferences,
	ProcessType_UserPreferrences,
	ProcessType_Permissions
}ProcessType;

@protocol ProcessControllProtocol
-(void) processingError: (NSError *)error;
-(void) processResponse: (id)response;
@end

@interface G2TransitionPageViewController : UIViewController <NetworkServiceProtocol, G2ServerResponseProtocol>{
	UIImageView *backGroundImageView;
	
	ProcessType currProcessType;
	id __weak			delegate;
	UILabel *lable;
}

@property(nonatomic,strong)	UILabel *lable;
@property (nonatomic) ProcessType currProcessType;
@property (nonatomic, weak) id delegate;

-(void) serverDidRespondWithNonJSONResponse:(id)response;
+(NSString *) startProcessForType: (ProcessType)processType withData: (id)dataObj withDelegate: (id)delegate;
+(G2TransitionPageViewController *) getInstance;
@end
