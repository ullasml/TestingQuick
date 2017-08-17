
#import <Foundation/Foundation.h>

@interface TimeSheetApprovalStatus : NSObject<NSCopying>

@property (nonatomic, copy, readonly) NSString *approvalStatusUri;
@property (nonatomic, copy, readonly) NSString *approvalStatus;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithApprovalStatusUri:(NSString *)uri
                           approvalStatus:(NSString *)approvalStatus NS_DESIGNATED_INITIALIZER;

@end
