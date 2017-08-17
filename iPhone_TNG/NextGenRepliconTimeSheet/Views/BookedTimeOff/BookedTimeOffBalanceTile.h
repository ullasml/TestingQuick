//
//  BookedTimeOffBalanceTile.h
//  Replicon
//
//  Created by Dipta Rakshit on 6/26/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BookedTimeOffBalanceTileDelegate;
@interface BookedTimeOffBalanceTile : UIView
{
    id <BookedTimeOffBalanceTileDelegate> __weak delegate;
    UILabel *balanceLbl;
    UILabel *typeLbl;
    UILabel *statusLbl;
    UIImageView *backgroundImageView;
}
@property(nonatomic,weak) id <BookedTimeOffBalanceTileDelegate> delegate;
@property(nonatomic,strong) UILabel *balanceLbl;
@property(nonatomic,strong) UILabel *typeLbl,*statusLbl;
@property(nonatomic,strong) UIImageView *backgroundImageView;

-(void)createView:(CGRect)frame;

@end


@protocol BookedTimeOffBalanceTileDelegate <NSObject>

@optional
- (void)gotSingleTapForBookedTimeOffTileWithTag:(NSInteger)tag;

@end