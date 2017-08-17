//
//  PreviousApprovalsButtonViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Prashant Shukla on 17/08/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Theme;
@protocol PreviousApprovalsButtonControllerDelegate;
@class ButtonStylist;

@interface PreviousApprovalsButtonViewController : UIViewController

@property (nonatomic, readonly) ButtonStylist *buttonStylist;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, weak, readonly) id <PreviousApprovalsButtonControllerDelegate>delegate;
@property (weak, nonatomic, readonly) UIButton *viewPreviousApprovalsButton;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDelegate:(id <PreviousApprovalsButtonControllerDelegate>)delegate
                   buttonStylist:(ButtonStylist *)buttonStylist
                           theme:(id <Theme>)theme;

@end

@protocol PreviousApprovalsButtonControllerDelegate <NSObject>
- (void) approvalsButtonControllerWillNavigateToPreviousApprovalsScreen:(PreviousApprovalsButtonViewController *) previousApprovalsButtonViewController;

@end
