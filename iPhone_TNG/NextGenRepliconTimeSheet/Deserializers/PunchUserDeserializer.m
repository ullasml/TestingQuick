#import "PunchUserDeserializer.h"
#import "PunchUser.h"
#import "BookedTimeOffDeserializer.h"
#import "BookedTimeOff.h"

@interface PunchUserDeserializer ()
@property (nonatomic) BookedTimeOffDeserializer *bookedTimeOffDeserializer;

@end

@implementation PunchUserDeserializer

- (instancetype)initWithBookedTimeOffDeserializer:(BookedTimeOffDeserializer *)bookedTimeOffDeserializer
{
    self = [super init];
    if (self) {

        self.bookedTimeOffDeserializer = bookedTimeOffDeserializer;
    }
    return self;
}

- (PunchUser *)deserialize:(NSDictionary *)punchUserDictionary
{
    NSDictionary *userDictionary = punchUserDictionary[@"user"];
    NSString *nameString = userDictionary[@"displayText"];

    NSDictionary *latestTimePunchDetails = punchUserDictionary[@"latestTimePunchDetails"];

    NSString *addressString;
    NSURL *imageURL;

    if([latestTimePunchDetails isKindOfClass:[NSDictionary class]]) {
        NSDictionary *punchGeolocation = latestTimePunchDetails[@"geolocation"];

        if (punchGeolocation != (id)[NSNull null] && punchGeolocation[@"address"] != (id)[NSNull null])
        {
            addressString = punchGeolocation[@"address"];
        }


        NSDictionary  *largeImageDictionary = latestTimePunchDetails [@"auditImage"];
        NSDictionary  *thumbnailImageDictionary = latestTimePunchDetails [@"thumbnailImage"];

        if ([largeImageDictionary isKindOfClass:[NSDictionary class]] && [thumbnailImageDictionary isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *largeImageLinkDictionary = largeImageDictionary [@"imageLink"];
            imageURL = [NSURL URLWithString:largeImageLinkDictionary[@"href"]];
        }
    }

    NSDictionary *totalRegularHours = punchUserDictionary[@"totalRegularHours"];
    NSDateComponents *regularDateComponents = [self parseDateComponentsFromWorkHoursDictionary:totalRegularHours];

    NSDictionary *totalOvertimeHours = punchUserDictionary[@"totalOvertimeHours"];
    NSDateComponents *overtimeDateComponents = [self parseDateComponentsFromWorkHoursDictionary:totalOvertimeHours];

    NSMutableArray *bookedTimeOffArray = [NSMutableArray array];
    NSArray *timeOffDetailsArray = punchUserDictionary[@"timeOffDetails"];

    if(![timeOffDetailsArray isKindOfClass:[NSNull class]])
    {
        for (NSDictionary *timeOffDetailsDictionary in timeOffDetailsArray) {
            BookedTimeOff *bookedTimeOff = [self.bookedTimeOffDeserializer deserialize:timeOffDetailsDictionary];
            [bookedTimeOffArray addObject:bookedTimeOff];
        }
    }

    return [[PunchUser alloc] initWithNameString:nameString
                                        imageURL:imageURL
                                   addressString:addressString
                           regularDateComponents:regularDateComponents
                          overtimeDateComponents:overtimeDateComponents
                                   bookedTimeOff:bookedTimeOffArray];
}

#pragma mark - Private

- (BOOL)timeSegmentIsComplete:(NSDictionary *)timeSegment
{
    return ![timeSegment[@"endPunchUri"] isKindOfClass:[NSNull class]];
}

- (BOOL)imageLinkDictionary:(NSDictionary *)imageLinkDictionary hasSmallerImageThan:(NSDictionary *)otherImageLinkDictionary
{
    float imageHeightInPixels = [imageLinkDictionary [@"heightInPixels"] floatValue];
    float otherImageHeightInPixels = [otherImageLinkDictionary [@"heightInPixels"] floatValue];

    return (imageHeightInPixels < otherImageHeightInPixels);
}

- (NSDateComponents *)parseDateComponentsFromWorkHoursDictionary:(NSDictionary *)workHoursDictionary
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.hour = [workHoursDictionary[@"hours"] integerValue];
    dateComponents.minute = [workHoursDictionary[@"minutes"] integerValue];
    dateComponents.second = [workHoursDictionary[@"seconds"] integerValue];
    return dateComponents;
}



@end
