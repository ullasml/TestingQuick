//
//  AddCommentsViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 19/02/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCPlaceholderTextView.h"

@interface AddCommentsViewController : UIViewController<UITextViewDelegate>
{
    GCPlaceholderTextView *descTextView;
    id __weak delegate;
    id __weak tableDelegate;
    
}
@property(nonatomic,strong)	GCPlaceholderTextView *descTextView;
@property(nonatomic,weak)id delegate;
@property(nonatomic,weak)id tableDelegate;
@end
