//
//  InputFormCell.h
//  Replicon
//
//  Created by Abhishek Nimbalkar on 4/21/14.
//  Copyright (c) 2014 Replicon INC. All rights reserved.
//

#import "FormCell.h"

@interface InputFormCell : FormCell

@property (weak, nonatomic) IBOutlet UITextField *inputTxt;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

-(void) setInfoText:(NSString*)infoText;

@end
