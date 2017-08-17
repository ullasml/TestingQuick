//
//  CustomPickerView.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 04/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SegmentControlProtocol

- (void)pickerDoneClickAction:(id)sender;

@end




@interface CustomPickerView : UIView<UIPickerViewDelegate, UIPickerViewDataSource>
{
    id __weak delegate;
    UIPickerView *pickerView;
    UIBarButtonItem *doneButton;
    NSMutableArray *dataSourceArray;
    UIToolbar *toolbar;
    BOOL	toolbarRequired;
    
}
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) UIToolbar *toolbar;

-(void) initializePickers;
@end
