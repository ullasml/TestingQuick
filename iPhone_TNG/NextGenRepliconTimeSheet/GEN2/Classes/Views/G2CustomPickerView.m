//
//  CustomPickerView.m
//  Pictage
//
//  Created by Murali M on 4/28/10.
//  Copyright 2010 EnLume. All rights reserved.
//

#import "G2CustomPickerView.h"
#import "G2TimeEntryViewController.h"

#define TIME_TAG 9999
#define HOUR_TAG 8888

@implementation G2CustomPickerView

@synthesize pickerView, datePicker;
@synthesize toolbar;
@synthesize dateIndexPath, otherPickerIndexPath;
@synthesize delegate, dataSourceArray;
@synthesize toolbarRequired;

enum  {
	PICKER_PREVIOUS,
	PICKER_NEXT
};

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		DLog(@"CustomPickerView:: initWithFrame");
        // Initialization code
		if (toolbar == nil) {
			toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
																	  0,
																	  320,
																	  45.0)];
		}
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        if (version>=7.0)
        {
            toolbar.barStyle = UIBarStyleBlackTranslucent;
            toolbar.tintColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.5];
            
        }
        else{
           
            [toolbar setTintColor:[UIColor clearColor]];
        }
		
		[toolbar setTranslucent:YES];
		[self addSubview:toolbar];
		[self setHidden:YES];
    }
    return self;
}

-(void) initializePickers {
	if (segmentedControl == nil) {
		segmentedControl = [[UISegmentedControl alloc] initWithItems:
							[NSArray arrayWithObjects:
							 RPLocalizedString( @"Previous",@""),
							 RPLocalizedString(@"Next",@""),nil]];
	}
	
	//[self addSubview:toolbar];
	//[self setBackgroundColor:[UIColor purpleColor]];
	if (pickerView == nil) {
		UIPickerView *temppickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        self.pickerView=temppickerView;
        
		CGSize pickerSize = [pickerView sizeThatFits:CGSizeZero];
       
		[pickerView setFrame:CGRectMake(0.0,
										45.0 ,
										pickerSize.width,
										pickerSize.height)];
		pickerView.delegate = self;
		pickerView.dataSource = self;
		pickerView.showsSelectionIndicator = YES;
		[pickerView setHidden:YES];
		[self addSubview:pickerView];
	}
	
	if (datePicker == nil) {
		UIDatePicker *tempdatePicker  = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0,
																				 45.0 ,
																				 320,
																				 180)];
        self.datePicker=tempdatePicker;
       
		datePicker.datePickerMode = UIDatePickerModeDate;
		datePicker.hidden = YES;
		datePicker.date = [NSDate date];
		[datePicker addTarget:self action:@selector(updateDateComponent:) forControlEvents:UIControlEventValueChanged];
		[self addSubview:datePicker];
 		
		[pickerView setHidden:YES];
		[self addSubview:pickerView];
		
		[self setHidden:YES];
    }
    
}

