//
//  LoginDelegate.h
//  Replicon
//
//  Created by Swapna P on 4/17/11.
//  Copyright 2011 EnLume. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2RepliconServiceManager.h"

@interface G2LoginDelegate : NSObject {
	id __weak parentController;
}
-(void)sendrequestToCheckExistenceOfUserByLoginName;
@property (nonatomic , weak) id parentController;
@end
