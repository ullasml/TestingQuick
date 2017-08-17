//
//  CustomPickerView.m
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 04/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import "CustomPickerView.h"
#import "CurrentTimesheetViewController.h"

@implementation CustomPickerView
@synthesize delegate;
@synthesize pickerView;
@synthesize dataSourceArray;
@synthesize doneButton;
@synthesize toolbar;

#pragma mark -
#pragma mark Picker intialisation

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
        if (toolbar == nil)
        {
			toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,
                                                                  0,
                                                                  320,
                                                                  45.0)];
		}
		//Fix for ios7//JUHI
        float version= [[UIDevice currentDevice].systemVersion newFloatValue];
        
        if (version<7.0)
        {
            [toolbar setTintColor:[UIColor clearColor]];
        }
        else
            
        {
            self.doneButton.tintColor=RepliconStandardWhiteColor;
            UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
            [toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
            [toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
            [toolbar setBarStyle:UIBarStyleBlackTranslucent];
        }
		[toolbar setOpaque:YES];
        self.toolbar.barStyle = UIBarStyleBlackOpaque;
		[self addSubview:toolbar];
		

    }
    return self;
}

-(void) initializePickers
{
	
	if (pickerView == nil)
    {
		UIPickerView *temppickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        self.pickerView=temppickerView;
        
		CGSize pickerSize = [pickerView sizeThatFits:CGSizeZero];
		[pickerView setFrame:CGRectMake(0.0,
										0.0 ,
										pickerSize.width,
										pickerSize.height)];
		pickerView.delegate = self;
		pickerView.dataSource = self;
		pickerView.showsSelectionIndicator = YES;
		[self addSubview:pickerView];
        
    }
    if (toolbar == nil)
    {
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,45.0)];
    }
    //Fix for ios7//JUHI
	float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    
    if (version<7.0)
    {
        [toolbar setTintColor:[UIColor clearColor]];
    }
    else
        
    {
        self.doneButton.tintColor=RepliconStandardWhiteColor;
        UIImage *backgroundImage = [Util thumbnailImage:TOOLBAR_IMAGE];
        [toolbar setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
        [toolbar setTintColor:[Util colorWithHex:@"#dddddd" alpha:1]];
        [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    }
    [toolbar setTranslucent:YES];
    
    if (doneButton == nil) {
        doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                   target:self
                                                                   action:@selector(doneClickAction:)];
    }
    
    
    
    NSArray *toolArray = [NSArray arrayWithObjects:doneButton,nil];
    [toolbar setItems:toolArray];
    [self addSubview:toolbar];
    
    if (delegate != nil && [delegate isKindOfClass:[TimesheetMainPageController class]])
    {
        [toolbar setHidden:YES];
        
    }

}


#pragma mark -
#pragma mark Picker Done method

-(void) doneClickAction:(id)sender
{
    if (delegate != nil && [delegate conformsToProtocol:@protocol(SegmentControlProtocol)])
    {
		[delegate performSelector:@selector(pickerDoneClickAction:)];
	}
    
}


#pragma mark -
#pragma mark Picker Delegates methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{

	return 1;
}
- (CGFloat)pickerView:(UIPickerView *)pickerViewObj widthForComponent:(NSInteger)component
{
	return 280;
}

- (CGFloat)pickerView:(UIPickerView *)pickerViewObj rowHeightForComponent:(NSInteger)component
{
	return 40;
}
- (NSInteger)pickerView:(UIPickerView *)pickerViewObj numberOfRowsInComponent:(NSInteger)component
{
	
	if (self.dataSourceArray != nil && [self.dataSourceArray count] > 0 )
    {
        if ([(NSMutableArray *)[self.dataSourceArray objectAtIndex:component] count]==0)
        {
            [pickerViewObj setUserInteractionEnabled:FALSE];
        }
        else
        {
            [pickerViewObj setUserInteractionEnabled:TRUE];
        }
		return [self.dataSourceArray count];
	}
    [pickerViewObj setUserInteractionEnabled:FALSE];
	return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerViewObj titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.dataSourceArray != nil && ![self.dataSourceArray isKindOfClass:[NSNull class]] &&[self.dataSourceArray count]>0)
    {
        
        if ([[self.dataSourceArray objectAtIndex:row]  isKindOfClass:[NSDictionary class]]||[[self.dataSourceArray objectAtIndex:row]  isKindOfClass:[NSMutableDictionary class]])
        {
            return [[self.dataSourceArray objectAtIndex:row]  objectForKey:@"timeoffTypeName"];
        }
        else
        {
            return [self.dataSourceArray objectAtIndex:row];
        }
        
    }
	return nil;
}

- (void)pickerView:(UIPickerView *)pickerViewObj didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}

#pragma mark -
#pragma mark memory management



@end
