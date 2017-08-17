//
//  TimeOffBookingsViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Vijay M on 1/28/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ListOfBookedTimeOffViewController;
@class TimeOffDetailsObject;

@protocol BookedTimeOffBookingsViewCtrl <NSObject>

@optional
- (void)didSelectRowAtSummaryFromTimeOffBooking:(NSIndexPath *)indexPath :(TimeOffDetailsObject *)timeOffObj withContentOffset:(CGPoint)contentOffset;
- (void)checkForDeeplinkAndNavigate;
@end

@interface TimeOffBookingsViewController : UIViewController 
@property (nonatomic,assign) BOOL isCalledFromMenu;
@property (nonatomic, assign) CGPoint contentOffSet;
@property(nonatomic,weak) id <BookedTimeOffBookingsViewCtrl> delegate;
@end
