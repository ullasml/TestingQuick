//
//  RepliconKitDependencyModule.h
//  repliconkit
//
//  Created by Ravikumar Duvvuri on 08/03/17.
//  Copyright © 2017 replicon. All rights reserved.
//


#import "RepliconKitDependencyModule.h"
#import "AppConfigRepository.h"
#import "PersistedSettingsStorage.h"
#import "ReachabilityMonitor.h"
#import "AppConfig.h"
#import "NetworkClient.h"
#import "RPURLSessionDelegate.h"

NSString* const InjectorKeyRepliconKitUserDefaults = @"InjectorKeyStandardUserDefaults";
NSString* const InjectorKeyRepliConkitMainQueue = @"InjectorKeyMainQueue";
NSString* const InjectorKeyRepliConkitDefaultSessionConfiguration = @"InjectorKeyDefaultSessionConfiguration";

@implementation RepliconKitDependencyModule

- (void)configure:(id<BSBinder>)binder {
    
    [binder bind:[AppConfigRepository class] toBlock:^id(NSArray *args, id<BSInjector> injector) {
        return [[AppConfigRepository alloc] initWithPersistedSettingsStorage:[injector getInstance:[PersistedSettingsStorage class]]
                                                         reachabilityMonitor:[injector getInstance:[ReachabilityMonitor class]]
                                                               networkClient:[injector getInstance:[NetworkClient class]]];
    }];
    
    [binder bind:[AppConfig class] toBlock:^id(NSArray *args, id<BSInjector> injector) {
        return [[AppConfig alloc] initWithPersistedSettingsStorage:[injector getInstance:[PersistedSettingsStorage class]]];
    }];
    
    [binder bind:[PersistedSettingsStorage class] toBlock:^id(NSArray *args, id<BSInjector> injector) {
        return [[PersistedSettingsStorage alloc] initWithUserDefaults:[injector getInstance:InjectorKeyRepliconKitUserDefaults]];
    }];
    
    [binder bind:[NetworkClient class] toBlock:^id(NSArray *args, id<BSInjector> injector) {
        return [[NetworkClient alloc] initWithSession:[injector getInstance:InjectorKeyRepliConkitDefaultSessionConfiguration] queue:[injector getInstance:InjectorKeyRepliConkitMainQueue]];
    }];
    
    [binder bind:InjectorKeyRepliConkitDefaultSessionConfiguration toBlock:^id(NSArray *args, id<BSInjector> injector) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        return [NSURLSession sessionWithConfiguration:configuration delegate:[injector getInstance:[RPURLSessionDelegate class]] delegateQueue:nil];
    }];
    
    [binder bind:[RPURLSessionDelegate class] withScope:[BSSingleton scope]];
    [binder bind:InjectorKeyRepliconKitUserDefaults toInstance:[NSUserDefaults standardUserDefaults]];
    [binder bind:InjectorKeyRepliConkitMainQueue toInstance:[NSOperationQueue mainQueue]];
}

@end