-(void) showHideViewsByFieldType:(NSString *)fieldType {

	[self initializePickers];
	if (self.hidden) {
		[self setHidden:NO];
	}
	if ([fieldType isEqualToString:DATE_PICKER]) {
		[pickerView setHidden: YES];
		[datePicker setHidden:NO];
datePicker.datePickerMode=UIDatePickerModeDate;
		//set values to datepicker
        if ([[self.dataSourceArray objectAtIndex:0] isKindOfClass:[NSDate class]]) {
            [datePicker setDate:[self.dataSourceArray objectAtIndex:0]];
        }
		
	}
    else if ([fieldType isEqualToString:TIME_PICKER]) {
		[pickerView setHidden: YES];
		[datePicker setHidden:NO];
		datePicker.datePickerMode=UIDatePickerModeTime;
		//set values to datepicker
        if ([[self.dataSourceArray objectAtIndex:0] isKindOfClass:[NSDate class]]) {
            [datePicker setDate:[self.dataSourceArray objectAtIndex:0]];
        }
		
	}
	else if ([fieldType isEqualToString:DATA_PICKER]) {
		[pickerView setHidden: NO];
		[datePicker setHidden:YES];
		
		[pickerView reloadAllComponents];
		
		if ([delegate respondsToSelector:@selector(selectDataPickerRowBasedOnValues)]) {
			[delegate performSelector:@selector(selectDataPickerRowBasedOnValues)];
		}
	}
	else if ([fieldType isEqualToString:MOVE_TO_NEXT_SCREEN]) {
		[self setHidden:YES];
	}
	else if ([fieldType isEqualToString:NUMERIC_KEY_PAD]) {
		[datePicker setHidden:YES];
		[pickerView setHidden:YES];
	}
	//add ToolBar if required
	if (toolbarRequired) {
		[self addToolBarToView];
        //Fix for ios7//JUHI
        float version=[[UIDevice currentDevice].systemVersion floatValue];
        if (version>=7.0)
        {
            CGRect frame=segmentedControl.frame;
            if ([fieldType isEqualToString:NUMERIC_KEY_PAD])
            {
                frame.origin.y=4;
                segmentedControl.frame=frame;
                
            }
            else
            {
                frame=ToolbarSegmentControlFrame;
                segmentedControl.frame=frame;
            }
        }
        

	}
}

-(void) addToolBarToView {
	if (toolbar == nil) {
		toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,45.0)];
	}
	
	[toolbar setTranslucent:YES];
	
	if (doneButton == nil) {
		doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																   target:self
																   action:@selector(doneClickAction:)];
	}
	
	if (spaceButton == nil) {
		spaceButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace 
																	target:nil
																	action:nil];
	}
	if (segmentedControl == nil) {
		segmentedControl = [[UISegmentedControl alloc] initWithItems:
							[NSArray arrayWithObjects:
							 RPLocalizedString( @"Previous",@""),
							 RPLocalizedString(@"Next",@""),nil]];
	}
	
	
	[segmentedControl setFrame:ToolbarSegmentControlFrame];
//	[segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
	[segmentedControl setWidth:70.0 forSegmentAtIndex:0];
	[segmentedControl setWidth:70.0 forSegmentAtIndex:1];
	[segmentedControl addTarget:self 
							  action:@selector(segmentClick:) 
					forControlEvents:UIControlEventValueChanged];
	[segmentedControl setMomentary:YES];
	//Fix for ios7//JUHI
    float version=[[UIDevice currentDevice].systemVersion floatValue];
    if (version>=7.0)
    {
        doneButton.tintColor=RepliconStandardWhiteColor;
        [segmentedControl setTintColor:RepliconStandardWhiteColor];
        toolbar.barStyle = UIBarStyleBlackTranslucent;
        toolbar.tintColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:0.5];

        
        
    }
	else{
        [segmentedControl setTintColor:[UIColor clearColor]];
        [toolbar setTintColor:[UIColor clearColor]];
    }
	
	NSArray *toolArray = [NSArray arrayWithObjects:
						  spaceButton,
						  doneButton,
						  nil];
	[toolbar setItems:toolArray];
	[self addSubview:toolbar];
	[self addSubview:segmentedControl];
}

-(void)showHideSegmentControl:(BOOL) hide{
if (segmentedControl != nil && hide ) {
	[segmentedControl setHidden:YES];
}else if(segmentedControl != nil && !hide) {
	[segmentedControl setHidden:NO];
}

}
#pragma mark Date update methods

-(void) updateDateComponent :(id)sender {
	
	//Handle date updation here
//	DLog(@"selected date --- %@",datePicker.date);
	if (delegate != nil && ![delegate isKindOfClass:[NSNull class]] &&
		[delegate conformsToProtocol:@protocol(DatePickerProtocol)]) {
		NSDate *selectedDate = datePicker.date;
		//[delegate updatePickedDateAtIndexPath :dateIndexPath : selectedDate];
		[delegate performSelector:@selector(updatePickedDateAtIndexPath::) withObject:dateIndexPath withObject:selectedDate];
	}
}

