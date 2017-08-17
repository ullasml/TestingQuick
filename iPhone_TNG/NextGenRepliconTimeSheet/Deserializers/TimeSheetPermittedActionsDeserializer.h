

#import <Foundation/Foundation.h>
@class TimeSheetPermittedActions;

@interface TimeSheetPermittedActionsDeserializer : NSObject

- (TimeSheetPermittedActions *)deserialize:(NSDictionary *)jsonDictionary;

- (TimeSheetPermittedActions *)deserializeForWidgetTimesheet:(NSDictionary *)jsonDictionary 
                                         isAutoSubmitEnabled:(BOOL)isAutoSubmitEnabled;


@end
