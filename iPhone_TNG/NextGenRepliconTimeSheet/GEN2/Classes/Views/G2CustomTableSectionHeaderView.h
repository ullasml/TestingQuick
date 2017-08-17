//
//  CustomTableSectionHeaderView.h
//  Replicon
//
//  Created by vijaysai on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "G2Constants.h"

@interface G2CustomTableSectionHeaderView : UIView {

	UIImageView *headerImageView;
	UIImage	*headerImage;
	UILabel *headerLabel;
}

@property(nonatomic,strong)UIImage	*headerImage;
@property(nonatomic,strong)UILabel *headerLabel;

-(void)setViewProperties:(NSString *)imageName :(CGRect)labelFrame :(NSString *)labelText;

@end
