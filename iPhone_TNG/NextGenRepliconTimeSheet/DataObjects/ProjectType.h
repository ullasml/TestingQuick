

#import <Foundation/Foundation.h>
@class Period;
@class ClientType;
@class ProjectBillingType;
@class ProjectTimeAndExpenseEntryType;

@interface ProjectType : NSObject <NSCoding, NSCopying>

@property (nonatomic,readonly,copy) NSString *name;
@property (nonatomic,readonly,copy) NSString *uri;
@property (nonatomic,readonly) Period *projectPeriod;
@property (nonatomic,readonly) ClientType *client;
@property (nonatomic,readonly,assign) BOOL hasTasksAvailableForTimeAllocation;
@property (nonatomic,readonly,assign) BOOL isTimeAllocationAllowed;
@property (nonatomic, assign) BOOL isProjectTypeRequired;
@property (nonatomic) ProjectBillingType *projectBillingType;
@property (nonatomic) ProjectTimeAndExpenseEntryType *projectTimeAndExpenseEntryType;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTasksAvailableForTimeAllocation:(BOOL)tasksAvailableForTimeAllocation
                                isTimeAllocationAllowed:(BOOL)isTimeAllocationAllowed
                                          projectPeriod:(Period *)projectPeriod
                                             clientType:(ClientType *)client
                                                   name:(NSString *)name
                                                    uri:(NSString *)uri NS_DESIGNATED_INITIALIZER;
- (BOOL)isProjectBillable;
- (void)setClientTypeAsNoClient;

@end
