#import <Foundation/Foundation.h>


@class AstroUserDetector;
@class AstroAwareTimesheet;
@class UserPermissionsStorage;
@protocol Timesheet;


@interface SingleTimesheetDeserializer : NSObject

@property (nonatomic, readonly) AstroUserDetector *astroUserDetector;
@property (nonatomic, readonly) UserPermissionsStorage *userPermissionsStorage;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;


- (instancetype)initWithAstroUserDetector:(AstroUserDetector *)astroUserDetector
                    userPermissionStorage:(UserPermissionsStorage *)userPermissionStorage NS_DESIGNATED_INITIALIZER;

- (AstroAwareTimesheet *)deserialize:(NSDictionary *)timesheetDictionary;

@end
