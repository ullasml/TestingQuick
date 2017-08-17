//
//  UITextView+DisableCopyPaste.m
//  NextGenRepliconTimeSheet
//
//  Created by Prakashini Pattabiraman on 07/12/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "UITextView+DisableCopyPaste.h"

@implementation UITextView (DisableCopyPaste)

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    [UIMenuController sharedMenuController].menuVisible = NO;
    return NO;
}

@end
