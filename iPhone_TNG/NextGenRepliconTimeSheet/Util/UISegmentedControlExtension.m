//
//  UISegmentedControlExtension.m
//  Replicon
//
//  Created by Dipta Rakshit on 6/26/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "UISegmentedControlExtension.h"

@implementation UISegmentedControl(CustomTintExtension)

-(void)setTag:(NSInteger)tag forSegmentAtIndex:(NSUInteger)segment {
    [[[self subviews] objectAtIndex:segment] setTag:tag];
}

-(void)setTintColor:(UIColor*)color forTag:(NSInteger)aTag {
    // must operate by tags.  Subview index is unreliable
    UIView *segment = [self viewWithTag:aTag];
    
    // UISegment is an undocumented class, so tread carefully
    // if the segment exists and if it responds to the setTintColor message
    if (segment && ([segment respondsToSelector: @selector(setTintColor:)])) {
        [segment performSelector:@selector(setTintColor:) withObject:color];
    }
}

-(void)setTextColor:(UIColor*)color forTag:(NSInteger)aTag {
    UIView *segment = [self viewWithTag:aTag];
    for (UIView *view in segment.subviews) {
    // if the sub view exists and if it responds to the setTextColor message
        if (view && ([view respondsToSelector:@selector(setTextColor:)])) {
            [view performSelector:@selector(setTextColor:) withObject:color];
        }
    }
}

-(void)setShadowColor:(UIColor*)color forTag:(NSInteger)aTag {
    
    // you probably know the drill by now
    // you could also combine setShadowColor and setTextColor
    UIView *segment = [self viewWithTag:aTag];
    for (UIView *view in segment.subviews) {
        
        if (view && ([view respondsToSelector:@selector(setShadowColor:)])) {
            [view performSelector:@selector(setShadowColor:) withObject:color];
        }
    }
}
- (void)setBackgroundColor:(UIColor *)backgroundColor forTag:(NSInteger)aTag
{
    UIView *segmentView = [self viewWithTag:aTag];
    
    [[segmentView layer] setBorderColor:[[UIColor clearColor] CGColor]];
    [[segmentView layer] setBorderWidth:1.0];
    [[segmentView layer] setCornerRadius:3];
    
    [segmentView setBackgroundColor:backgroundColor];
    
    
}
@end