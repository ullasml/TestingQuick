//
//  ListOfExpenseEntriesCustomCell.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 26/03/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListOfExpenseEntriesCustomCell : UITableViewCell


-(void)createCellLayoutWithParams:(NSString *)upperleftString
                    upperrightstr:(NSString *)upperrightString
                    lowerrightStr:(NSString *)lowerrightStr
               isReceiptAvailable:(BOOL)isReceiptAvailable
         isReimburesmentAvailable:(BOOL)isReimburesmentAvailable
                            width:(CGFloat)width
;


@end
