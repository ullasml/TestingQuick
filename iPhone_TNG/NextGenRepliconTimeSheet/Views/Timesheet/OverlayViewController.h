//
//  OverlayViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 7/6/12.
//  Copyright (c) 2012 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectClientOrProjectViewController;

@interface OverlayViewController : UIViewController

{
    id  __weak parentDelegate;
    
}

@property (nonatomic,weak) id	parentDelegate;

@end
