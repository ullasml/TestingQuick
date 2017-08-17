//
//  SyncExpenses.h
//  Replicon
//
//  Created by vijaysai on 08/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2ExpensesModel.h"
#import "G2RepliconServiceManager.h"
#import "G2Constants.h"
#import "FrameworkImport.h"
#import "G2Util.h"

@interface G2SyncExpenses : NSObject<G2ServerResponseProtocol,NetworkServiceProtocol> {

	G2ExpensesModel *expenseModel;
	NSMutableArray *modifiedSheetIdentities;
}

@property (nonatomic, strong) G2ExpensesModel *expenseModel;
//@property (nonatomic, retain) NSMutableArray *modifiedSheetIdentities;

-(void) syncModifiedExpenses :(id)_delegate;
-(void)showErrorAlert:(NSError *) error;
@end
