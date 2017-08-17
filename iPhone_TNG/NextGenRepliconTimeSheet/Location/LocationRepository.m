#import "LocationRepository.h"
#import <KSDeferred/KSDeferred.h>


@interface LocationRepository ()

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocation *mostRecentLocation;
@property (nonatomic) NSMutableArray *observers;

@end


@implementation LocationRepository

- (instancetype)initWithLocationManager:(CLLocationManager *)locationManager
{
    self = [super init];
    if (self)
    {
        self.locationManager = locationManager;
        self.locationManager.delegate = self;

        self.observers = [[NSMutableArray alloc] init];

        [self startObservingLocation];
    }
    return self;
}

- (void)startObservingLocation
{
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }

    [self.locationManager startUpdatingLocation];
}

- (KSPromise *)mostRecentLocationPromise
{
    KSDeferred *deferred = [[KSDeferred alloc] init];
    [self.observers addObject:deferred];

    if (self.mostRecentLocation == nil)
    {
        self.mostRecentLocation = self.locationManager.location;
    }

    [self notifyObserversWithMostRecentLocation];

    return deferred.promise;
}

#pragma mark - <CLLocationManagerDelegate>

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.mostRecentLocation = locations.lastObject;
    [self notifyObserversWithMostRecentLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    for (KSDeferred *deferred in self.observers)
    {
        [deferred rejectWithError:error];
    }

    [self.observers removeAllObjects];
}

#pragma mark - Private

- (void)notifyObserversWithMostRecentLocation
{
    if (self.mostRecentLocation == nil)
    {
        return;
    }

    for (KSDeferred *deferred in self.observers)
    {
        [deferred resolveWithValue:self.mostRecentLocation];
    }

    [self.observers removeAllObjects];
}

@end
