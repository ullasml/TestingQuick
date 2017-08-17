#import <Foundation/Foundation.h>

@class OvertimeSummaryController;
@class KSPromise;
@class OvertimeSummaryTablePresenter;


@interface OvertimeSummaryControllerProvider : NSObject

@property (nonatomic, readonly) OvertimeSummaryTablePresenter *overtimeSummaryTablePresenter;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithOvertimeSummaryTablePresenter:(OvertimeSummaryTablePresenter *)overtimeSummaryTablePresenter NS_DESIGNATED_INITIALIZER;

-(OvertimeSummaryController *)provideInstanceWithOvertimeSummaryPromise:(KSPromise *)overtimeSummaryPromise;

@end
