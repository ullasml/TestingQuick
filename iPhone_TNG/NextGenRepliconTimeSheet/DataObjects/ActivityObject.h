//
//  ActivityObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 13/02/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityObject : NSObject
{
    NSString *activityName;
    NSString *activityUri;
    NSString *activityCode;
}
@property (nonatomic,strong)NSString *activityName;
@property (nonatomic,strong)NSString *activityUri;
@property (nonatomic,strong)NSString *activityCode;
@end
