//
//  CustomSelectedView.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 11/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "CustomSelectedView.h"
#import "Constants.h"
#import "Util.h"

@implementation CustomSelectedView
@synthesize fieldName;
@synthesize delegate;
@synthesize viewTag;
@synthesize deleteBtn;
#define BOTTOM_SEPARATOR_HEIGHT 2.0f
#define HORIZONTAL_PADDING 10.0f

- (id)initWithFrame:(CGRect)frame andTag:(int)tag
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.viewTag=tag;
        [self drawLayout];
    }
    return self;
}

-(void)drawLayout
{
    [self setBackgroundColor:[Util colorWithHex:@"#EAEAEA" alpha:1]];
    [self setTag:self.viewTag];
    if (fieldName==nil)
    {
        UILabel *tempfieldName = [[UILabel alloc]init];
        self.fieldName=tempfieldName;
        
    }
    [fieldName setFrame:CGRectMake(10, 3, CGRectGetWidth([[UIScreen mainScreen] bounds]) - HORIZONTAL_PADDING, 20)];
    [fieldName setTextColor:RepliconStandardBlackColor];
    [fieldName setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_16]];
    [fieldName setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:fieldName];
    [self setFrame:CGRectMake(0,0, CGRectGetWidth([[UIScreen mainScreen] bounds]), 26)];
}

-(void)deleteAction:(id)sender
{
    if (delegate != nil && ![delegate isKindOfClass:[NSNull class]] &&
		[delegate conformsToProtocol:@protocol(deleteCustomViewProtocol)])
    {
        [delegate removeCustomView:sender];
    }
}

@end
