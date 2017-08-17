//
//  SyncResposeHandler.m
//  Replicon
//
//  Created by vijaysai on 10/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2SyncResposeHandler.h"
#import "RepliconAppDelegate.h"


@implementation G2SyncResposeHandler


#pragma mark ServerResponseHandling -

-(void) hanldeSheetsByIdResponse:(id) response {
	
	
}

#pragma mark ServerResponseProtocol Methods

- (void) serverDidRespondWithResponse:(id) response {
	
	
	if (response!=nil) {
		NSString *status = [[response objectForKey:@"response"]objectForKey:@"Status"];
		if ([status isEqualToString:@"OK"]) {
			
			if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == SyncOfflineCreatedEntries_ServiceId_34) {
				
			//	[[RepliconServiceManager expensesService] sendRequestToGetExpenseByIds:modifiedSheetIdentities];
			}
			else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == ExpenseById_ServiceID_12 ) {
				[self hanldeSheetsByIdResponse:response];
			}
			else if ([[[response objectForKey:@"refDict"]objectForKey:@"refID"] intValue] == EditExpenseEntries_Service_Id  ) {
				[self hanldeSheetsByIdResponse:response];
			}
		}
	}
}

- (void) serverDidFailWithError:(NSError *) error {
	
    [self showErrorAlert:error];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==SAML_SESSION_TIMEOUT_TAG)
    {
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(launchWebViewController)];
    }
}

-(void)showErrorAlert:(NSError *) error
{
    RepliconAppDelegate *appdelegate = (RepliconAppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([appdelegate.errorMessageForLogging isEqualToString:SESSION_EXPIRED]) {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"AuthMode"] isEqualToString:@"SAML"])
        {
            UIAlertView *confirmAlertView = [[UIAlertView alloc] initWithTitle:nil message:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED)
                                                                      delegate:self cancelButtonTitle:RPLocalizedString(@"OK", @"OK") otherButtonTitles:nil];
            [confirmAlertView setDelegate:self];
            [confirmAlertView setTag:SAML_SESSION_TIMEOUT_TAG];
            [confirmAlertView show];
            
        }
        else 
        {
            [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(SESSION_EXPIRED, SESSION_EXPIRED) ];
        }
        
    }
    else  if ([appdelegate.errorMessageForLogging isEqualToString:G2PASSWORD_EXPIRED]) {
        [G2Util errorAlert:AUTOLOGGING_ERROR_TITLE errorMessage:RPLocalizedString(G2PASSWORD_EXPIRED, G2PASSWORD_EXPIRED) ];
        [[[UIApplication sharedApplication]delegate] performSelector:@selector(reloaDLogin)];
    }
    
}


@end
