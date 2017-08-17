//
//  HRInputFormCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 11/09/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "HRFormCell.h"

@interface HRInputFormCell : HRFormCell
@property (weak, nonatomic) IBOutlet UITextField *inputTxt;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

-(void) setInfoText:(NSString*)infoText;
@end
