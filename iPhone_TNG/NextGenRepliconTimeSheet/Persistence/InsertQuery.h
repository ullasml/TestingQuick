#import <Foundation/Foundation.h>


@interface InsertQuery : NSObject

@property (nonatomic, copy, readonly) NSString *query;
@property (nonatomic, readonly) NSArray *valueArguments;

- (instancetype)initWithValueArguments:(NSArray *)valueArguments
                                 query:(NSString *)query;

@end
