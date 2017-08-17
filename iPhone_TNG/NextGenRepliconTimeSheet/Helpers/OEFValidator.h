//
//  OEFValidator.h
//  NextGenRepliconTimeSheet
//


#import <Foundation/Foundation.h>
@class OEFType;

@interface OEFValidator : NSObject

@property (nonatomic, readonly) NSUserDefaults *userDefaults;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults;
- (NSError *)validateOEF:(OEFType *)oefType;

@end
