//
//  SCHBeaconsViewController.m
//  ScavengerHunt
//
//  Created by Andre Muis on 9/14/14.
//  Copyright (c) 2014 Andre Muis. All rights reserved.
//

#import "SCHBeaconsViewController.h"

#import "REPConstants.h"
#import "REPBeaconManager.h"
#import "REPBeaconManagerDelegate.h"
#import "REPRepliconBeacon.h"
#import "REPWebServices.h"
#import "SCHBeaconTableViewCell.h"
#import "SCHStyles.h"
#import "AppDelegate.h"

#import <objc/runtime.h>

@interface SCHBeaconsViewController () <
    UITableViewDataSource,
    UITableViewDelegate,
    REPBeaconManagerDelegate>

@property (readwrite, weak, nonatomic) IBOutlet UITableView *beaconsTableView;
@property (readwrite, weak, nonatomic) IBOutlet UITextView *messagesTextView;

@property (readonly, strong, nonatomic) REPWebServices *webServices;
@property (readonly, strong, nonatomic) REPBeaconManager *beaconManager;

@property (readonly, strong, nonatomic) SCHStyles *styles;

@end

const id MyConstantKey;

@implementation SCHBeaconsViewController

- (id)initWithCoder: (NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    
    if (self)
    {
        _webServices = [REPWebServices webServices];
        _beaconManager = [REPBeaconManager beaconManagerWithDelegate: self];
        
        _styles = [SCHStyles styles];
        
        
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _webServices = [REPWebServices webServices];
        _beaconManager = [REPBeaconManager beaconManagerWithDelegate: self];
        
        _styles = [SCHStyles styles];
        
      //  [self createAndPlaySoundID];
    }
    
    [self.beaconManager stopMonitoringAllRepliconBeacons];
    
    [self.beaconManager clearRepliconBeacons];
    [self.beaconsTableView reloadData];
    
    self.messagesTextView.text = @"";
    [self displayMessage: @"Downloading beacon data . . ."];
    
    [self.webServices clearResponseCache];
    [self.webServices getBeaconsJSONWithSuccess: ^(id beaconsJSON)
     {
         [self displayMessage: @"Searching for beacons . . ."];
         
         NSError *error = nil;
         [self.beaconManager createRepliconBeaconsWithBeaconsJSON: beaconsJSON
                                                            error: &error];
         
         if (error == nil)
         {
             [self.beaconsTableView reloadData];
             
             [self.beaconManager startMonitoringAllRepliconBeacons];
         }
         else
         {
             [self displayMessage: [NSString stringWithFormat: @"%@", error]];
         }
     }
                                        failure: ^(NSError *error)
     {
         [self displayMessage: [NSString stringWithFormat: @"%@", error]];
     }];

    
    return self;
}

- (UIRectEdge)edgesForExtendedLayout
{
    return [super edgesForExtendedLayout] ^ UIRectEdgeBottom;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.beaconsTableView.backgroundColor = self.styles.backgroundColor;
    self.messagesTextView.backgroundColor = self.styles.backgroundColor;
}

- (void)viewDidAppear: (BOOL)animated
{
    [super viewDidAppear: animated];

    [self.beaconManager stopMonitoringAllRepliconBeacons];

    [self.beaconManager clearRepliconBeacons];
    [self.beaconsTableView reloadData];
    
    self.messagesTextView.text = @"";
    [self displayMessage: @"Downloading beacon data . . ."];
    
    [self.webServices clearResponseCache];
    [self.webServices getBeaconsJSONWithSuccess: ^(id beaconsJSON)
    {
        [self displayMessage: @"Searching for beacons . . ."];
        
        NSError *error = nil;
        [self.beaconManager createRepliconBeaconsWithBeaconsJSON: beaconsJSON
                                                           error: &error];
        
        if (error == nil)
        {
            [self.beaconsTableView reloadData];
            
            [self.beaconManager startMonitoringAllRepliconBeacons];
        }
        else
        {
            [self displayMessage: [NSString stringWithFormat: @"%@", error]];
        }
    }
                                        failure: ^(NSError *error)
    {
        [self displayMessage: [NSString stringWithFormat: @"%@", error]];
    }];
}

- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView: (UITableView *)tableView numberOfRowsInSection: (NSInteger)section
{
    return self.beaconManager.repliconBeacons.count;
}

- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    SCHBeaconTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: [SCHBeaconTableViewCell reuseIdentifier]];
    
    if (cell == nil)
    {
        cell = [[SCHBeaconTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                             reuseIdentifier: [SCHBeaconTableViewCell reuseIdentifier]];
    }
    
    REPRepliconBeacon *repliconBeacon = [self.beaconManager.repliconBeacons objectAtIndex: indexPath.row];
    
    [cell updateWithRepliconBeacon: repliconBeacon];
    
    return cell;
}

- (void)            beaconManager: (REPBeaconManager *)manager
  didEnterRegionForRepliconBeacon: (REPRepliconBeacon *)repliconBeacon
{
    [self.beaconsTableView reloadData];
    
    
  
    
    if (repliconBeacon.boundaryCrossings==0)
    {
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground)
        {
            [self.beaconManager displayLocalNotificationWithMessage:repliconBeacon];
        }
        
        else
            
        {
             UIAlertView *alertView = [UIAlertView showAlertViewWithCancelButtonTitle:RPLocalizedString(@"Cancel", @"")
                                           otherButtonTitle:RPLocalizedString(@"Ok", @"")
                                                   delegate:self
                                                    message:repliconBeacon.message
                                                      title:@""
                                                        tag:999];

            
            [self createAndPlaySoundID];
            
            objc_setAssociatedObject(alertView, &MyConstantKey, repliconBeacon, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
 
    
}

- (void)            beaconManager: (REPBeaconManager *)manager
   didExitRegionForRepliconBeacon: (REPRepliconBeacon *)repliconBeacon
{
    [self.beaconsTableView reloadData];

}

- (void)beaconManager: (REPBeaconManager *)beaconManager
    didEncounterError: (NSError *)error
{
    [self displayMessage: [NSString stringWithFormat: @"%@", error]];
}

- (void)displayMessage: (NSString *)message
{
    self.messagesTextView.text = [NSString stringWithFormat: @"%@\n\n%@", message, self.messagesTextView.text];
}


-(void)stopBeacons
{
    [self.beaconManager stopMonitoringAllRepliconBeacons];
}

//- (REPRepliconBeacon *)repliconBeaconWithBeaconRegionFromBeaconManager:(NSUUID *)uuid andMajor:(NSNumber *)major andMinor:(NSNumber *)minor

- (void)repliconBeaconWithBeaconRegionFromBeaconManager:(NSDictionary *)userInfo

{
    
    
    
    NSUUID *uuid=[[NSUUID UUID] initWithUUIDString: [userInfo objectForKey:@"proximityUUID"] ];
    NSNumber *major=[userInfo objectForKey:@"major"];
    NSNumber *minor=[userInfo objectForKey:@"minor"];

  
    
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid major:(CLBeaconMajorValue)[major integerValue] minor:(CLBeaconMinorValue)[minor integerValue] identifier:@""];
   
    
    REPRepliconBeacon *repliconBeacon=[self.beaconManager repliconBeaconWithBeaconRegion:beaconRegion];
    
    NSLog(@"----%@",repliconBeacon);
    
    repliconBeacon.boundaryCrossings = 1;
    
  
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 999)
    {
        REPRepliconBeacon *repBeacon = (REPRepliconBeacon *)objc_getAssociatedObject(alertView, &MyConstantKey);
        
        if (buttonIndex==1)
        {
            AppDelegate *appDelegate=(AppDelegate *) [[UIApplication sharedApplication]delegate];
            [appDelegate getDeepLinkingWorkingForValue:DEEPLINKING_ATTENDENCE];
            
            repBeacon.boundaryCrossings = 1;
        }
        else
        {
            
            
            repBeacon.boundaryCrossings=0;
        }
        
        
    }
    
}

-(void)createAndPlaySoundID
{
    SystemSoundID soundID;
    
    NSURL *soundURL = [[NSBundle mainBundle] URLForResource:@"alert"
                                              withExtension:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)soundURL,&soundID);
    AudioServicesPlayAlertSound(soundID);
}

-(void)dealloc
{
    self.beaconsTableView.delegate = nil;
    self.beaconsTableView.dataSource = nil;
}

@end






















