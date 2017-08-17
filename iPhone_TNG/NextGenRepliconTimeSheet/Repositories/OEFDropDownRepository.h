
#import <Foundation/Foundation.h>
#import "OEFDropDownDeserializer.h"
#import "OEFDropdownRequestProvider.h"
#import "OEFDropdownRepositoryProtocol.h"

@class OEFDropdownStorage;
@protocol RequestPromiseClient;
@protocol UserSession ;


@interface OEFDropDownRepository : NSObject<OEFDropdownRepositoryProtocol>

@property (nonatomic,readonly) id <RequestPromiseClient> client;
@property (nonatomic,readonly) id <UserSession>userSession;
@property (nonatomic,readonly) OEFDropdownRequestProvider *requestProvider;
@property (nonatomic,readonly) OEFDropdownStorage *storage;
@property (nonatomic,readonly) OEFDropdownDeserializer *oefDropdownDeserializer;
@property (nonatomic,readonly) NSString *dropDownOEFUri;
@property (nonatomic,readonly) NSString *userUri;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithOEFDropDownDeserializer:(OEFDropdownDeserializer *)oefDropdownDeserializer
                             requestProvider:(OEFDropdownRequestProvider *)requestProvider
                                 userSession:(id <UserSession>)userSession
                                     storage:(OEFDropdownStorage *)storage
                                      client:(id<RequestPromiseClient>)client NS_DESIGNATED_INITIALIZER;

-(void)setUpWithDropDownOEFUri:(NSString *)dropDownOEFUri userUri:(NSString *)userUri;


@end

