#import "TeamStatusSummary.h"


@interface TeamStatusSummary()

@property(nonatomic) NSArray *usersInArray;
@property(nonatomic) NSArray *usersOnBreakArray;
@property(nonatomic) NSArray *usersNotInArray;
@end
@implementation TeamStatusSummary



-(instancetype)initWithUsersInArray:(NSArray *)usersInArray
                       onBreakArray:(NSArray *)usersOnBreakArray
                         notInArray:(NSArray *)usersNotInArray
{
    self = [super init];
    if (self) {
        self.usersInArray = usersInArray;
        self.usersNotInArray = usersNotInArray;
        self.usersOnBreakArray = usersOnBreakArray;
    }
    return self;
}
@end
