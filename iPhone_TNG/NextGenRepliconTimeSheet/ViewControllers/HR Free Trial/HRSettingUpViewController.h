//
//  HRSettingUpViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 11/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRSettingUpViewController : UIViewController
@property (nonatomic, strong) NSArray           *pageImages;
@property (nonatomic, strong) NSArray           *pageTexts;
@property (nonatomic, strong) NSMutableArray    *pageViews;
@property (nonatomic, strong) IBOutlet UIView   *bottomView;
@property (nonatomic, weak)   IBOutlet UIButton *startButton;
- (void)loadVisiblePages;
- (void)loadPage:(NSInteger)page;
- (void)purgePage:(NSInteger)page;
-(void)signUpData :(NSNotification *)notification;
-(IBAction)startUsingRepliconClicked:(id)sender;
@property(nonatomic,assign)NSInteger previousPage;
@end
