#import <Foundation/Foundation.h>

@interface TeamStatusSummary : NSObject

@property(nonatomic,readonly) NSArray *usersInArray;
@property(nonatomic,readonly) NSArray *usersOnBreakArray;
@property(nonatomic,readonly) NSArray *usersNotInArray;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

-(instancetype)initWithUsersInArray:(NSArray *)usersInArray
                       onBreakArray:(NSArray *)usersOnBreakArray
                         notInArray:(NSArray *)usersNotInArray NS_DESIGNATED_INITIALIZER;

@end
