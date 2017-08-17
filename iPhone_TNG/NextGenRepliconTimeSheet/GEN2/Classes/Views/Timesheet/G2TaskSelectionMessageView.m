//
//  TaskSelectionMessageView.m
//  Replicon
//
//  Created by vijaysai on 6/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2TaskSelectionMessageView.h"

@implementation G2TaskSelectionMessageView
@synthesize titleLabel;
@synthesize messageLabel;
@synthesize closeButton;
@synthesize progressView;
@synthesize loadingLabel;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
		[self setAlpha:0.7];
		[self setBackgroundColor:[UIColor blackColor]];
		[self.layer setBorderWidth:3.5];
		[self.layer setCornerRadius:10.0];
    }
    return self;
}

-(void) showTransparentAlert :(NSString *)_title message:(NSString *)_message {
	if (titleLabel == nil) {
		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 285, 40)];
	}
	[titleLabel setText:_title];
	[titleLabel setNumberOfLines:2];
	[titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
	[titleLabel setTextColor:RepliconStandardWhiteColor];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[self addSubview:titleLabel];
	
	if (messageLabel == nil) {
		messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, 280, 40)];
	}
	[messageLabel setText:_message];
	[messageLabel setNumberOfLines:2];
	[messageLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
	[messageLabel setTextColor:RepliconStandardWhiteColor];
	[messageLabel setBackgroundColor:[UIColor clearColor]];
	[self addSubview:messageLabel];
	
	if (closeButton == nil) {
		closeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[closeButton setFrame:CGRectMake(100, 90, 80, 30)];			   
	}
	[closeButton setBackgroundColor:RepliconStandardClearColor];
	[closeButton setTitleColor:RepliconStandardTextColor forState:UIControlStateNormal];
	[closeButton setTitle:@"Close" forState:UIControlStateNormal];
	[closeButton addTarget:self action:@selector(removeView:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:closeButton];
	
	if (progressView == nil) {
		UIActivityIndicatorView *tempProgressView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.progressView=tempProgressView;
        
		[self.progressView setFrame:CGRectMake(120, 90, 50, 50)];
	}
	[self.progressView setHidesWhenStopped:YES];
	[self.progressView startAnimating];
	[self.progressView setHidden:YES];
	//[progressView setBackgroundColor:RepliconStandardClearColor];
	[self addSubview:self.progressView];
	
	if (loadingLabel == nil) {
		loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 140, 220.0, 40.0)];
	}
	[loadingLabel setHidden:YES];
	[loadingLabel setBackgroundColor:[UIColor clearColor]];
	[loadingLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_18]];
	[loadingLabel setTextColor:RepliconStandardWhiteColor];
	[loadingLabel setText:@"Loading"];
	[self addSubview:loadingLabel];
	
	
	
}
																

- (void)removeView:(id)sender{
	//do nothing
	[self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/




@end
