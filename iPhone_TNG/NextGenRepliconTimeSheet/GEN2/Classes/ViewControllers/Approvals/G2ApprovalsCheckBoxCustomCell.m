//
//  ApprovalsCheckBoxCustomCell.m
//  Replicon
//
//  Created by Dipta Rakshit on 2/7/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import "G2ApprovalsCheckBoxCustomCell.h"
#import "G2Constants.h"
#import "G2Util.h"

@implementation G2ApprovalsCheckBoxCustomCell
@synthesize  leftLbl;
@synthesize  rightLbl;
@synthesize  lineImageView;
//@synthesize  commonCellDelegate;
@synthesize  radioButton;
@synthesize  userSelected;
@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)createCellLayoutWithParams:(NSString *)leftString   rightstr:(NSString *)rightString hairlinerequired:(BOOL)_hairlinereq radioButtonTag:(NSInteger)tagValue  overTimerequired:(BOOL)overTimeReq mealrequired:(BOOL)mealReq timeOffrequired:(BOOL)timeOffReq regularRequired:(BOOL)regularReq overTimeStr:(NSString *)overTimeString mealStr:(NSString *)mealString timeOffStr:(NSString *)timeOffString regularStr:(NSString *)regularString
{

    UIImage *radioDeselectedImage = [G2Util thumbnailImage:ApproverCheckBoxDeselectedImage];
    
    
	if (radioButton == nil) {
		radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[radioButton setFrame:CGRectMake(0,0.0 ,radioDeselectedImage.size.width+20.0 ,
										 radioDeselectedImage.size.height+19.0)];
         [radioButton setImage:radioDeselectedImage forState:UIControlStateHighlighted];
	}
	[radioButton setBackgroundColor:[UIColor clearColor]];
   
	[radioButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[radioButton setUserInteractionEnabled:YES];
    [radioButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 8.0, -1, 0.0)];
	[radioButton setHidden:NO];
	[radioButton setTag:tagValue];
	
    [radioButton addTarget:self action:@selector(selectTaskRadioButton:) forControlEvents:UIControlEventTouchUpInside];
	[self.contentView addSubview:radioButton];
    
    if (leftLbl == nil) {
		UILabel *templeftLbl = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 8.0, 145.0, 20.0)];
        self.leftLbl=templeftLbl;
        
	}
	[self.leftLbl setBackgroundColor:[UIColor clearColor]];
    [self.leftLbl setTextColor:RepliconStandardBlackColor];
	
	[self.leftLbl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
	[self.leftLbl setTextAlignment:NSTextAlignmentLeft];
	[self.leftLbl setText:leftString];
	[self.leftLbl setNumberOfLines:1];
	[self.contentView addSubview:self.leftLbl];
	
	if (rightLbl == nil) {
		UILabel *temprightLbl = [[UILabel alloc] initWithFrame:CGRectMake(210.0, 8.0, 100.0, 20.0)];
        self.rightLbl=temprightLbl;
        
	}
	
    [self.rightLbl setBackgroundColor:[UIColor clearColor]];
    [self.rightLbl setTextColor:RepliconStandardBlackColor];
    
    [self.rightLbl setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_15]];
    [self.rightLbl setTextAlignment:NSTextAlignmentRight];
    [self.rightLbl setText:rightString];
    [self.rightLbl setNumberOfLines:1];
    [self.contentView addSubview:self.rightLbl];
	
	 [self createRightLowerWithOverTimerequired:overTimeReq mealrequired:mealReq timeOffrequired:timeOffReq regularRequired:regularReq overTimeStr:overTimeString mealStr:mealString timeOffStr:timeOffString regularStr:regularString]; 
	
    [self.leftLbl setHighlightedTextColor:iosStandaredWhiteColor];
	[self.rightLbl setHighlightedTextColor:iosStandaredWhiteColor]; 
    
    
	UIImage *lineImage = [G2Util thumbnailImage:G2Cell_HairLine_Image];
	if (lineImageView == nil) {
		UIImageView *templineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 42.0, 320.0,lineImage.size.height)];
        self.lineImageView=templineImageView;
       
	}
	[lineImageView setImage:lineImage];
	if (_hairlinereq) {
		[self.contentView addSubview:lineImageView];
	}
}


