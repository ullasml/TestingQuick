

#import <Foundation/Foundation.h>

@class KSPromise;
@protocol OEFDropdownRepositoryProtocol

- (KSPromise *)fetchAllOEFDropDownOptions;

- (KSPromise *)fetchFreshOEFDropDownOptions;

- (KSPromise *)fetchMoreOEFDropDownOptionsMatchingText:(NSString *)text;

- (KSPromise *)fetchOEFDropDownOptionsMatchingText:(NSString *)text;

- (KSPromise *)fetchCachedOEFDropDownOptionsMatchingText:(NSString *)text;

@end

