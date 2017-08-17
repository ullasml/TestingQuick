//
//  ExpensesCellView.h
//  RepliconHomee
//
//  Created by Manoj  on 30/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "G2Constants.h"
@interface G2ExpensesCellView : UITableViewCell {
	
	UILabel *trackingLabel;
	UILabel *titleDetailsLable;
	UILabel *dateLable;
	UILabel *cosetLable;
	UILabel *statusLable;
	UILabel *client_projectLabel;
	
	UIImageView *recieptImageView;
	UILabel *secondCostLabel;
}

@property(nonatomic,strong) UILabel  *secondCostLabel;
@property(nonatomic,strong)UIImageView *recieptImageView;
@property(nonatomic,strong)UILabel *trackingLabel;
@property(nonatomic,strong)UILabel *titleDetailsLable;
@property(nonatomic,strong)UILabel *dateLable;
@property(nonatomic,strong)UILabel *cosetLable;
@property(nonatomic,strong)UILabel *statusLable;
@property(nonatomic,strong)UILabel *client_projectLabel;
-(void)createExpDetailsLables;
-(void)createExpenseEntriesfields;
-(void)addCostLable;
-(void)addReceiptIndicatorImage;
@end
