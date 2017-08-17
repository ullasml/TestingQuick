#import <Foundation/Foundation.h>


@interface AllViolationSections : NSObject

@property (nonatomic, readonly) NSUInteger totalViolationsCount;
@property (nonatomic, readonly) NSArray *sections;

- (instancetype)initWithTotalViolationsCount:(NSUInteger)totalViolationsCount sections:(NSArray *)sections;

@end
