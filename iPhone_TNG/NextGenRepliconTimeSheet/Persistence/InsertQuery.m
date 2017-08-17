#import "InsertQuery.h"


@interface InsertQuery ()

@property (nonatomic, copy) NSString *query;
@property (nonatomic) NSArray *valueArguments;

@end


@implementation InsertQuery

- (instancetype)initWithValueArguments:(NSArray *)valueArguments
                                 query:(NSString *)query

{
    self = [super init];
    if (self) {
        self.valueArguments = valueArguments;
        self.query = query;
    }

    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

