
#import <Foundation/Foundation.h>
@class URLStringProvider;


@interface ExpenseProjectRequestProvider : NSObject

@property (nonatomic,readonly) URLStringProvider *urlStringProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
                                        NS_DESIGNATED_INITIALIZER;

- (NSURLRequest *)requestForProjectsForExpenseSheetURI:(NSString *)expenseSheetURI
                                             clientUri:(NSString *)clientUri
                                            searchText:(NSString *)text
                                                  page:(NSNumber *)page;


@end
