#import "InjectorProvider.h"
#import "FoundationModule.h"


@implementation InjectorProvider

+ (id<BSInjector, BSBinder>)injector
{
    FoundationModule *foundationModule= [[FoundationModule alloc]init];
    NSArray *modules = @[foundationModule];
    return (id<BSInjector, BSBinder>)[Blindside injectorWithModules:modules];
}

@end
