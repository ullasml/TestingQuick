//
//  TeamTimeUserObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 26/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamTimeUserObject : NSObject


@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *userUri;
@property(nonatomic,strong)NSString *CellIdentifier;
@property(nonatomic,strong)NSString *totalHours;
@property(nonatomic,strong)NSString *durationInHrsMins;
@property(nonatomic,assign)BOOL     isUserHasNoData;
@property(nonatomic,strong)NSString *breakHours;
@property(nonatomic,strong)NSString *regularHours;
@end
