//
//  HRFormCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 11/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "HRFormCell.h"

@implementation HRFormCell
#pragma mark - Textfield delegate protocol

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if([self.delegate respondsToSelector:@selector(formCellDidBeginEditing:)])
        [self.delegate formCellDidBeginEditing:self];
    
}
@end
