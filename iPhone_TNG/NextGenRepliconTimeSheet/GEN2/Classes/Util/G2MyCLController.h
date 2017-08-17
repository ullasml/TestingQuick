//
//  MyCLController.h
//  Replicon
//
//  Created by Dipta Rakshit on 12/26/11.
//  Copyright (c) 2011 Replicon. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@protocol MyCLControllerDelegate <NSObject>
@required
- (void)locationUpdate:(CLLocation *)location; 
- (void)locationError:(NSError *)error;
@end

@interface G2MyCLController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locationManager;
	id __weak delegate;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, weak) id <MyCLControllerDelegate> delegate;

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation;

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error;

@end