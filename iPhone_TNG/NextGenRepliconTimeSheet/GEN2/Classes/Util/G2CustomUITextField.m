//
//  CustomUITextField.m
//  Replicon
//
//  Created by Dipta Rakshit on 4/21/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2CustomUITextField.h"

@implementation G2CustomUITextField


@synthesize horizontalPadding, verticalPadding;
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectMake(bounds.origin.x + horizontalPadding, bounds.origin.y + verticalPadding, bounds.size.width - horizontalPadding*2, bounds.size.height - verticalPadding*2);
}
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}
@end