

#import "MostRecentPunchInDetector.h"
#import "Punch.h"
#import "TimeLinePunchesStorage.h"
#import "Constants.h"
#import "Punch.h"


@interface MostRecentPunchInDetector ()

@property (nonatomic) TimeLinePunchesStorage *timeLinePunchesStorage;

@end
@implementation MostRecentPunchInDetector

- (instancetype)initWithTimeLinePunchesStorage:(TimeLinePunchesStorage *)timeLinePunchesStorage
{
    self = [super init];
    if (self) {
        self.timeLinePunchesStorage = timeLinePunchesStorage;
    }
    return self;
}

-(id <Punch>)mostRecentPunchIn
{
    NSArray *dataArray = [self.timeLinePunchesStorage recentPunches];
    
    if (dataArray.count>0) {
        
        NSPredicate *punchInPredicate = [NSPredicate predicateWithFormat:@"(%K == %lu)", @"actionType", PunchActionTypePunchIn];

         NSPredicate *transferPredicate = [NSPredicate predicateWithFormat:@"(%K == %lu)", @"actionType", PunchActionTypeTransfer];

        NSPredicate *placesPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[punchInPredicate, transferPredicate]];
        
        NSArray *filteredarrayWithClockIn = [dataArray filteredArrayUsingPredicate:placesPredicate];
        if (filteredarrayWithClockIn.count>0) {
            
            NSMutableArray *dataMutableArray = [NSMutableArray arrayWithArray:filteredarrayWithClockIn];
            
            NSArray *sortedPunchInArray = [self sortedArrayByDate:dataMutableArray];
            
            for (NSInteger i = sortedPunchInArray.count; i>0; i--)
                
            {
                id <Punch> punch = sortedPunchInArray[i-1];
                
                if ([punch actionType] == PunchActionTypePunchIn||
                    [punch actionType] == PunchActionTypeTransfer)
                {
                    return punch;
                }
            }
        }
    }
    return nil;
}

-(NSArray*)sortedArrayByDate :(NSMutableArray*)dataArray
{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    [dataArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    return dataArray;
}

    
@end
