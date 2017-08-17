//
//  PunchEntry_TestCase.m
//  NextGenRepliconTimeSheet
//
//  Created by Juhi Gautam on 09/12/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PunchEntryViewController.h"

@interface PunchEntry_TestCase : XCTestCase
@property (nonatomic,strong) PunchEntryViewController *punchEntryVC;
@end

@implementation PunchEntry_TestCase
@synthesize punchEntryVC;

- (void)setUp {
    [super setUp];
    punchEntryVC=[[PunchEntryViewController alloc]init];
    punchEntryVC.screenMode=ADD_PUNCH_ENTRY;
    [punchEntryVC loadView];
    XCTAssertNotNil(punchEntryVC, @"Cannot create PunchEntryViewController instance");
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
}
- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}
-(void)testForTransfer
{
    NSString *testStr=[NSString stringWithFormat:@"%@",RPLocalizedString(Transfer_Title,@"")];
    
    BOOL isLoginSuccessfull=[[NSUserDefaults standardUserDefaults] boolForKey:@"isSuccessLogin"];
    if (isLoginSuccessfull)
    {
         XCTAssertEqualObjects([punchEntryVC checkForTrasferWithActvityPermission :punchEntryVC.hasActivityAccess forSegmentCtrl:punchEntryVC.segmentedCtrl], testStr, @"Transfer button failed.");
    }
   else
   {
       XCTAssertEqualObjects([punchEntryVC checkForTrasferWithActvityPermission :punchEntryVC.hasActivityAccess forSegmentCtrl:punchEntryVC.segmentedCtrl], nil, @"Transfer option not available.");
   }
}


@end
