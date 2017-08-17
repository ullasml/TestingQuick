#import <Foundation/Foundation.h>


@class RemotePunch;
@class GUIDProvider;
@class PunchSerializer;
@protocol Punch;
@protocol UserSession;


@interface PunchRequestBodyProvider : NSObject

@property (nonatomic, readonly) PunchSerializer *punchSerializer;
@property (nonatomic, readonly) id<UserSession> userSession;
@property (nonatomic, readonly) GUIDProvider *guidProvider;
@property (nonatomic, readonly) NSString *guid;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchSerializer:(PunchSerializer *)punchSerializer
                           guidProvider:(GUIDProvider *)guidProvider
                            userSession:(id<UserSession>)userSession NS_DESIGNATED_INITIALIZER;

- (NSDictionary *)requestBodyForPunch:(NSArray *)punchesArray;

- (NSDictionary *)requestBodyForPunchesWithDate:(NSDate *)date userURI:(NSString *)userURI;
- (NSDictionary *)requestBodyForMostRecentPunchForUserUri:(NSString *)userUri;
- (NSDictionary *)requestBodyToDeletePunchWithURI:(NSString *)uri;
- (NSDictionary *)requestBodyToUpdatePunch:(NSArray *)remotePunchesArray;
- (NSDictionary *)requestBodyToRecalculateScriptDataForUserURI:(NSString *)userURI withDateDict:(NSDictionary *)dateDict;
- (NSDictionary *)requestBodyForPunchesWithLastTwoMostRecentPunchWithDate:(NSDate *)date;

@end
