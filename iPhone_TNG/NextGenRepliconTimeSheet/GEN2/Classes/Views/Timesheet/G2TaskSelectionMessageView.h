//
//  TaskSelectionMessageView.h
//  Replicon
//
//  Created by vijaysai on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<QuartzCore/QuartzCore.h>
#import "G2Constants.h"

@interface G2TaskSelectionMessageView : UIView {
	
	UILabel *titleLabel;
	UILabel *messageLabel;
	UIButton *closeButton;
	UIActivityIndicatorView *progressView;
	UILabel	*loadingLabel;

}

-(void) showTransparentAlert :(NSString *)_title message:(NSString *)_message;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *messageLabel;
@property(nonatomic, strong) UIButton *closeButton;
@property(nonatomic, strong) UIActivityIndicatorView *progressView;
@property(nonatomic, strong) UILabel	*loadingLabel;

@end
