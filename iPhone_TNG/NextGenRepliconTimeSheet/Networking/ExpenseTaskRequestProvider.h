
#import <Foundation/Foundation.h>
@class URLStringProvider;


@interface ExpenseTaskRequestProvider : NSObject

@property (nonatomic,readonly) URLStringProvider *urlStringProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
                                        NS_DESIGNATED_INITIALIZER;

- (NSURLRequest *)requestForTasksForExpenseSheetURI:(NSString *)expenseSheetURI
                                     projectUri:(NSString *)projectUri
                                     searchText:(NSString *)text
                                           page:(NSNumber *)page;
@end
