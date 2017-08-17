
#import <Foundation/Foundation.h>
@class URLStringProvider;



@interface ExpenseClientRequestProvider : NSObject

@property (nonatomic,readonly) URLStringProvider *urlStringProvider;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
                              NS_DESIGNATED_INITIALIZER;

- (NSURLRequest *)requestForClientsForExpenseSheetURI:(NSString *)expenseSheetURI
                                           searchText:(NSString *)text
                                                 page:(NSNumber *)page;
@end
