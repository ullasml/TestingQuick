//
//  SubmissionErrorCellView.h
//  ResubmitTimesheet
//
//  Created by Sridhar on 29/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"
#import "G2Fonts-iPhone.h"

@interface G2SubmissionErrorCellView : UITableViewCell {
	UILabel *availableField; 
	UILabel *missingField;

}
-(void)setSubmissionErrorFields:(NSString *)availablefield missingfield:(NSString *)_missingfield;

@property(nonatomic, strong) UILabel *availableField;
@property(nonatomic, strong) UILabel *missingField;

@end
