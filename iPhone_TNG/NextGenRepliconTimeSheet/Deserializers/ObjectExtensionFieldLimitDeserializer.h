//
//  ObjectExtensionFieldLimitDeserializer.h
//  NextGenRepliconTimeSheet
//


#import <Foundation/Foundation.h>

@interface ObjectExtensionFieldLimitDeserializer : NSObject

@property (nonatomic, readonly) NSUserDefaults *standardUserDefaults;

- (instancetype)initWithUserDefaults:(NSUserDefaults*)userDefaults;

- (void)deserializeObjectExtensionFieldLimitFromHomeFlowService:(NSDictionary *)jsonDictionary;

@end
