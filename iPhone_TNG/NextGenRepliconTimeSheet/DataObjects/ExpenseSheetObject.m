//
//  ExpenseSheetObject.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 26/03/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "ExpenseSheetObject.h"

@implementation ExpenseSheetObject
@synthesize expenseSheetApprovalStatus;
@synthesize expenseSheetDescription;
@synthesize expenseSheetURI;
@synthesize expenseSheetReimbursementAmount;
@synthesize expenseSheetReimbursementCurrencyName;
@synthesize expenseSheetReimbursementCurrencyURI;
@synthesize expenseSheetIncurredAmount;
@synthesize expenseSheetIncurredCurrencyName;
@synthesize expenseSheetIncurredCurrencyURI;
@synthesize expenseSheetDate;


- (id) init
{
	self = [super init];
	if (self != nil)
    {
		      
    }
	return self;
}





@end
