//
//  TimesheetSubmitReasonView.h
//  NextGenRepliconTimeSheet
//
//  Created by juhigautam on 10/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimesheetSubmitReasonView : UIView{
    UILabel *reasonDate;
    
    NSMutableArray *reasonArray;
    float headerHight;
}
@property (nonatomic,strong)UILabel *reasonDate;
@property (nonatomic,strong)NSMutableArray *reasonArray;

- (id)initWithFrame:(CGRect)frame andReasonData:(NSMutableArray *)reasondetail headerHeight:(float)height;
@end
