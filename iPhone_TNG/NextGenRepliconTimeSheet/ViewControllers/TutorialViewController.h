//
//  TutorialViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 8/3/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewController : UIViewController
{
    UIImageView *tutorialImageView;
}

@property(nonatomic,retain) UIImageView *tutorialImageView;
- (id) initWithImage: (UIImage *)image;
@end