-(void)selectTaskRadioButton:(id)sender {
	
    UIImage *currentRadioButtonImage= [sender imageForState:UIControlStateNormal];
    
    if (currentRadioButtonImage == [G2Util thumbnailImage:ApproverCheckBoxSelectedImage]) {
        UIImage *deselectedRadioImage = [G2Util thumbnailImage:ApproverCheckBoxDeselectedImage];
        if (radioButton != nil) {
            [radioButton setImage:deselectedRadioImage forState:UIControlStateNormal];
            [radioButton setImage:deselectedRadioImage forState:UIControlStateHighlighted];
            [self setUserSelected:NO];
        }
    }
    else
    {
        UIImage *selectedRadioImage = [G2Util thumbnailImage:ApproverCheckBoxSelectedImage];
        if (radioButton != nil) {
            [radioButton setImage:selectedRadioImage forState:UIControlStateNormal];
             [radioButton setImage:selectedRadioImage forState:UIControlStateHighlighted];
            [self setUserSelected:YES];
        }
    }
    
    NSIndexPath *indexPath =nil;
    
    if ([self.superview isKindOfClass:[UITableView class]])
        indexPath = [(UITableView *)self.superview indexPathForCell: self];
    else if ([self.superview.superview isKindOfClass:[UITableView class]])
        indexPath = [(UITableView *)self.superview.superview indexPathForCell: self];
    else
    {
        
    }
    
    if (indexPath!=nil)
    {
        if ([delegate respondsToSelector:@selector(handleButtonClickforSelectedUser:isSelected:)])
            [delegate handleButtonClickforSelectedUser:indexPath isSelected:self.userSelected];
    }
    
  

}


