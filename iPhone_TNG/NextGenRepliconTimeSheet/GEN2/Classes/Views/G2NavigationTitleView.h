//
//  NavigationTitleView.h
//  Replicon
//
//  Created by Swapna P on 5/4/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"

@interface G2NavigationTitleView : UIView {
	UILabel						*innerTopToolbarLabel;
	UILabel						*topToolbarlabel;
	
}

-(void)setTopToolbarlabelText:(NSString *)_string;
-(void)setInnerTopToolbarlabelText:(NSString *)_string;
-(void)addTopToolBarLabel;
-(void)addInnerTopToolBarLabel;
-(void)setTopToolbarlabelFrame:(CGRect)rect;
-(void)setInnerTopToolbarlabelFrame:(CGRect)rect;
-(void)setTopToolbarlabelFont:(UIFont *)_font;
-(void)setInnerTopToolbarlabelFont:(UIFont *)_font;

@property(nonatomic, strong) UILabel		*innerTopToolbarLabel;
@property(nonatomic, strong) UILabel		*topToolbarlabel;

@end
