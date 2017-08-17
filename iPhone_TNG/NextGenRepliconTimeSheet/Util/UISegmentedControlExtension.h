//
//  UISegmentedControlExtension.h
//  Replicon
//
//  Created by Dipta Rakshit on 6/26/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISegmentedControl(CustomTintExtension)
-(void)setTag:(NSInteger)tag forSegmentAtIndex:(NSUInteger)segment;
-(void)setTintColor:(UIColor*)color forTag:(NSInteger)aTag;
-(void)setTextColor:(UIColor*)color forTag:(NSInteger)aTag;
-(void)setShadowColor:(UIColor*)color forTag:(NSInteger)aTag;
- (void)setBackgroundColor:(UIColor *)backgroundColor forTag:(NSInteger)aTag;
@end