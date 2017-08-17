//
//  RepliconKitDependencyModule.h
//  repliconkit
//
//  Created by Ravikumar Duvvuri on 08/03/17.
//  Copyright © 2017 replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Blindside/Blindside.h>

extern NSString* const InjectorKeyRepliconKitUserDefaults;
extern NSString* const InjectorKeyRepliConkitMainQueue;

@interface RepliconKitDependencyModule : NSObject<BSModule>

@end
