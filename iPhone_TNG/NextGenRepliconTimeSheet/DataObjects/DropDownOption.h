//
//  DropDownOption.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 15/05/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DropDownOption : NSObject
{
    NSString *dropDownOptionName;
    NSString *dropDownOptionUri;
}
@property (nonatomic,strong)NSString *dropDownOptionName;
@property (nonatomic,strong)NSString *dropDownOptionUri;
@end
