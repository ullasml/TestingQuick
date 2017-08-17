//
//  ViewUtil.m
//  Replicon
//
//  Created by Ravi Shankar on 7/21/11.
//  Copyright 2011 enl. All rights reserved.
//

#import "G2ViewUtil.h"
#import "G2Constants.h"

@implementation G2ViewUtil

+(void) setToolbarLabel: (UIViewController *)parentController withText: (NSString *)labelText
{
	UILabel *topToolbarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180,20)];
    [topToolbarLabel setNumberOfLines:0];
    [topToolbarLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [topToolbarLabel setFont:[UIFont boldSystemFontOfSize: RepliconFontSize_16]];
    [topToolbarLabel setTextAlignment:NSTextAlignmentCenter];
    [topToolbarLabel setBackgroundColor:[UIColor clearColor]];
    [topToolbarLabel setTextColor:[UIColor whiteColor]];
    [topToolbarLabel setTextAlignment: NSTextAlignmentCenter];
    [topToolbarLabel setShadowColor:[UIColor blackColor]];//US4065//Juhi
    [topToolbarLabel setShadowOffset:CGSizeMake(0, -1)];//emboss effect (0,1)
    
    [topToolbarLabel setText: labelText];
    parentController.navigationItem.titleView = topToolbarLabel;
   
	
}

@end
