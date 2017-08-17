//
//  CustomKeyboardViewController.m
//  CustomKeyBoard
//
//  Created by Juhi Gautam on 08/03/13.
//  Copyright (c) 2013 Juhi Gautam. All rights reserved.
//

#import "CustomKeyboardViewController.h"

@interface CustomKeyboardViewController ()

@end

@implementation CustomKeyboardViewController
@synthesize entryDelegate;
@synthesize previousBtn;
@synthesize nextBtn;
@synthesize doneBtn;
@synthesize clearBtn;

#define KEYBOARD_HEIGHT 215
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGRect frame=self.view.frame;
        frame.origin.y=screenRect.size.height-KEYBOARD_HEIGHT;
        frame.size.width = screenRect.size.width;
        self.view.frame=frame;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [previousBtn setTitle:RPLocalizedString(@"Previous",@"") forState:UIControlStateNormal];
    [nextBtn setTitle:RPLocalizedString(@"Next",@"") forState:UIControlStateNormal];
    [clearBtn setTitle:RPLocalizedString(@"Clear",@"") forState:UIControlStateNormal];
    [doneBtn setTitle:RPLocalizedString(@"Done",@"") forState:UIControlStateNormal];
    
}
-(IBAction)minsButtonAction:(id)sender{
       
    NSString *minStr=[sender currentTitle];
    NSRange minrange=[minStr rangeOfString:@":"];
    NSUInteger index=minrange.location;
    minStr=[minStr substringFromIndex:index+1];
    
    if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
        [entryDelegate conformsToProtocol:@protocol(CustomKeyboardProtocol)])
    {
          [entryDelegate minsFieldUpdatedWithText:minStr];
        
    }
}
-(IBAction)amButtonAction:(id)sender{
    
    
    NSString *timestr=[sender currentTitle];
    NSString*hourstr=nil;
    NSString *format=nil;
    NSRange amRange=[timestr rangeOfString:@"am"];
    NSUInteger index=amRange.location;
    hourstr=[timestr substringToIndex:index];
    format=[timestr substringFromIndex:index];
    if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
        [entryDelegate conformsToProtocol:@protocol(CustomKeyboardProtocol)])
    {
        [entryDelegate hoursFieldUpdatedWithText:hourstr andFormat:format];
        
    }
}
-(IBAction)pmButtonAction:(id)sender{
    
    
    NSString *timestr=[sender currentTitle];
    NSString*hourstr=nil;
    NSString *format=nil;
    NSRange pmRange=[timestr rangeOfString:@"pm"];
    NSUInteger index=pmRange.location;
    hourstr=[timestr substringToIndex:index];
    format=[timestr substringFromIndex:index];
    if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
        [entryDelegate conformsToProtocol:@protocol(CustomKeyboardProtocol)])
    {
        [entryDelegate hoursFieldUpdatedWithText:hourstr andFormat:format];
        
    }

}
-(IBAction)doneButtonAction:(id)sender{
    
    if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
        [entryDelegate conformsToProtocol:@protocol(CustomKeyboardProtocol)])
    {
        [entryDelegate doneButtonPressed];
        
    }
}
-(IBAction)clearButtonAction:(id)sender{
    if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
        [entryDelegate conformsToProtocol:@protocol(CustomKeyboardProtocol)])
    {
        [entryDelegate clearButtonPressed];
        
    }
}
-(IBAction)nextButtonAction:(id)sender{
    if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
        [entryDelegate conformsToProtocol:@protocol(CustomKeyboardProtocol)])
    {
        [entryDelegate nextButtonPressed];
        
    }
}
-(IBAction)previousButtonAction:(id)sender{
    if (entryDelegate != nil && ![entryDelegate isKindOfClass:[NSNull class]] &&
        [entryDelegate conformsToProtocol:@protocol(CustomKeyboardProtocol)])
    {
        [entryDelegate previousButtonPressed];
        
    }
}
-(void)enableAndDisablePreviousButton:(BOOL)isPrevious andNextButton:(BOOL)isNext{
    
    [previousBtn setEnabled:isPrevious];
    [nextBtn setEnabled:isNext];
    
    if (isPrevious==NO && isNext==YES)
    {
       [self.previousBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
       [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
       
    }
    else if(isPrevious==YES && isNext==NO)
    {
        [self.previousBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.nextBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
    else
    {
        [self.previousBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
