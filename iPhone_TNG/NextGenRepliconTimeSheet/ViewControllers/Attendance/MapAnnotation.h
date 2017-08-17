//
//  MapAnnotation.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 12/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject <MKAnnotation>

@property (copy,nonatomic) NSString *title;
@property (assign,nonatomic) CLLocationCoordinate2D coordinate;
@property (assign, nonatomic) MKPinAnnotationColor color;


@end
