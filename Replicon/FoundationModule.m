

#import "FoundationModule.h"
#import "Replicon-Swift.h"

@implementation FoundationModule

- (void)configure:(id<BSBinder>)binder
{
    [binder bind:@"URLSessionClient" toBlock:^id(NSArray *args, id<BSInjector> injector) {
        return [[URLSessionClient alloc]init];
    }];
    
    [binder bind:@"Presenter" toBlock:^id(NSArray *args, id<BSInjector> injector) {
        return [[Presenter alloc]init];
    }];
    
    [binder bind:@"ObjectiveController" toBlock:^id(NSArray *args, id<BSInjector> injector) {
        return [[ObjectiveController alloc]init];
    }];

    [binder bind:@"RootController" toBlock:^id(NSArray *args, id<BSInjector> injector) {
        RootController *rootController = [[RootController alloc] initWithUrlSessionClient:[injector getInstance:@"URLSessionClient"]
                                                                                presenter:[injector getInstance:@"Presenter"]];
        return rootController;
    }];

}
@end
