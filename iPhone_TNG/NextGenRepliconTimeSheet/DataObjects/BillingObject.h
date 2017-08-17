//
//  BillingObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 12/02/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BillingObject : NSObject
{
    NSString *billingName;
    NSString *billingUri;
}
@property (nonatomic,strong)NSString *billingName;
@property (nonatomic,strong)NSString *billingUri;
@end
