#import <Foundation/Foundation.h>


@interface PunchUser : NSObject

@property (nonatomic, readonly) NSString *nameString;
@property (nonatomic, readonly) NSURL *imageURL;
@property (nonatomic, readonly) NSString *addressString;
@property (nonatomic, readonly) NSDateComponents *regularDateComponents;
@property (nonatomic, readonly) NSDateComponents *overtimeDateComponents;
@property (nonatomic, readonly) NSArray *bookedTimeOffArray;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithNameString:(NSString *)nameString
                          imageURL:(NSURL *)imageURL
                     addressString:(NSString *)addressString
             regularDateComponents:(NSDateComponents *)regularDateComponents
            overtimeDateComponents:(NSDateComponents *)overtimeDateComponents
                     bookedTimeOff:(NSArray *)bookedTimeOffArray;

- (BOOL) isEqual:(PunchUser *)otherPunchUser;

@end
