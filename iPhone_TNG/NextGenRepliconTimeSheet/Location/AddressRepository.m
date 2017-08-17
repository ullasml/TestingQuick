#import "AddressRepository.h"
#import "JSONClient.h"
#import <KSDeferred/KSPromise.h>


@interface AddressRepository ()

@property (nonatomic) JSONClient *client;

@end


@implementation AddressRepository

- (instancetype)initWithClient:(JSONClient *)client
{
    self = [super init];
    if (self)
    {
        self.client = client;
    }
    return self;
}

- (KSPromise *)addressPromiseWithCoordinates:(CLLocationCoordinate2D)coordinates
{
    NSURLComponents *components = [NSURLComponents componentsWithString:@"https://maps.googleapis.com/maps/api/geocode/json"];

    NSString *latlngValue = [NSString stringWithFormat:@"%@,%@", @(coordinates.latitude), @(coordinates.longitude)];
    components.query = [NSString stringWithFormat:@"latlng=%@", latlngValue];

    NSURL *url = [components URL];

    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];

    KSPromise *jsonPromise = [self.client promiseWithRequest:request];

    return [jsonPromise then:^id(NSDictionary *jsonDictionary) {
        NSArray *resultsArray = jsonDictionary[@"results"];
        NSDictionary *addressDictionary = resultsArray.firstObject;
        return addressDictionary[@"formatted_address"];
    } error:nil];
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
