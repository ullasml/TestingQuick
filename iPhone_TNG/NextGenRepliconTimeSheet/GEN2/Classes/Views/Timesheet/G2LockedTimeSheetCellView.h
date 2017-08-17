//
//  LockedTimeSheetCellView.h
//  Replicon
//
//  Created by Dipta Rakshit on 12/23/11.
//  Copyright (c) 2011 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G2LockedTimeSheetCellView : UITableViewCell
{
    IBOutlet UILabel  *dateLbl;
    IBOutlet UILabel  *hoursLbl;
    IBOutlet UILabel  *timeInOutLbl;
    IBOutlet UILabel  *locationHeaderLbl;
    IBOutlet UILabel  *locationValueLbl;
    IBOutlet UIImageView *clockImageView;
}

@property(nonatomic,strong) IBOutlet UILabel  *dateLbl;
@property(nonatomic,strong) IBOutlet UILabel  *hoursLbl;
@property(nonatomic,strong) IBOutlet UILabel  *timeInOutLbl;
@property(nonatomic,strong) IBOutlet UILabel  *locationHeaderLbl;
@property(nonatomic,strong) IBOutlet UILabel  *locationValueLbl;
@property(nonatomic,strong) IBOutlet UIImageView *clockImageView;

@end
