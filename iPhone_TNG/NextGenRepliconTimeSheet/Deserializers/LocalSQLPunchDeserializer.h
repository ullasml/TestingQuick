#import <Foundation/Foundation.h>


@class LocalPunch;
@protocol Punch;
@class PunchOEFStorage;
@class PunchActionTypeDeserializer;
@class ViolationsStorage;


@interface LocalSQLPunchDeserializer : NSObject

@property (nonatomic, readonly) PunchActionTypeDeserializer *punchActionTypeDeserializer;
@property (nonatomic, readonly) ViolationsStorage *violationsStorage;
@property (nonatomic, readonly) NSDateFormatter *dateFormatter;
@property (nonatomic, readonly) NSCalendar *calendar;


- (instancetype)initWithPunchActionTypeDeserializer:(PunchActionTypeDeserializer*)punchActionTypeDeserializer
                                  violationsStorage:(ViolationsStorage *)violationsStorage
                                      DateFormatter:(NSDateFormatter *)dateFormatter
                                           calendar:(NSCalendar *)calendar;


- (id <Punch>)deserializeSingleSQLPunch:(NSDictionary *)sqlPunchDictionary punchOEFStorage:(PunchOEFStorage *)punchOEFStorage;

- (LocalPunch *)deserializeSingleLocalSQLPunch:(NSDictionary *)localSQLPunchDictionary punchOEFStorage:(PunchOEFStorage *)punchOEFStorage;

- (NSArray *)deserializeLocalSQLPunches:(NSArray *)localSQLPunchDictionaries punchOEFStorage:(PunchOEFStorage *)punchOEFStorage;

@end
