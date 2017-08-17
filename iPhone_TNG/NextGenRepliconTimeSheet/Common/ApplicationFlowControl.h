
#import <Foundation/Foundation.h>

@class AppDelegate;

@interface ApplicationFlowControl : NSObject

@property (nonatomic,readonly) AppDelegate *delegate;
@property (nonatomic,readonly) NSUserDefaults *userDefaults;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults
                            delegate:(AppDelegate *)delegate NS_DESIGNATED_INITIALIZER;

-(void)performFlowControlForError:(NSError *)error;

@end
