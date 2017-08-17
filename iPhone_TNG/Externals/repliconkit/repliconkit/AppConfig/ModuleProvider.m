
#import "ModuleProvider.h"
#import "RepliconKitDependencyModule.h"

@implementation ModuleProvider

+ (id<BSInjector, BSBinder>)injector {
    RepliconKitDependencyModule *dependencyModule = [[RepliconKitDependencyModule alloc] init];
    NSArray *modules = @[dependencyModule];
    return (id<BSInjector, BSBinder>)[Blindside injectorWithModules:modules];
}

@end
