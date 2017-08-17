#import <Foundation/Foundation.h>
#import "RemotePunch.h"

@interface RemoteSQLPunchSerializer : NSObject


- (instancetype)initWithCalendar:(NSCalendar *)calendar;

- (NSMutableDictionary *)serializePunchForStorage:(RemotePunch *)localPunch;

@end
