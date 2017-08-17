//
//  NavigationTitleView.m
//  Replicon
//
//  Created by Swapna P on 5/4/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import "G2NavigationTitleView.h"


@implementation G2NavigationTitleView
@synthesize innerTopToolbarLabel;
@synthesize topToolbarlabel;

#pragma mark -
#pragma mark Initializer

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		[self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}
#pragma mark -
#pragma mark Add Methods

-(void)addTopToolBarLabel{
	if (topToolbarlabel == nil) {
	topToolbarlabel = [[UILabel alloc] init];
	}
	[topToolbarlabel setTextAlignment:NSTextAlignmentCenter];
	[topToolbarlabel setLineBreakMode:NSLineBreakByWordWrapping];
	[topToolbarlabel setNumberOfLines:0];
	[topToolbarlabel setBackgroundColor:[UIColor clearColor]];
	[topToolbarlabel setTextColor:RepliconStandardWhiteColor];
	[self addSubview:topToolbarlabel];
	
}
-(void)addInnerTopToolBarLabel{
	if (innerTopToolbarLabel == nil) {
	innerTopToolbarLabel = [[UILabel alloc] init];
	}
	[innerTopToolbarLabel setTextAlignment:NSTextAlignmentCenter];
	[innerTopToolbarLabel setLineBreakMode:NSLineBreakByWordWrapping];
	[innerTopToolbarLabel setNumberOfLines:0];
	[innerTopToolbarLabel setBackgroundColor:[UIColor clearColor]];
	[innerTopToolbarLabel setTextColor:RepliconStandardWhiteColor];
	
	[self addSubview:innerTopToolbarLabel];
	
}
#pragma mark -
#pragma mark Set Methods

-(void)setTopToolbarlabelFrame:(CGRect)rect{
	[self.topToolbarlabel setFrame:rect];
}
-(void)setInnerTopToolbarlabelFrame:(CGRect)rect{
	[self.innerTopToolbarLabel setFrame:rect];
}

-(void)setTopToolbarlabelText:(NSString *)_string{
	[self.topToolbarlabel setText:_string];
	
}
-(void)setInnerTopToolbarlabelText:(NSString *)_string{
	[self.innerTopToolbarLabel setText:_string];
}
-(void)setTopToolbarlabelFont:(UIFont *)_font{
	[self.topToolbarlabel setFont:_font];
}
-(void)setInnerTopToolbarlabelFont:(UIFont *)_font{
	[self.innerTopToolbarLabel setFont:_font];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/




@end
