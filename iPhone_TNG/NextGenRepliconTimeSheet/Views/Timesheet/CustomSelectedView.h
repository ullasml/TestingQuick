//
//  CustomSelectedView.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 11/01/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol deleteCustomViewProtocol;
@interface CustomSelectedView : UIView
{
    UILabel *fieldName;
    id <deleteCustomViewProtocol> __weak delegate;
    int viewTag;
    UIButton *deleteBtn;
}
@property (nonatomic,weak) id	<deleteCustomViewProtocol> delegate;
@property (nonatomic,strong)UILabel *fieldName;
@property (nonatomic,assign)int viewTag;
@property (nonatomic,strong) UIButton *deleteBtn;
- (id)initWithFrame:(CGRect)frame andTag:(int)tag;

@end


@protocol deleteCustomViewProtocol <NSObject>
- (void)removeCustomView:(id)sender;
@end