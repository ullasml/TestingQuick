//
//  AppConfigModuleHelper.h
//  repliconkit
//
//  Created by Ravikumar Duvvuri on 08/03/17.
//  Copyright © 2017 replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BSBinder;
@protocol BSInjector;

@interface ModuleProvider : NSObject
+ (id<BSInjector, BSBinder>)injector;
@end
