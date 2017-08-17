#import "AuditHistoryDeserializer.h"
#import "AuditHistory.h"

@implementation AuditHistoryDeserializer


-(NSArray *)deserialize:(NSArray *)jsonDictionary
{
    NSMutableArray *punchLogs = [NSMutableArray array];
    if (jsonDictionary.count>0) {
        for (NSDictionary *punchLog in jsonDictionary) {
            NSString *uri = punchLog[@"uri"];
            NSMutableArray *records = punchLog[@"records"];
            NSMutableArray *displayTextArray = [NSMutableArray array];
            if (records.count) {
                for (NSDictionary *logDictionary in records) {
                    [displayTextArray addObject:logDictionary[@"displayText"]];
                }
            }
            AuditHistory *auditHistory =  [[AuditHistory alloc] initWithHistory:displayTextArray uri:uri];
            [punchLogs addObject:auditHistory];
        }
    }
    return punchLogs;
}

@end
