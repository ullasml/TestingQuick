#import <Foundation/Foundation.h>


@protocol BSBinder;
@protocol BSInjector;


@interface InjectorProvider : NSObject

+ (id<BSInjector, BSBinder>)injector;

@end
