

#import <Foundation/Foundation.h>
#import "ActivityRepositoryProtocol.h"
#import "ActivityDeserializer.h"
#import "ActivityRequestProvider.h"

@class ActivityStorage;
@protocol RequestPromiseClient;
@protocol UserSession ;


@interface ActivityRepository : NSObject <ActivityRepositoryProtocol>

@property (nonatomic,readonly) id <RequestPromiseClient> client;
@property (nonatomic,readonly) id <UserSession>userSession;
@property (nonatomic,readonly) ActivityRequestProvider *requestProvider;
@property (nonatomic,readonly) ActivityStorage *storage;
@property (nonatomic,readonly) ActivityDeserializer *activityDeserializer;
@property (nonatomic,readonly) NSString *userUri;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithActivityDeserializer:(ActivityDeserializer *)activityDeserializer
                             requestProvider:(ActivityRequestProvider *)requestProvider
                                 userSession:(id <UserSession>)userSession
                                     storage:(ActivityStorage *)storage
                                      client:(id<RequestPromiseClient>)client NS_DESIGNATED_INITIALIZER;

-(void)setUpWithUserUri:(NSString *)userUri;
@end
