#import "PunchUser.h"


@interface PunchUser ()

@property (nonatomic) NSString *nameString;
@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSString *addressString;
@property (nonatomic) NSDateComponents *regularDateComponents;
@property (nonatomic) NSDateComponents *overtimeDateComponents;
@property (nonatomic) NSArray *bookedTimeOffArray;

@end

@implementation PunchUser

- (instancetype)initWithNameString:(NSString *)nameString
                          imageURL:(NSURL *)imageURL
                     addressString:(NSString *)addressString
             regularDateComponents:(NSDateComponents *)regularDateComponents
            overtimeDateComponents:(NSDateComponents *)overtimeDateComponents
                     bookedTimeOff:(NSArray *)bookedTimeOffArray
{

    self = [super init];
    if (self) {
        self.nameString = nameString;
        self.imageURL = imageURL;
        self.addressString = addressString;
        self.regularDateComponents = regularDateComponents;
        self.overtimeDateComponents = overtimeDateComponents;
        self.bookedTimeOffArray = bookedTimeOffArray;
    }
    return self;
}

-(BOOL) isEqual:(PunchUser *)otherPunchUser
{
    if(![otherPunchUser isKindOfClass:[self class]]) {
        return NO;
    }

    BOOL nameStringEqual = (!self.nameString && !otherPunchUser.nameString) || [self.nameString isEqualToString:otherPunchUser.nameString];
    BOOL imageURLEqual = (!self.imageURL && !otherPunchUser.imageURL) || [self.imageURL isEqual:otherPunchUser.imageURL];
    BOOL addressStringEqual = (!self.addressString && !otherPunchUser.addressString) || [self.addressString isEqualToString:otherPunchUser.addressString];
    BOOL regularDateComponentsEqual = (!self.regularDateComponents && !otherPunchUser.regularDateComponents) || [self.regularDateComponents isEqual:otherPunchUser.regularDateComponents];
    BOOL overtimeDateComponentsEqual = (!self.overtimeDateComponents && !otherPunchUser.overtimeDateComponents) || [self.overtimeDateComponents isEqual:otherPunchUser.overtimeDateComponents];
    BOOL bookedTimeOffArrayEqual = (!self.bookedTimeOffArray && !otherPunchUser.bookedTimeOffArray) || [self.bookedTimeOffArray isEqualToArray:otherPunchUser.bookedTimeOffArray];

    return ( nameStringEqual && imageURLEqual && addressStringEqual && regularDateComponentsEqual && overtimeDateComponentsEqual && bookedTimeOffArrayEqual);
}

@end