-(void)createRightLowerWithOverTimerequired:(BOOL)overTimeReq mealrequired:(BOOL)mealReq timeOffrequired:(BOOL)timeOffReq regularRequired:(BOOL)regularReq overTimeStr:(NSString *)overTimeString mealStr:(NSString *)mealString timeOffStr:(NSString *)timeOffString regularStr:(NSString *)regularString
{
    
    UIImage *greenBoxImage=[G2Util thumbnailImage:MealBreaks_Green_Box];
    UIImage *blueBoxImage=[G2Util thumbnailImage:MealBreaks_Blue_Box];
    UIImage *grayBoxImage=[G2Util thumbnailImage:MealBreaks_Gray_Box];
    UIImage *yellowBoxImage=[G2Util thumbnailImage:MealBreaks_Yellow_Box];
    

    
    if (mealReq && timeOffReq && overTimeReq && regularReq)
    {
        int x=55;
        int offset=0;
        for (int i=0; i<4; i++)
        {
            UIButton *rightLowerbt =[[UIButton alloc]init];    
            [rightLowerbt setFrame:CGRectMake(x, 30.0, greenBoxImage.size.width, greenBoxImage.size.height)];
            
            [rightLowerbt setClipsToBounds: YES];
            [rightLowerbt setBackgroundColor:[UIColor clearColor]];
            [rightLowerbt setUserInteractionEnabled:NO];
            
            [rightLowerbt setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal ];
            [rightLowerbt.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            [rightLowerbt.titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            if (i==0)
            {
                [rightLowerbt setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal ];
                [rightLowerbt setTitle:mealString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateHighlighted];
            }
            else if (i==1)
            {
                [rightLowerbt setTitle:timeOffString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateHighlighted];
                
            }
             else if (i==2)
            {
                [rightLowerbt setTitle:overTimeString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateHighlighted];
                
            }
             else if (i==3)
            {
               
                [rightLowerbt setTitle:regularString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateHighlighted];
                
            }
            [self.contentView addSubview:rightLowerbt];
            x=x+64.99+offset;
            
        }
        
    }//
    if (mealReq && timeOffReq && overTimeReq && !regularReq)
    {
        int x=119;
        int offset=0;
        for (int i=0; i<3; i++)
        {
            UIButton *rightLowerbt =[[UIButton alloc]init]; 
            // For rounded corners
            [rightLowerbt setFrame:CGRectMake(x, 30.0,greenBoxImage.size.width, greenBoxImage.size.height)];
          
            [rightLowerbt setClipsToBounds: YES];
            [rightLowerbt setBackgroundColor:[UIColor clearColor]];
            [rightLowerbt setUserInteractionEnabled:NO];
            
            [rightLowerbt setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal ];
            [rightLowerbt.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            [rightLowerbt.titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            if (i==0)
            {
                [rightLowerbt setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal ];
                [rightLowerbt setTitle:mealString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateHighlighted];
            }
            else if (i==1)
            {
                [rightLowerbt setTitle:timeOffString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateHighlighted];
                
            }
            else if (i==2)
            {
                [rightLowerbt setTitle:overTimeString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateHighlighted];
                
            }
            
            [self.contentView addSubview:rightLowerbt];
            x=x+64.99+offset;
            
        }
        
        
    }//
    if (mealReq && timeOffReq && !overTimeReq && regularReq)
    {
        int x=119;
        int offset=0;
        for (int i=0; i<3; i++)
        {
            UIButton *rightLowerbt =[[UIButton alloc]init]; 
            // For rounded corners
            [rightLowerbt setFrame:CGRectMake(x, 30.0, greenBoxImage.size.width, greenBoxImage.size.height)];
           
            [rightLowerbt setClipsToBounds: YES];
            [rightLowerbt setBackgroundColor:[UIColor clearColor]];
            [rightLowerbt setUserInteractionEnabled:NO];
            
            [rightLowerbt setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal ];
            [rightLowerbt.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            [rightLowerbt.titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            if (i==0)
            {
                [rightLowerbt setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal ];
                [rightLowerbt setTitle:mealString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateHighlighted];
            }
            else if (i==1)
            {
                [rightLowerbt setTitle:timeOffString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateHighlighted];
                
            }
            else if (i==2)
            {
                [rightLowerbt setTitle:regularString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateHighlighted];
                
            }
            [self.contentView addSubview:rightLowerbt];
            x=x+64.99+offset;
           
        }
        
    }//
    if (mealReq && !timeOffReq && overTimeReq && regularReq)
    {
        int x=119;
        int offset=0;
        for (int i=0; i<3; i++)
        {
            UIButton *rightLowerbt =[[UIButton alloc]init];
            // For rounded corners
            [rightLowerbt setFrame:CGRectMake(x, 30.0, greenBoxImage.size.width, greenBoxImage.size.height)];
          
            [rightLowerbt setClipsToBounds: YES];
            [rightLowerbt setBackgroundColor:[UIColor clearColor]];
            [rightLowerbt setUserInteractionEnabled:NO];
            
            [rightLowerbt setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal ];
            [rightLowerbt.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            [rightLowerbt.titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            if (i==0)
            {
                [rightLowerbt setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal ];
                [rightLowerbt setTitle:mealString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateHighlighted];
            }
            else if (i==1)
            {
                [rightLowerbt setTitle:overTimeString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateHighlighted];
                
            }
            else if (i==2)
            {
                [rightLowerbt setTitle:regularString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateHighlighted];
                
            }
            [self.contentView addSubview:rightLowerbt];
            x=x+64.99+offset;
            
        }
        
    }//
    if (!mealReq && timeOffReq && overTimeReq && regularReq)
    {
        int x=119;
        int offset=0;
        for (int i=0; i<3; i++)
        {
            UIButton *rightLowerbt =[[UIButton alloc]init]; 
            // For rounded corners
            [rightLowerbt setFrame:CGRectMake(x, 30.0, greenBoxImage.size.width, greenBoxImage.size.height)];
           
            [rightLowerbt setClipsToBounds: YES];
            [rightLowerbt setBackgroundColor:[UIColor clearColor]];
            [rightLowerbt setUserInteractionEnabled:NO];
            
            [rightLowerbt setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal ];
            [rightLowerbt.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            [rightLowerbt.titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            if (i==0)
            {
                [rightLowerbt setTitle:timeOffString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateHighlighted];
                
            }
            else if (i==1)
            {
                [rightLowerbt setTitle:overTimeString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateHighlighted];
                
            }
            else if (i==2)
            {
                
                [rightLowerbt setTitle:regularString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateHighlighted];
                
            }
            [self.contentView addSubview:rightLowerbt];
            x=x+64.99+offset;
            
        }
        
        
    }//
    if (mealReq && timeOffReq && !overTimeReq && !regularReq)
    {
        int x=183;
        int offset=0;
        for (int i=0; i<2; i++)
        {
            UIButton *rightLowerbt =[[UIButton alloc]init]; 
            // For rounded corners
            [rightLowerbt setFrame:CGRectMake(x, 30.0,greenBoxImage.size.width, greenBoxImage.size.height)];
           
            [rightLowerbt setClipsToBounds: YES];
            [rightLowerbt setBackgroundColor:[UIColor clearColor]];
            [rightLowerbt setUserInteractionEnabled:NO];
            
            [rightLowerbt setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal ];
            [rightLowerbt.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            [rightLowerbt.titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            if (i==0)
            {
                [rightLowerbt setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal ];
                [rightLowerbt setTitle:mealString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateHighlighted];
            }
            else if (i==1)
            {
                [rightLowerbt setTitle:timeOffString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateHighlighted];
                
            }
            
            [self.contentView addSubview:rightLowerbt];
            x=x+64.99+offset;
            
        }
        
    }//
    if (mealReq && !timeOffReq && overTimeReq && !regularReq)
    {
        int x=183;
        int offset=0;
        for (int i=0; i<2; i++)
        {
            UIButton *rightLowerbt =[[UIButton alloc]init]; 
            // For rounded corners
            [rightLowerbt setFrame:CGRectMake(x, 30.0, greenBoxImage.size.width, greenBoxImage.size.height)];
            
            [rightLowerbt setClipsToBounds: YES];
            [rightLowerbt setBackgroundColor:[UIColor clearColor]];
            [rightLowerbt setUserInteractionEnabled:NO];
            
            [rightLowerbt setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal ];
            [rightLowerbt.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            [rightLowerbt.titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            if (i==0)
            {
                [rightLowerbt setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal ];
                [rightLowerbt setTitle:mealString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateHighlighted];
            }
            else if (i==1)
            {
                [rightLowerbt setTitle:overTimeString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateHighlighted];
                
            }
            [self.contentView addSubview:rightLowerbt];
            x=x+64.99+offset;
           
        }
        
        
    }//
    if (mealReq && !timeOffReq && !overTimeReq && regularReq)
    {
        int x=183;
        int offset=0;
        for (int i=0; i<2; i++)
        {
            UIButton *rightLowerbt =[[UIButton alloc]init]; 
            // For rounded corners
            [rightLowerbt setFrame:CGRectMake(x, 30.0, greenBoxImage.size.width, greenBoxImage.size.height)];
          
            [rightLowerbt setClipsToBounds: YES];
            [rightLowerbt setBackgroundColor:[UIColor clearColor]];
            [rightLowerbt setUserInteractionEnabled:NO];
            
            [rightLowerbt setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal ];
            [rightLowerbt.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            [rightLowerbt.titleLabel setTextAlignment:NSTextAlignmentCenter];
            
            if (i==0)
            {
                [rightLowerbt setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal ];
                [rightLowerbt setTitle:mealString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateHighlighted];
            }
            else if (i==1)
            {
               
                [rightLowerbt setTitle:regularString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateHighlighted];
                
            }
            [self.contentView addSubview:rightLowerbt];
            x=x+64.99+offset;
           
        }
        
        
    }//
    if (!mealReq && !timeOffReq && overTimeReq && regularReq)
    {
        int x=183;
        int offset=0;
        for (int i=0; i<2; i++)
        {
            UIButton *rightLowerbt =[[UIButton alloc]init]; 
            // For rounded corners
            [rightLowerbt setFrame:CGRectMake(x, 30.0, greenBoxImage.size.width, greenBoxImage.size.height)];
           
            [rightLowerbt setClipsToBounds: YES];
            [rightLowerbt setBackgroundColor:[UIColor clearColor]];
            [rightLowerbt setUserInteractionEnabled:NO];
            
            [rightLowerbt setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal ];
            [rightLowerbt.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            [rightLowerbt.titleLabel setTextAlignment:NSTextAlignmentCenter];
            if (i==0)
            {
                [rightLowerbt setTitle:overTimeString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateHighlighted];
                
            }
            else if (i==1)
            {
                [rightLowerbt setTitle:regularString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateHighlighted];
                
            }
            [self.contentView addSubview:rightLowerbt];
            x=x+64.99+offset;
           
        }
        
    }//
    if (!mealReq && timeOffReq && !overTimeReq && regularReq)
    {
        int x=183;
        int offset=0;
        for (int i=0; i<2; i++)
        {
            UIButton *rightLowerbt =[[UIButton alloc]init]; 
            // For rounded corners
            [rightLowerbt setFrame:CGRectMake(x, 30.0,greenBoxImage.size.width, greenBoxImage.size.height)];
           
            [rightLowerbt setClipsToBounds: YES];
            [rightLowerbt setBackgroundColor:[UIColor clearColor]];
            [rightLowerbt setUserInteractionEnabled:NO];
            
            [rightLowerbt setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal ];
            [rightLowerbt.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            [rightLowerbt.titleLabel setTextAlignment:NSTextAlignmentCenter];
            if (i==0)
            {
                [rightLowerbt setTitle:timeOffString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateHighlighted];
                
            }
            else if (i==1)
            {
                [rightLowerbt setTitle:regularString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateHighlighted];
                
            }
            [self.contentView addSubview:rightLowerbt];
            x=x+64.99+offset;
           
        }
        
    }//
    if (!mealReq && timeOffReq && overTimeReq && !regularReq)
    {
        int x=183;
        int offset=0;
        for (int i=0; i<2; i++)
        {
            UIButton *rightLowerbt =[[UIButton alloc]init]; 
            // For rounded corners
            [rightLowerbt setFrame:CGRectMake(x, 30.0, greenBoxImage.size.width, greenBoxImage.size.height)];
            
            [rightLowerbt setClipsToBounds: YES];
            [rightLowerbt setBackgroundColor:[UIColor clearColor]];
            [rightLowerbt setUserInteractionEnabled:NO];
            
            [rightLowerbt setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal ];
            [rightLowerbt.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
            [rightLowerbt.titleLabel setTextAlignment:NSTextAlignmentCenter];
            if (i==0)
            {
                [rightLowerbt setTitle:timeOffString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateHighlighted];
                
            }
            else if (i==1)
            {
                [rightLowerbt setTitle:overTimeString forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateNormal];
                [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateHighlighted];
                
            }
            [self.contentView addSubview:rightLowerbt];
            x=x+64.99+offset;
            
        }
        
    }//
    else
    {
        UIButton *rightLowerbt =[[UIButton alloc]init]; 
        // For rounded corners
        [rightLowerbt setFrame:CGRectMake(247, 30.0, greenBoxImage.size.width, greenBoxImage.size.height)];
        
        [rightLowerbt setClipsToBounds: YES];
        [rightLowerbt setBackgroundColor:[UIColor clearColor]];
        [rightLowerbt setUserInteractionEnabled:NO];
        
        [rightLowerbt setTitleColor:RepliconStandardWhiteColor forState:UIControlStateNormal ];
        [rightLowerbt.titleLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
        [rightLowerbt.titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        
        if (mealReq && !timeOffReq && !overTimeReq && !regularReq)
        {
            [rightLowerbt setTitleColor:RepliconStandardBlackColor forState:UIControlStateNormal ];
            [rightLowerbt setTitle:mealString forState:UIControlStateNormal];
            [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateNormal];
            [rightLowerbt setBackgroundImage:yellowBoxImage forState:UIControlStateHighlighted];
            
        }
        else if (!mealReq && timeOffReq && !overTimeReq && !regularReq)
        {
            [rightLowerbt setTitle:timeOffString forState:UIControlStateNormal];
            [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateNormal];
            [rightLowerbt setBackgroundImage:grayBoxImage forState:UIControlStateHighlighted];
        }
        else if (!mealReq && !timeOffReq && overTimeReq && !regularReq)
        {
            [rightLowerbt setTitle:overTimeString forState:UIControlStateNormal];
            [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateNormal];
            [rightLowerbt setBackgroundImage:blueBoxImage forState:UIControlStateHighlighted];
        }
        else if (!mealReq && !timeOffReq && !overTimeReq && regularReq)
        {
            [rightLowerbt setTitle:regularString forState:UIControlStateNormal];
            [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateNormal];
            [rightLowerbt setBackgroundImage:greenBoxImage forState:UIControlStateHighlighted];
        }
        else
            rightLowerbt.hidden=YES;
        [self.contentView addSubview:rightLowerbt];
        
        
        
        
    }
    
}



@end
