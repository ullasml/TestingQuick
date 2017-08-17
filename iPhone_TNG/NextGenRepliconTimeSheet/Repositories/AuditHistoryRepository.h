
#import <Foundation/Foundation.h>

@class KSPromise;
@class RequestDictionaryBuilder;
@protocol RequestPromiseClient;
@class AuditHistoryDeserializer;
@class AuditHistoryStorage;

@interface AuditHistoryRepository : NSObject

@property (nonatomic, readonly) RequestDictionaryBuilder *requestDictionaryBuilder;
@property (nonatomic, readonly) AuditHistoryDeserializer *auditHistoryDeserializer;
@property (nonatomic, readonly) AuditHistoryStorage *auditHistoryStorage;
@property (nonatomic, readonly) id<RequestPromiseClient> client;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;


- (instancetype)initWithAuditHistoryDeserializer:(AuditHistoryDeserializer *)auditHistoryDeserializer
                        requestDictionaryBuilder:(RequestDictionaryBuilder *)requestDictionaryBuilder
                             auditHistoryStorage:(AuditHistoryStorage *)auditHistoryStorage
                                          client:(id <RequestPromiseClient>)client;

- (KSPromise *)fetchPunchLogs:(NSArray*)uriArray;

@end
