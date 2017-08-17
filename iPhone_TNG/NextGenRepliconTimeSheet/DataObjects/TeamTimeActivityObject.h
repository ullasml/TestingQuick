//
//  TeamTimeActivityObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 26/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamTimeActivityObject : NSObject

@property(nonatomic,strong)NSString *activityName;
@property(nonatomic,strong)NSString *activityUri;
@property(nonatomic,strong)NSString *CellIdentifier;
@property(nonatomic,strong)NSString *totalHours;
@property(nonatomic,strong)NSString *durationInHrsMins;
@end
