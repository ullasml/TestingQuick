//
//  ProjectObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 07/02/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectObject : NSObject

{
    NSString *projectName;
    NSString *projectUri;
    NSString *projectCode;
    NSString *clientName;
    NSString *clientUri;
    BOOL isTimeAllocationAllowed;
    BOOL hasTasksAvailableForTimeAllocation;
    
}
@property (nonatomic,strong)NSString *projectName;
@property (nonatomic,strong)NSString *projectUri;
@property (nonatomic,strong)NSString *projectCode;
@property (nonatomic,strong)NSString *clientName;
@property (nonatomic,strong)NSString *clientUri;
@property (nonatomic,assign)BOOL isTimeAllocationAllowed;
@property (nonatomic,assign)BOOL hasTasksAvailableForTimeAllocation;
@end
