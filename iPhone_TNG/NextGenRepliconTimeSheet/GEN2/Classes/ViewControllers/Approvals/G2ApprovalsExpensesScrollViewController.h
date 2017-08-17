//
//  ApprovalsExpensesScrollViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 2/14/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2ApprovalsUsersListOfExpenseEntriesViewController.h"
#import "G2AddDescriptionViewController.h"

@interface G2ApprovalsExpensesScrollViewController : UIViewController<approvalUsersListOfExpensesViewControllerDelegate>
{
    
    G2AddDescriptionViewController *addDescriptionViewController;
    UIScrollView *mainScrollView ;
    NSMutableArray *listOfItemsArr,*listOfSheetsArr;
}
@property(nonatomic,strong)	NSMutableArray *listOfItemsArr,*listOfSheetsArr;
@property(nonatomic,strong)	 UIScrollView *mainScrollView ;
@property(nonatomic,strong)	G2AddDescriptionViewController *addDescriptionViewController;
@property(nonatomic,assign) NSUInteger numberOfViews;
@property(nonatomic,assign) NSInteger currentViewIndex;
@end