#pragma mark toolbar handling methods

-(void) doneClickAction:(id)sender {
	//Hide the View
	
    
    if ([delegate isKindOfClass:[G2TimeEntryViewController class]]) 
    {
        G2TimeEntryViewController *timeEntryCtrl=(G2TimeEntryViewController *)delegate;
        if (timeEntryCtrl.lastUsedTextField.tag==TIME_TAG || timeEntryCtrl.lastUsedTextField.tag==HOUR_TAG) 
        {
            [timeEntryCtrl validateTimeEntryFieldValueInCell];
            if (timeEntryCtrl.isTimeFieldValueBreak) {
                timeEntryCtrl.isTimeFieldValueBreak=NO;
                return;
            }
        }
        
        
    }
    [self setHidden:YES];
	if (delegate != nil && [delegate conformsToProtocol:@protocol(NumericKeyPadProtocol)]) {
		[delegate performSelector:@selector(resignAnyKeyPads:) withObject:otherPickerIndexPath];
	}
	
	if (delegate != nil && [delegate conformsToProtocol:@protocol(G2SegmentControlProtocol)]) {
		[delegate performSelector:@selector(doneClickAction::) withObject:segmentedControl withObject:otherPickerIndexPath];
	}
	
}
-(void) segmentClick:(UISegmentedControl *)segmentControl {
	
	DLog(@"one of segment clicked");
	
	if (delegate != nil && [delegate conformsToProtocol:@protocol(G2SegmentControlProtocol)]) {
		if (segmentControl.selectedSegmentIndex == 0) {
			//[delegate previousClickAction:segmentControl :otherPickerIndexPath];
			[delegate performSelector:@selector(previousClickAction::) withObject:segmentControl withObject:otherPickerIndexPath];
		}
		if (segmentControl.selectedSegmentIndex == 1) {
			//[delegate nextClickAction:segmentControl :otherPickerIndexPath];
			[delegate performSelector:@selector(nextClickAction::) withObject:segmentControl withObject:otherPickerIndexPath];
		}
		[segmentedControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
	}
	
}

-(void) changeSegmentControlButtonsStatus :(BOOL)enablePrevious :(BOOL)enableNext {
	if (segmentedControl != nil) {
		[segmentedControl setEnabled:enablePrevious forSegmentAtIndex:PICKER_PREVIOUS];
		[segmentedControl setEnabled:enableNext forSegmentAtIndex:PICKER_NEXT];
	}
		
}

#pragma mark -
#pragma mark Picker Delegates methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	//DLog(@"numberOfComponentsInPickerView");
	
	if (self.dataSourceArray != nil && [self.dataSourceArray count] > 0) {
		
		return [self.dataSourceArray count];
	}
	return 1;
}				 
- (CGFloat)pickerView:(UIPickerView *)pickerViewObj widthForComponent:(NSInteger)component{
	//DLog(@"widthForComponent");
	if (self.dataSourceArray != nil && [self.dataSourceArray count]>1) {
		return (280/[self.dataSourceArray count]);
	}
	return 280;
}

- (CGFloat)pickerView:(UIPickerView *)pickerViewObj rowHeightForComponent:(NSInteger)component{
	//DLog(@"rowHeightForComponent");
	
	return 40;
}
- (NSInteger)pickerView:(UIPickerView *)pickerViewObj numberOfRowsInComponent:(NSInteger)component{
	//DLog(@"numberOfRowsInComponent");
	if (self.dataSourceArray != nil && [self.dataSourceArray count] > 0 &&
		[[self.dataSourceArray objectAtIndex:component] isKindOfClass:[NSMutableArray class]]) {
        if ([[self.dataSourceArray objectAtIndex:component] count]==0)
        {
            [pickerViewObj setUserInteractionEnabled:FALSE];
        }
        else
        {
            [pickerViewObj setUserInteractionEnabled:TRUE];
        }
        //DON"T DELETE THIS NSLOG
        NSLog(@"COUNT PICKER ROWS:%lu",(unsigned long)[[self.dataSourceArray objectAtIndex:component] count]);
		return [[self.dataSourceArray objectAtIndex:component] count];
	}
    [pickerViewObj setUserInteractionEnabled:FALSE];
	return 0;
}	

