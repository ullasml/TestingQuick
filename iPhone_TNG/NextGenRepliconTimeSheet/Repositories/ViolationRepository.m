#import "ViolationRepository.h"
#import "DateProvider.h"
#import "ViolationRequestProvider.h"
#import "ViolationsDeserializer.h"
#import "RequestPromiseClient.h"
#import <KSDeferred/KSPromise.h>
#import "ViolationsForTimesheetPeriodDeserializer.h"
#import "AllViolationSections.h"
#import "ViolationSection.h"
#import "ViolationsForPunchDeserializer.h"


@interface ViolationRepository ()

@property (nonatomic) DateProvider *dateProvider;
@property (nonatomic) ViolationRequestProvider *violationRequestProvider;
@property (nonatomic) ViolationsDeserializer *violationsDeserializer;
@property (nonatomic) ViolationsForPunchDeserializer *violationsForPunchDeserializer;
@property (nonatomic) id<RequestPromiseClient> requestPromiseClient;
@property (nonatomic) ViolationsForTimesheetPeriodDeserializer *violationsForTimesheetPeriodDeserializer;

@end


@implementation ViolationRepository

- (instancetype)initWithViolationsForTimesheetPeriodDeserializer:(ViolationsForTimesheetPeriodDeserializer *)violationsForTimesheetPeriodDeserializer
                                  violationsForPunchDeserializer:(ViolationsForPunchDeserializer *)violationsForPunchDeserializer
                                        violationRequestProvider:(ViolationRequestProvider *)violationRequestProvider
                                          violationsDeserializer:(ViolationsDeserializer *)violationsDeserializer
                                            requestPromiseClient:(id<RequestPromiseClient>)requestPromiseClient
                                                    dateProvider:(DateProvider *)dateProvider {
    self = [super init];
    if (self) {
        self.dateProvider = dateProvider;
        self.violationRequestProvider = violationRequestProvider;
        self.violationsDeserializer = violationsDeserializer;
        self.requestPromiseClient = requestPromiseClient;
        self.violationsForPunchDeserializer = violationsForPunchDeserializer;
        self.violationsForTimesheetPeriodDeserializer = violationsForTimesheetPeriodDeserializer;
    }

    return self;
}

- (KSPromise *)fetchAllViolationSectionsForToday
{
    NSDate *date = [self.dateProvider date];
    NSURLRequest *request = [self.violationRequestProvider provideRequestWithDate:date];
    KSPromise *promise = [self.requestPromiseClient promiseWithRequest:request];

   return [promise then:^id(NSArray *jsonArray) {

       NSArray *violations = [self.violationsDeserializer deserialize:jsonArray];
       ViolationSection *section = [[ViolationSection alloc] initWithTitleObject:date
                                                                      violations:violations
                                                                            type:ViolationSectionTypeDate];
       AllViolationSections *allViolationSections = [[AllViolationSections alloc] initWithTotalViolationsCount:violations.count sections:@[section]];

        return allViolationSections;
    } error:nil];
}

-(KSPromise *)fetchValidationsForPunchURI:(NSString *)punchURI
{
    NSURLRequest *request = [self.violationRequestProvider provideRequestWithPunchURI:punchURI];
    KSPromise *promise = [self.requestPromiseClient promiseWithRequest:request];

    return [promise then:^id(NSDictionary *jsonDictionary) {

        return [self.violationsForPunchDeserializer deserialize:jsonDictionary];
    } error:nil];
}


@end
