//
//  SCHStatusViewController.m
//  ScavengerHunt
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Andre Muis. All rights reserved.
//

#import "SCHStatusViewController.h"

#import "CBCentralManager+repStateAsString.h"
#import "CLLocationManager+repAuthorizationStatusAsString.h"
#import "REPConstants.h"
#import "REPWebServices.h"
#import "SCHStyles.h"

@interface SCHStatusViewController () <CBCentralManagerDelegate>

@property (readwrite, weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (readwrite, weak, nonatomic) IBOutlet UILabel *centralManagerStateLabel;

@property (readwrite, weak, nonatomic) IBOutlet UILabel *locationServicesEnabledLabel;
@property (readwrite, weak, nonatomic) IBOutlet UILabel *locationServicesStatusLabel;

@property (readwrite, weak, nonatomic) IBOutlet UILabel *networkReachableLabel;

@property (readwrite, weak, nonatomic) IBOutlet UILabel *beaconJSONURLLabel;
@property (readwrite, weak, nonatomic) IBOutlet UITextView *beaconsJSONTextView;

@property (readonly, strong, nonatomic) CBCentralManager *centralManager;
@property (readonly, strong, nonatomic) CLLocationManager *locationManager;

@property (readonly, strong, nonatomic) REPWebServices *webServices;

@property (readonly, strong, nonatomic) SCHStyles *styles;

@end

@implementation SCHStatusViewController

- (id)initWithCoder: (NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    if (self)
    {
        _centralManager = [[CBCentralManager alloc] initWithDelegate: self queue: nil options: nil];
        _locationManager = [[CLLocationManager alloc] init];
        
        _webServices = [REPWebServices webServices];

        _styles = [SCHStyles styles];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }

    return self;
}

- (UIRectEdge)edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.versionLabel.backgroundColor = [UIColor clearColor];
    
    self.centralManagerStateLabel.backgroundColor = [UIColor clearColor];
    
    self.locationServicesEnabledLabel.backgroundColor = [UIColor clearColor];
    self.locationServicesStatusLabel.backgroundColor = [UIColor clearColor];
    
    self.networkReachableLabel.backgroundColor = [UIColor clearColor];
    
    self.beaconJSONURLLabel.backgroundColor = [UIColor clearColor];
    
    self.beaconsJSONTextView.backgroundColor = self.styles.backgroundColor;
    
    [self updateUI: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateUI:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock: ^(AFNetworkReachabilityStatus status)
    {
        [self updateUI: nil];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    self.beaconsJSONTextView.text = @"";
    [self updateUI: nil];
}

- (void)centralManagerDidUpdateState: (CBCentralManager *)central
{
    [self updateUI: nil];
}

- (void)updateUI: (NSNotification *)notification
{
    self.versionLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey: @"CFBundleVersion"];
    
    
    self.centralManagerStateLabel.text = [self.centralManager repStateAsString];

    if (self.centralManager.state == CBCentralManagerStatePoweredOn)
    {
        self.centralManagerStateLabel.textColor = [UIColor blueColor];
    }
    else
    {
        self.centralManagerStateLabel.textColor = [UIColor redColor];
    }
    
    
    self.locationServicesEnabledLabel.text = [CLLocationManager locationServicesEnabled] ? @"yes" : @"no";
    
    if ([CLLocationManager locationServicesEnabled] == YES)
    {
        self.locationServicesEnabledLabel.textColor = [UIColor blueColor];
    }
    else
    {
        self.locationServicesEnabledLabel.textColor = [UIColor redColor];
    }

    
    self.locationServicesStatusLabel.text = [CLLocationManager repAuthorizationStatusAsString];
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)
    {
        self.locationServicesStatusLabel.textColor = [UIColor blueColor];
    }
    else
    {
        self.locationServicesStatusLabel.textColor = [UIColor redColor];
    }

    
    self.networkReachableLabel.text = [AFNetworkReachabilityManager sharedManager].reachable ? @"yes" : @"no";

    if ([AFNetworkReachabilityManager sharedManager].reachable == YES)
    {
        self.networkReachableLabel.textColor = [UIColor blueColor];
    }
    else
    {
        self.networkReachableLabel.textColor = [UIColor redColor];
    }
    
    
    NSURL *beaconsJSONURL = [NSURL URLWithString: kREPServerBaseURLString];
    beaconsJSONURL = [beaconsJSONURL URLByAppendingPathComponent: kREPBeaconsJSONFileName];
    
    self.beaconJSONURLLabel.text = [beaconsJSONURL absoluteString];
    
    
    [self.webServices clearResponseCache];
    
    self.beaconsJSONTextView.text = @"";
    [self.webServices getBeaconsJSONWithSuccess: ^(id beaconsJSON)
    {
        self.beaconsJSONTextView.text = [beaconsJSON description];
    }
                                       failure: ^(NSError *error)
    {
        self.beaconsJSONTextView.text = [NSString stringWithFormat: @"%@", error];
    }];
}

@end



















