//
//  ExpensesCellView.m
//  RepliconHomee
//
//  Created by Manoj  on 30/01/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2ExpensesCellView.h"
#import "G2Util.h"

@implementation G2ExpensesCellView

@synthesize trackingLabel,recieptImageView,
titleDetailsLable,
secondCostLabel,
dateLable,
cosetLable,
statusLable,client_projectLabel;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		UIImage *img = [G2Util thumbnailImage:cellBackgroundImageView];
		UIImageView *backGroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
		[backGroundImageView setImage:img];
		[self.contentView addSubview:backGroundImageView];
		
		
	}
	return self;
}

-(void)createExpDetailsLables 
{
	if (dateLable==nil) {
		UILabel *tempdateLable = [[UILabel alloc] initWithFrame:CGRectMake(13, 7, 180, 20)];
        self.dateLable=tempdateLable;
        
	}
	[dateLable setBackgroundColor:[UIColor clearColor]];
	[dateLable setTextColor:RepliconStandardGrayColor];
	[dateLable setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
	[dateLable setTextAlignment:NSTextAlignmentLeft];
	[dateLable setNumberOfLines:1];
	[self.contentView addSubview:dateLable];
	
	
	if (titleDetailsLable==nil) {
		UILabel *temptitleDetailsLable = [[UILabel alloc] initWithFrame:CGRectMake(13, 27, 180, 30)]; //25y
        self.titleDetailsLable=temptitleDetailsLable;
        
	}
	
	[titleDetailsLable setBackgroundColor:[UIColor clearColor]];
	[titleDetailsLable setTextColor:RepliconStandardBlackColor];
	[titleDetailsLable setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_20]];
	[titleDetailsLable setTextAlignment:NSTextAlignmentLeft];
	[titleDetailsLable setNumberOfLines:1];
	[self.contentView addSubview:titleDetailsLable];
	
	if (trackingLabel==nil) {
		UILabel *temptrackingLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 60, 160, 16)]; //60
        self.trackingLabel=temptrackingLabel;
        
	}
	
	[trackingLabel setBackgroundColor:[UIColor clearColor]];
	[trackingLabel setTextColor:[UIColor blackColor]];
	[trackingLabel setTextColor:RepliconStandardGrayColor];
	[trackingLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
	
	[trackingLabel setTextAlignment:NSTextAlignmentLeft];
	[trackingLabel setNumberOfLines:1];
	[self.contentView addSubview:trackingLabel];
	
	if (statusLable==nil) {
		UILabel *tempstatusLable = [[UILabel alloc] initWithFrame:CGRectMake(150, 60, 158, 16)];
        self.statusLable=tempstatusLable;
        
	}
	[statusLable setBackgroundColor:[UIColor clearColor]];
	[statusLable setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_12]];
	[statusLable setTextAlignment:NSTextAlignmentRight];
	[statusLable setNumberOfLines:1];
	[self.contentView addSubview:statusLable];
}


-(void)addCostLable
{
	if (cosetLable==nil) {
		UILabel *tempcosetLable = [[UILabel alloc] initWithFrame:CGRectMake(130, 7, 180, 20)]; //20
        self.cosetLable=tempcosetLable;
        
		[cosetLable setBackgroundColor:[UIColor clearColor]];
		[cosetLable setTextColor:RepliconStandardBlackColor];
		[cosetLable setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14]];
		[cosetLable setTextAlignment:NSTextAlignmentRight];
		[cosetLable setNumberOfLines:1];
		[self.contentView addSubview:cosetLable];
	}
	
	if (secondCostLabel==nil) {
	UILabel *tempsecondCostLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 30, 158, 20)]; //20
        self.secondCostLabel  =tempsecondCostLabel;
        
	[secondCostLabel setBackgroundColor:[UIColor clearColor]];
	[secondCostLabel setTextColor:RepliconStandardBlackColor];
	[secondCostLabel setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14]];
	[secondCostLabel setTextAlignment:NSTextAlignmentRight];
	[secondCostLabel setNumberOfLines:1];
	[self.contentView addSubview:secondCostLabel];
	}

}

-(void)createExpenseEntriesfields 
{
	if (dateLable==nil) {
		UILabel *tempdateLable = [[UILabel alloc] initWithFrame:CGRectMake(13, 7, 180, 20)];
        self.dateLable=tempdateLable;
        
	}
	[dateLable setBackgroundColor:[UIColor clearColor]];
	[dateLable setTextColor:RepliconStandardGrayColor];
	[dateLable setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
	[dateLable setTextAlignment:NSTextAlignmentLeft];
	[dateLable setNumberOfLines:2];
	[self.contentView addSubview:dateLable];

	
	if (client_projectLabel==nil) {
		//client_projectLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 59, 160, 16)]; //60
		UILabel *tempclient_projectLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 27, 180, 30)]; //60
        self.client_projectLabel=tempclient_projectLabel;
        
	}
	
	[client_projectLabel setBackgroundColor:[UIColor clearColor]];
	[client_projectLabel setTextColor:RepliconStandardBlackColor];
	[client_projectLabel setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_20]];
	[client_projectLabel setTextAlignment:NSTextAlignmentLeft];
	[client_projectLabel setNumberOfLines:2];
	[self.contentView addSubview:client_projectLabel];
	
	
	if (titleDetailsLable==nil) {
		//titleDetailsLable = [[UILabel alloc] initWithFrame:CGRectMake(13, 27, 180, 30)];
		UILabel *temptitleDetailsLable = [[UILabel alloc] initWithFrame:CGRectMake(13, 59, 160, 16)];
        self.titleDetailsLable=temptitleDetailsLable;
       
	}
	
	[titleDetailsLable setBackgroundColor:[UIColor clearColor]];
	[titleDetailsLable setTextColor:RepliconStandardBlackColor];
	[titleDetailsLable setFont:[UIFont fontWithName:RepliconFontFamily size:RepliconFontSize_12]];
	[titleDetailsLable setTextAlignment:NSTextAlignmentLeft];
	[titleDetailsLable setNumberOfLines:2];
	[self.contentView addSubview:titleDetailsLable];
	
	
	if (cosetLable==nil) {
		UILabel *tempcosetLable = [[UILabel alloc] initWithFrame:CGRectMake(130, 3, 180, 40)]; //20
		self.cosetLable=tempcosetLable;
        
	}
	[cosetLable setBackgroundColor:[UIColor clearColor]];
	[cosetLable setTextColor:RepliconStandardBlackColor];
	[cosetLable setFont:[UIFont fontWithName:RepliconFontFamilyBold size:RepliconFontSize_14]];
	[cosetLable setTextAlignment:NSTextAlignmentRight];
	[cosetLable setNumberOfLines:1];
	[self.contentView addSubview:cosetLable];
	
	
}

-(void)addReceiptIndicatorImage
{
	UIImage *imageRec=[G2Util thumbnailImage:@"G2camera_icon_s1_s1.png"];
	if (recieptImageView == nil) {
	UIImageView *temprecieptImageView=[[UIImageView alloc] initWithFrame:CGRectMake(290, 54, imageRec.size.width, imageRec.size.height)];
        self.recieptImageView=temprecieptImageView;
        
	}
	[self.contentView addSubview:recieptImageView];
	
}



@end