//
//  TeamTimeBreakObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 27/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamTimeBreakObject : NSObject
@property(nonatomic,strong)NSString *breakName;
@property(nonatomic,strong)NSString *breakUri;
@property(nonatomic,strong)NSString *CellIdentifier;
@property(nonatomic,strong)NSString *totalHours;
@property(nonatomic,strong)NSString *durationInHrsMins;
@end
