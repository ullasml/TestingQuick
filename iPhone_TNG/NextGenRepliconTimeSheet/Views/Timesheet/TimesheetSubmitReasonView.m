//
//  TimesheetSubmitReasonView.m
//  NextGenRepliconTimeSheet
//
//  Created by juhigautam on 10/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import "TimesheetSubmitReasonView.h"
#import "Constants.h"
@implementation TimesheetSubmitReasonView
@synthesize reasonArray;
@synthesize reasonDate;


- (id)initWithFrame:(CGRect)frame andReasonData:(NSMutableArray *)reasondetail headerHeight:(float)height
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        reasonArray=reasondetail;
        headerHight=height;
        [self drawLayout];
    }
    return self;
}
-(void)drawLayout
{
    if (reasonDate==nil)
    {
        UILabel *tempfieldName = [[UILabel alloc]init];
        self.reasonDate=tempfieldName;
        
    }
    
    [self setBackgroundColor:[Util colorWithHex:@"#EEEEEE" alpha:1]];
    
    [self.reasonDate setFrame:CGRectMake(12, 8, self.frame.size.width-12, headerHight)];
    [self.reasonDate setNumberOfLines:100];
    [self.reasonDate setTextColor:RepliconStandardBlackColor];
    [self.reasonDate setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
    [self.reasonDate setUserInteractionEnabled:NO];
    [self.reasonDate setBackgroundColor:[UIColor clearColor]];
    [self.reasonDate setHighlightedTextColor:RepliconStandardWhiteColor];
    [self addSubview:reasonDate];
    
    if ([reasonArray count]>0)
    {
        float y=headerHight;
        
        for (int i=0; i<[reasonArray count]; i++)
        {
            NSMutableDictionary *detailDict=[reasonArray objectAtIndex:i];
            UILabel *reasonValue = [[UILabel alloc]init];
            float reasonlabelHeight = [self getHeightForString:[NSString stringWithFormat:@"- %@",[detailDict objectForKey:@"header"]] fontSize:RepliconFontSize_14 forWidth:self.frame.size.width-12];
            [reasonValue setFrame:CGRectMake(12, y+15.0, self.frame.size.width-12, reasonlabelHeight)];
            reasonValue.numberOfLines=100;
            [reasonValue setTextColor:RepliconStandardBlackColor];
            [reasonValue setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
            [reasonValue setUserInteractionEnabled:NO];
            [reasonValue setBackgroundColor:[UIColor clearColor]];
            [reasonValue setText:[NSString stringWithFormat:@"- %@",[detailDict objectForKey:@"header"]]];
            [reasonValue setHighlightedTextColor:RepliconStandardWhiteColor];
            [self addSubview:reasonValue];
            y=y+reasonlabelHeight;
            if ([detailDict objectForKey:@"modifications"]!=nil && ![[detailDict objectForKey:@"modifications"] isKindOfClass:[NSNull class]] )
            {
                NSArray *subReasonArray=[detailDict objectForKey:@"modifications"];
                
                for (int j=0; j<[subReasonArray count]; j++)
                {
                    UILabel *subReasonValue = [[UILabel alloc]init];
                    float subReasonlabelHeight = [self getHeightForString:[NSString stringWithFormat:@"* %@",[subReasonArray objectAtIndex:j]] fontSize:RepliconFontSize_14 forWidth:self.frame.size.width-12];
                    [subReasonValue setFrame:CGRectMake(54, y+15.0, self.frame.size.width-54, subReasonlabelHeight)];
                     subReasonValue.numberOfLines=100;
                    [subReasonValue setTextColor:RepliconStandardBlackColor];
                    [subReasonValue setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_14]];
                    [subReasonValue setUserInteractionEnabled:NO];
                    [subReasonValue setBackgroundColor:[UIColor clearColor]];
                    [subReasonValue setText:[NSString stringWithFormat:@"* %@",[subReasonArray objectAtIndex:j]]];
                    [subReasonValue setHighlightedTextColor:RepliconStandardWhiteColor];
                    [self addSubview:subReasonValue];
                    y=y+subReasonlabelHeight;
                
                }
                
            }
            
        }
        
        
    }
    
    
    
    
}
-(float)getHeightForString:(NSString *)string fontSize:(int)fontSize forWidth:(float)width
{
    // Let's make an NSAttributedString first
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    //Add LineBreakMode
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString setAttributes:@{NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, attributedString.length)];
    // Add Font
    [attributedString setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} range:NSMakeRange(0, attributedString.length)];
    
    //Now let's make the Bounding Rect
    CGSize mainSize  = [attributedString boundingRectWithSize:CGSizeMake(width, 10000)  options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    if (mainSize.width==0 && mainSize.height ==0)
    {
        mainSize=CGSizeMake(0,0);
    }
    float version= [[UIDevice currentDevice].systemVersion newFloatValue];
    if (version>=7.0)
    {
        NSString *fontName=nil;
        if (fontSize==RepliconFontSize_16)
        {
            fontName=RepliconFontFamilyBold;
        }
        else
        {
            fontName=RepliconFontFamily;
        }
        CGSize maxSize = CGSizeMake(width, MAXFLOAT);
        CGRect labelRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:fontName size:fontSize]} context:nil];
        return labelRect.size.height;
    }
    return mainSize.height;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