- (NSString *)pickerView:(UIPickerView *)pickerViewObj titleForRow:(NSInteger)row forComponent:(NSInteger)component	
{
	//DLog(@"titleForRow::::");
	if (self.dataSourceArray != nil && [[self.dataSourceArray objectAtIndex:component] isKindOfClass:[NSMutableArray class]]) {
//		DLog(@"[[dataSourceArray objectAtIndex:component] objectAtIndex:row] %@",[[dataSourceArray objectAtIndex:component] objectAtIndex:row]);
        if ([[[self.dataSourceArray objectAtIndex:component] objectAtIndex:row] isKindOfClass:[NSMutableDictionary class]]) {
            return [[[self.dataSourceArray objectAtIndex:component] objectAtIndex:row] objectForKey:@"name"];
        }
        else
        {
            return [[self.dataSourceArray objectAtIndex:component] objectAtIndex:row];
        }
		
	}
	return nil;
}

- (void)pickerView:(UIPickerView *)pickerViewObj didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	//DLog(@"didSelectRow:::Row %d:: %d",row,component);
	if (delegate != nil && ![delegate isKindOfClass:[NSNull class]] && 
		[delegate conformsToProtocol:@protocol(DataPickerProtocol)]) {
		
		if([self.dataSourceArray count] > 1 && (component != [self.dataSourceArray count] -1)) {
			id selectedValue = [[self.dataSourceArray objectAtIndex:component] objectAtIndex:row];
			//NSMutableArray *updatedDataArray = [delegate getDependantComponentData: selectedValue];
			NSMutableArray *updatedDataArray = [delegate getDependantComponentData:otherPickerIndexPath :selectedValue : component];
			[self updateDataSourceArray:updatedDataArray component:component];
			[pickerViewObj reloadComponent:component+1];
			
			//select First row in next component by default
			[delegate updatePickerSelectedValueAtIndexPath:otherPickerIndexPath : 0 : (int)component+1];
			[pickerViewObj selectRow:0 inComponent:component+1 animated:YES];
            selectedRowForClients=row;
		}
		else {
			[delegate updatePickerSelectedValueAtIndexPath:otherPickerIndexPath : (int)row :(int)component];
            
            if (component>1) {
                if (selectedRowForClients!= [pickerViewObj selectedRowInComponent:0]) {
                    selectedRowForClients=[pickerViewObj selectedRowInComponent:0];
                    id selectedValue = [[self.dataSourceArray objectAtIndex:0] objectAtIndex:selectedRowForClients];
                    //NSMutableArray *updatedDataArray = [delegate getDependantComponentData: selectedValue];
                    NSMutableArray *updatedDataArray = [delegate getDependantComponentData:otherPickerIndexPath :selectedValue : 0];
                    [self updateDataSourceArray:updatedDataArray component:0];
                    [pickerViewObj reloadComponent:1];
                    
                    //select First row in next component by default
                    [delegate updatePickerSelectedValueAtIndexPath:otherPickerIndexPath : 0 : 1];
                    [pickerViewObj selectRow:0 inComponent:1 animated:YES];
                    
                    
                }

            }

            
                       

		}
		
	}
}
-(void)updateDataSourceArray:(NSMutableArray *)updatedDataArray component:(NSInteger)_component{
	if (updatedDataArray != nil && [updatedDataArray count]>0) {
		[self.dataSourceArray removeObjectAtIndex:_component+1];
		[self.dataSourceArray addObject:updatedDataArray];
	}
}



@end
