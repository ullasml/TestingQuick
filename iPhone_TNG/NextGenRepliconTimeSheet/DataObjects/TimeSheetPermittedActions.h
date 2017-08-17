
#import <Foundation/Foundation.h>

@interface TimeSheetPermittedActions : NSObject<NSCopying>

@property (nonatomic, readonly) BOOL canAutoSubmitOnDueDate;
@property (nonatomic, readonly) BOOL canReOpenSubmittedTimeSheet;
@property (nonatomic, readonly) BOOL canReSubmitTimeSheet;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithCanSubmitOnDueDate:(BOOL)canSubmitOnDueDate
                                 canReopen:(BOOL)canReopenTimeSheet
                      canReSubmitTimeSheet:(BOOL)canReSubmitTimeSheet NS_DESIGNATED_INITIALIZER;

@end
