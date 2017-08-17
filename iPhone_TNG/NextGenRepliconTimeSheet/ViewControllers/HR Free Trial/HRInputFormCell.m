//
//  HRInputFormCell.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 11/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "HRInputFormCell.h"

@interface HRInputFormCell()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *infoLabelBottomSpacingConstraint;

@end
@implementation HRInputFormCell
-(void)awakeFromNib {
    [super awakeFromNib];
    self.infoLabelHeightConstraint.constant = 0;
    self.infoLabelBottomSpacingConstraint.constant = 0;
}


-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.inputTxt.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.inputTxt.autocorrectionType = UITextAutocorrectionTypeDefault;
    self.inputTxt.secureTextEntry = NO;
    self.inputTxt.keyboardType = UIKeyboardTypeAlphabet;
    self.inputTxt.returnKeyType = UIReturnKeyNext;
    self.inputTxt.delegate = self;
    
    self.infoLabelHeightConstraint.constant = 0;
    self.infoLabelBottomSpacingConstraint.constant = 0;
    
}

-(void)setInfoText:(NSString *)infoText {
    self.infoLabel.text = infoText;
    if ([infoText isEqualToString:@""]) {
        self.infoLabelHeightConstraint.constant = 0;
        self.infoLabelBottomSpacingConstraint.constant = 0;
    } else {
        self.infoLabelHeightConstraint.constant = 17;
        self.infoLabelBottomSpacingConstraint.constant = 4;
    }
}
@end
