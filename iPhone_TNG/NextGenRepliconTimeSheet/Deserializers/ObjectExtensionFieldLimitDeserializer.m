//
//  ObjectExtensionFieldLimitDeserializer.m
//  NextGenRepliconTimeSheet
//


#import "ObjectExtensionFieldLimitDeserializer.h"
#import "Constants.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "InjectorKeys.h"

@interface ObjectExtensionFieldLimitDeserializer ()

@property (nonatomic) NSUserDefaults *standardUserDefaults;

@end

@implementation ObjectExtensionFieldLimitDeserializer

- (instancetype)initWithUserDefaults:(NSUserDefaults*)userDefaults {
    if(self = [super init])
    {
        self.standardUserDefaults = userDefaults;
    }
    
    return self;
}

- (void)deserializeObjectExtensionFieldLimitFromHomeFlowService:(NSDictionary *)oefLimitDictionary {
    
    if(oefLimitDictionary && [oefLimitDictionary count] > 0) {
        
        [self.standardUserDefaults setObject:[oefLimitDictionary objectForKey:@"numericObjectExtensionFieldMaxPrecision"] forKey:OEFMaxPrecisionKey];
        [self.standardUserDefaults setObject:[oefLimitDictionary objectForKey:@"numericObjectExtensionFieldMaxScale"] forKey:OEFMaxScaleKey];
        [self.standardUserDefaults setObject:[oefLimitDictionary objectForKey:@"textObjectExtensionFieldMaxLength"] forKey:OEFMaxTextCharLimitKey];
    }
}

@end
