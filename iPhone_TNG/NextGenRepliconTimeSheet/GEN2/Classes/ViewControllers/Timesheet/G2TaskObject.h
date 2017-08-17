//
//  TaskObject.h
//  Replicon
//
//  Created by Swapna P on 8/16/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface G2TaskObject : NSObject {
	NSString *taskIdentity;
	NSString *taskName;
	NSString *entryId;
	NSString *parentTaskId;

}
@property(nonatomic,strong) NSString *taskIdentity;
@property(nonatomic,strong) NSString *taskName;
@property(nonatomic,strong) NSString *entryId;
@property(nonatomic,strong) NSString *parentTaskId;

@end
