#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, AllowAccessAlertHelperAlertButton) {
    AllowAccessAlertHelperPunchAlertButtonCancel = 0,
    AllowAccessAlertHelperPunchAlertButtonSettings
};


@interface AllowAccessAlertHelper : NSObject

@property (nonatomic, weak, readonly) UIApplication *sharedApplication;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithApplication:(UIApplication *)application NS_DESIGNATED_INITIALIZER;

- (void)handleLocationError:(NSError *)locationError cameraError:(NSError *)cameraError;

@end
