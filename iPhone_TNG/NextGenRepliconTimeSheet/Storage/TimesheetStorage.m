
#import "TimesheetStorage.h"
#import "SQLiteTableStore.h"

@interface TimesheetStorage ()

@property (nonatomic) SQLiteTableStore *sqliteStore;

@end


@implementation TimesheetStorage

- (instancetype)initWithSQLiteStore:(SQLiteTableStore *)sqliteStore{
    self = [super init];
    if (self)
    {
        self.sqliteStore = sqliteStore;
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

