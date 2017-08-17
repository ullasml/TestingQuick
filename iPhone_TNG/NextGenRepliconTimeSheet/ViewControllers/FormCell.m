//
//  FormCell.m
//  Replicon
//
//  Created by Abhi on 3/30/14.
//  Copyright (c) 2014 Replicon INC. All rights reserved.
//

#import "FormCell.h"

@implementation FormCell


#pragma mark - Textfield delegate protocol

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if([self.delegate respondsToSelector:@selector(formCellDidBeginEditing:)])
        [self.delegate formCellDidBeginEditing:self];
    
}

@end
