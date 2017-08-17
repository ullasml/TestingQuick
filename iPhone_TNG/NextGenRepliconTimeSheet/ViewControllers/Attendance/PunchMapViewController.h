//
//  PunchMapViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 11/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PunchMapViewController : UIViewController<MKMapViewDelegate>

@property (nonatomic,assign)BOOL isClockIn;

@property (nonatomic,strong)UIImage *clockUserImage,*originalClockUserImage;
@property (nonatomic,weak)id delegate;
@property (nonatomic,strong)UILabel *locationInfoLabel;
@property (nonatomic,strong)MKMapView *mapView;
@property (nonatomic,strong)UIView *punchMapView;
@property (nonatomic,strong) NSMutableDictionary   *projectInfoDict;
@property (nonatomic,strong) NSString *punchTime;
@property (nonatomic,strong) NSString *punchTimeAmPm;
@property (nonatomic,strong) UIActivityIndicatorView *activityView;
@property (nonatomic,strong)NSMutableDictionary *timePunchDataDict;
@property (nonatomic,strong)NSMutableDictionary *locationDict;
@property (nonatomic,assign)id _parentDelegate;


-(void)punchResponseReceivedAction:(NSNotification *)notification;
-(void)geoAddressReceived:(NSMutableDictionary *)addressDict;
-(void)checkForLocation;
-(UIView*)createViewWithLocationAvailable:(NSDictionary*)response;
-(void)addMapView;
-(void)setMapLocation;

//-(UIView*)createViewWithLocationAvailable:(BOOL)isLocationAvailable isResponseReceived:(BOOL)isResponseReceived LocationStr:(NSString *)locationStr;
@end
