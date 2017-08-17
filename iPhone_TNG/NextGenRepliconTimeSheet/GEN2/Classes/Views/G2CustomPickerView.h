//
//  CustomPickerView.h
//  Pictage
//
//  Created by Murali M on 4/28/10.
//  Copyright 2010 EnLume. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Util.h"
#import "G2Constants.h"

@protocol NumericKeyPadProtocol

@required

-(void)resignAnyKeyPads:(NSIndexPath *)indexPath;

@end

@protocol DataPickerProtocol

@required

-(void)updatePickerSelectedValueAtIndexPath:(NSIndexPath *)otherPickerIndexPath :(int) row :(int)component;

@optional
-(NSMutableArray *)getDependantComponentData:(NSIndexPath *)selectedIndexPath :(id)selectedValue :(NSInteger)component;

@end

@protocol G2SegmentControlProtocol

@required
- (void)previousClickAction:(id )button :(NSIndexPath *)currentIndexPath;
- (void)nextClickAction:(id )button :(NSIndexPath *)currentIndexPath;

@optional
- (void)doneClickAction:(id)button :(NSIndexPath *)currentIndexPath;

@end

@protocol DatePickerProtocol

@required

-(void)updatePickedDateAtIndexPath :(NSIndexPath *)dateIndexPath :(NSDate *) selectedDate;

@end

@protocol DataPickerZeroIndexUpdateProtocol

@required 
-(void)updatePickerValuesAtZeroIndex :(NSMutableArray *)zeroIndexValuesArray :(NSIndexPath *)otherIndexPath;

@end




@interface G2CustomPickerView : UIView<UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource> {
	
	UIPickerView *pickerView;
	UIDatePicker *datePicker;
	UIToolbar *toolbar;
	UIBarButtonItem *doneButton;
	UIBarButtonItem *spaceButton;
	UISegmentedControl *segmentedControl;
	
	NSIndexPath *dateIndexPath;
	NSIndexPath *otherPickerIndexPath;
	id __weak delegate;
	
	NSMutableArray *dataSourceArray;
	
	BOOL	toolbarRequired;
    
    NSInteger selectedRowForClients;
}

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) NSIndexPath *dateIndexPath;
@property (nonatomic, strong) NSIndexPath *otherPickerIndexPath;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, assign) BOOL toolbarRequired;

-(void) initializePickers;
-(void) addToolBarToView;
-(void) showHideViewsByFieldType:(NSString *)fieldType;
-(void) updateDateComponent :(id)sender;
-(void) doneClickAction:(id)sender;
-(void) segmentClick:(UISegmentedControl *)segmentControl;
-(void) changeSegmentControlButtonsStatus :(BOOL)enablePrevious :(BOOL)enableNext; 
-(void)showHideSegmentControl:(BOOL) hide;
-(void)updateDataSourceArray:(NSMutableArray *)updatedDataArray component:(NSInteger)_component;

@end
