//
//  ExpenseSheetObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 26/03/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExpenseSheetObject : NSObject
{
    NSString    *expenseSheetApprovalStatus;
    NSString    *expenseSheetDescription;
    NSString    *expenseSheetURI;
    NSString    *expenseSheetReimbursementAmount;
    NSString    *expenseSheetReimbursementCurrencyName;
	NSString    *expenseSheetReimbursementCurrencyURI;
    NSString    *expenseSheetIncurredAmount;
    NSString    *expenseSheetIncurredCurrencyName;
	NSString    *expenseSheetIncurredCurrencyURI;
    NSDate      *expenseSheetDate;
    
    
}

@property (nonatomic,strong) NSString    *expenseSheetApprovalStatus;

@property (nonatomic,strong) NSString    *expenseSheetDescription;
@property (nonatomic,strong) NSString    *expenseSheetURI;
@property (nonatomic,strong) NSString    *expenseSheetReimbursementAmount;
@property (nonatomic,strong) NSString    *expenseSheetReimbursementCurrencyName;
@property (nonatomic,strong) NSString    *expenseSheetReimbursementCurrencyURI;
@property (nonatomic,strong) NSString    *expenseSheetIncurredAmount;
@property (nonatomic,strong) NSString    *expenseSheetIncurredCurrencyName;
@property (nonatomic,strong) NSString    *expenseSheetIncurredCurrencyURI;
@property (nonatomic,strong) NSDate      *expenseSheetDate;

@end
