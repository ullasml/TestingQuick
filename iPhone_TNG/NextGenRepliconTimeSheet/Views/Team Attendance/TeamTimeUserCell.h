//
//  TeamTimeUserCell.h
//  TT Proto
//
//  Created by Abhi on 3/7/14.
//  Copyright (c) 2014 Aby Nimbalkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeamTimeUserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *breakHoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *breakHoursValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *regularHoursLabel;
@property (weak, nonatomic) IBOutlet UILabel *regularHoursValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addButtonWidth;
@property (nonatomic,assign) BOOL showsAddButton;
@property (nonatomic,weak) id					delegate;
@property (strong, nonatomic) NSIndexPath *indexPath;
-(IBAction)addBtnClicked:(id)sender;
-(void)setShowsAddButtonBOOL:(BOOL)showsAddButtonTmp;
@end
