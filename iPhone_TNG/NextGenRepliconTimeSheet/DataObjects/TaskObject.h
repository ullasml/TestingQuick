//
//  TaskObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 07/02/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaskObject : NSObject
{
    NSString *taskName;
    NSString *taskUri;
    NSString *taskFullPath;
    NSString *taskCode;
    
}

@property (nonatomic,strong)NSString *taskName;
@property (nonatomic,strong)NSString *taskUri;
@property (nonatomic,strong)NSString *taskFullPath;
@property (nonatomic,strong)NSString *taskCode;
@end
