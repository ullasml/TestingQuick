#import "PunchActionTypeDeserializer.h"
#import "Constants.h"


@interface PunchActionTypeDeserializer ()

@property (nonatomic) NSDictionary *actionMap;

@end


@implementation PunchActionTypeDeserializer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.actionMap = @{
            PUNCH_ACTION_URI_OUT: @(PunchActionTypePunchOut),
            PUNCH_ACTION_URI_IN: @(PunchActionTypePunchIn),
            PUNCH_ACTION_URI_TRANSFER: @(PunchActionTypeTransfer),
            PUNCH_ACTION_URI_BREAK: @(PunchActionTypeStartBreak)
        };
    }

    return self;
}

- (PunchActionType)deserialize:(NSString *)actionURI
{
    return [self.actionMap[actionURI] unsignedIntegerValue];
}

- (NSString *)getPunchActionTypeString:(PunchActionType)punchActiontype
{
    NSString *punchActionTypeStr = nil;
    switch (punchActiontype) {
        case PunchActionTypePunchIn:
            punchActionTypeStr = @"PunchIn";
            break;
        case PunchActionTypePunchOut:
            punchActionTypeStr = @"PunchOut";
            break;
        case PunchActionTypeStartBreak:
            punchActionTypeStr = @"StartBreak";
            break;
        case PunchActionTypeTransfer:
            punchActionTypeStr = @"Transfer";
            break;

        default:
            break;
    }
    return punchActionTypeStr;
}

@end
