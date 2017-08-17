#import <Foundation/Foundation.h>


@class RemotePunch;
@class PunchActionTypeDeserializer;
@class GUIDProvider;
@class OEFDeserializer;
@class ViolationsDeserializer;
@class DateTimeComponentDeserializer;


@interface RemotePunchDeserializer : NSObject

@property (nonatomic, readonly) PunchActionTypeDeserializer *punchActionTypeDeserializer;
@property (nonatomic, readonly) DateTimeComponentDeserializer *dateTimeComponentDeserializer;
@property (nonatomic, readonly) ViolationsDeserializer *violationsDeserializer;
@property (nonatomic, readonly) OEFDeserializer *oefDeserializer;
@property (nonatomic, readonly) GUIDProvider *guidProvider;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithPunchActionTypeDeserializer:(PunchActionTypeDeserializer *)punchActionTypeDeserializer
                      dateTimeComponentDeserializer:(DateTimeComponentDeserializer *)dateTimeComponentDeserializer
                             violationsDeserializer:(ViolationsDeserializer *)violationsDeserializer
                                    oefDeserializer:(OEFDeserializer *)oefDeserializer
                                       guidProvider:(GUIDProvider *)guidProvider
                                           calendar:(NSCalendar *)calendar;

- (RemotePunch *)deserialize:(NSDictionary *)punchDictionary;

@end
