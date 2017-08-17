#import <UIKit/UIKit.h>
#import "Constants.h"
/*
 * It takes care of just reading the App Properties from a pList and showing them.
 * Specifically, this class doesn't set the properties back into the pList
 */
@interface AppProperties : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
+ (AppProperties *) getInstance;
- (id) getAppPropertyFor: (NSString *) propertyName;
- (id) getServiceMappingPropertyFor:(NSString *) propertyName;
- (id) getServiceURLFor:(NSString *) propertyName;
- (id) getTimesheetColumnURIFromPlist;
- (id) getExpenseSheetColumnURIFromPlist;
- (id) getTimeOffColumnURIFromPlist;
- (id) getTeamTimeColumnURIFromPlist;
- (NSString *) getServiceKeyForValue:(int) propertyValue;

@end
