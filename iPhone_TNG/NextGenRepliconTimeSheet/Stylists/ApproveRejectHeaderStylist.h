#import <Foundation/Foundation.h>


@class ApprovalsPendingTimeOffTableViewHeader;
@protocol Theme;


@interface ApproveRejectHeaderStylist : NSObject

@property (nonatomic, readonly) id<Theme> theme;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;
- (void)styleApproveRejectHeader:(ApprovalsPendingTimeOffTableViewHeader *)headerView;

@end
