#import <Cedar/Cedar.h>
#import <CoreLocation/CoreLocation.h>
#import "LocalPunch.h"
#import "Constants.h"
#import "BreakType.h"
#import "Activity.h"
#import "ProjectType.h"
#import "ClientType.h"
#import "TaskType.h"
#import "OEFType.h"
#import "GUIDProvider.h"


using namespace Cedar::Matchers;
using namespace Cedar::Doubles;


SPEC_BEGIN(LocalPunchSpec)

describe(@"LocalPunch", ^{
    
    context(@"without OEF", ^{
        describe(@"isEqual:", ^{
            __block LocalPunch *punchA;
            __block LocalPunch *punchB;
            __block NSDate *dateA;
            __block NSDate *dateB;
            __block CLLocation *locationA;
            __block CLLocation *locationB;
            __block NSString *addressA;
            __block NSString *addressB;
            __block NSString *breakUriA;
            __block NSString *breakUriB;
            __block BreakType *breakTypeA;
            __block BreakType *breakTypeB;
            __block Activity *activityA;
            __block Activity *activityB;
            __block ProjectType *projectA;
            __block ProjectType *projectB;
            __block ClientType *clientA;
            __block ClientType *clientB;
            __block TaskType *taskA;
            __block TaskType *taskB;
            __block NSString *punchARequestId;
            __block NSString *punchBRequestId;
            
            beforeEach(^{
                breakTypeA = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
                breakTypeB = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
                activityA = [[Activity alloc] initWithName:@"Activity" uri:@"uri"];
                activityB = [[Activity alloc] initWithName:@"Activity" uri:@"uri"];
                projectA = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project" uri:@"uri"];
                projectB = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project" uri:@"uri"];
                clientA = [[ClientType alloc]initWithName:@"Client" uri:@"uri"];
                clientB = [[ClientType alloc]initWithName:@"Client" uri:@"uri"];
                taskA = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task" uri:@"uri"];
                taskB = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task" uri:@"uri"];
                punchARequestId = [[NSUUID UUID] UUIDString];
                punchBRequestId = [[NSUUID UUID] UUIDString];
            });
            
            it(@"should not be equal when compring a different type of object", ^{
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];
                punchA should_not equal((LocalPunch *)[NSDate date]);
            });
            
            it(@"should be equal when all members are nil", ^{
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:nil address:nil userURI:nil image:nil task:nil date:nil];
                
                punchA should equal(punchB);
            });
            
            it(@"when all members are equal should be equal", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                NSString *userURIA = @"user-uri";
                NSString *userURIB = @"user-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:addressA userURI:userURIA image:image task:taskA date:dateA];
                
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:addressB userURI:userURIB image:[image copy] task:taskB date:dateB];
                
                punchA should equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for date", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:101];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:addressB userURI:nil image:[image copy] task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should be equal when all members are equal and there are two nil dates", ^{
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:nil];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:addressB userURI:nil image:[image copy] task:taskB date:nil];
                
                punchA should equal(punchB);
            });
            
            it(@"should not be equal when all members are equal and there is one nil date", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:addressB userURI:nil image:[image copy] task:taskB date:nil];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should be equal when all members are equal and there are two nil locations", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:nil project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:nil project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:addressB userURI:nil image:[image copy] task:taskB date:dateB];
                
                punchA should equal(punchB);
            });
            
            it(@"should be equal when all member are equal and there are two nil images", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:@"asdf" userURI:nil image:nil task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:@"asdf" userURI:nil image:nil task:taskB date:dateB];
                punchA should equal(punchB);
            });
            
            it(@"should not be equal when all members are equal and there are two nil addresses", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:nil userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:nil userURI:nil image:[image copy] task:taskB date:dateB];
                
                
                punchA should equal(punchB);
            });
            
            it(@"should be equal when all members are equal and there are two nil break URIs", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:@"asdf" userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:@"asdf" userURI:nil image:[image copy] task:taskB date:dateB];
                
                
                punchA should equal(punchB);
            });
            
            it(@"should be equal when all members are equal and there are two nil break types", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:@"asdf" userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:@"asdf" userURI:nil image:[image copy] task:taskB date:dateB];
                
                
                punchA should equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for location's latitude", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(60.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:addressB userURI:nil image:image task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for location's longitude", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 4.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:addressB userURI:nil image:image task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for horizontal accuracy", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.6 verticalAccuracy:-1 timestamp:dateB];
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:addressB userURI:nil image:image task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for address", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"The White House";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:addressB userURI:nil image:image task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for breakUri", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"asdf";
                breakUriB = @"zxcv";
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:addressB userURI:nil image:image task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for image", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *imageA = [UIImage imageNamed:ExpensesImageUp];
                UIImage *imageB = [UIImage imageNamed:ApprovalsImageUp];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:@"asdf" userURI:nil image:imageA task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:@"asdf" userURI:nil image:imageB task:taskB date:dateB];
                
                punchA should_not equal(punchB);
                
            });
            
            it(@"should not be equal when all members are equal except for break type", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *imageA = [UIImage imageNamed:ExpensesImageUp];
                UIImage *imageB = [UIImage imageNamed:ApprovalsImageUp];
                
                breakTypeA = [[BreakType alloc] initWithName:@"Talk about your feelings break" uri:@"feelings"];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:@"asdf" userURI:nil image:imageA task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:@"asdf" userURI:nil image:imageB task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when the user URI differs", ^{
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:nil userURI:@"whoops" image:nil task:taskA date:nil];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:nil userURI:@"we accidentally the user URI" image:nil task:taskB date:nil];
                punchA should_not equal(punchB);
            });
            it(@"should not be equal when the project differs", ^{
                ProjectType *projectC = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"New Project" uri:@"new uri"];
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:nil userURI:nil image:nil task:taskA date:nil];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectC requestID:NULL activity:activityB client:clientB oefTypes:nil address:nil userURI:nil image:nil task:taskB date:nil];
                punchA should_not equal(punchB);
            });
            it(@"should not be equal when the client differs", ^{
                ClientType *clientC = [[ClientType alloc]initWithName:@"New Client" uri:@"new uri"];
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:nil userURI:nil image:nil task:taskA date:nil];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectB requestID:NULL activity:activityB client:clientC oefTypes:nil address:nil userURI:nil image:nil task:taskB date:nil];
                punchA should_not equal(punchB);
            });
            it(@"should not be equal when the task differs", ^{
                TaskType *taskC = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"New Task" uri:@"new uri"];
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:nil userURI:nil image:nil task:taskA date:nil];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:nil userURI:nil image:nil task:taskC date:nil];
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for oefTypes", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:101];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:addressB userURI:nil image:[image copy] task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when one of request Id is diffrent for punches", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:101];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:punchARequestId activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:punchBRequestId activity:activityB client:clientB oefTypes:nil address:addressB userURI:nil image:[image copy] task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should be equal when all members are equal with requestID", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:101];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:punchBRequestId activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:punchBRequestId activity:activityB client:clientB oefTypes:nil address:addressB userURI:nil image:[image copy] task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
        
        });
        
        
        it(@"should implement NSCoding", ^{
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.0, 3.0);
            CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
            UIImage *image = [UIImage imageNamed:@"icon_tabBar_approvals"];
            NSString *address = @"875 Howard St, San Francisco, CA";
            BreakType *mealBreak = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            Activity *activity = [[Activity alloc]initWithName:@"Activity-Name" uri:@"Activity-Uri"];
            ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
            ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
            TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task-Name" uri:@"Task-Uri"];
            
            NSString *punchRequestID =  [[NSUUID UUID] UUIDString];
            
            LocalPunch *punchToBeEncoded = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:mealBreak location:location project:project requestID:punchRequestID activity:activity client:client oefTypes:nil address:address userURI:@"user-uri" image:image task:task date:[NSDate date]];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:punchToBeEncoded];
            LocalPunch *decodedPunch = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            LocalPunch *copiedPunch = [decodedPunch copyWithZone:nil];
            
            copiedPunch.activity should_not be_nil;
            copiedPunch.project should_not be_nil;
            copiedPunch.client should_not be_nil;
            copiedPunch.task should_not be_nil;
            copiedPunch.oefTypesArray should be_nil;
            copiedPunch.requestID should_not be_nil;
            copiedPunch should equal(punchToBeEncoded);
        });
        
        describe(@"copyWithZone:", ^{
            it(@"should return an exact copy of the object", ^{
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.0, 3.0);
                CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                BreakType *mealBreak = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
                Activity *activity = [[Activity alloc]initWithName:@"Activity-Name" uri:@"Activity-Uri"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
                ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task-Name" uri:@"Task-Uri"];
                NSString *punchRequestID =  [[NSUUID UUID] UUIDString];
                
                LocalPunch *punchToBeCopied = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:mealBreak location:location project:project requestID:punchRequestID activity:activity client:client oefTypes:nil address:@"My House" userURI:@"user-uri" image:image task:task date:[NSDate date]];
                
                LocalPunch *copiedPunch = [punchToBeCopied copyWithZone:nil];
                
                copiedPunch should equal(punchToBeCopied);
                copiedPunch should_not be_same_instance_as(punchToBeCopied);
                copiedPunch.location should_not be_same_instance_as(punchToBeCopied.location);
            });
        });
        
        describe(@"copy", ^{
            it(@"should return an exact copy of the object", ^{
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.0, 3.0);
                CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                BreakType *mealBreak = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
                Activity *activity = [[Activity alloc]initWithName:@"Activity-Name" uri:@"Activity-Uri"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
                ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task-Name" uri:@"Task-Uri"];
                
                NSString *punchRequestID =  [[NSUUID UUID] UUIDString];
                LocalPunch *punchToBeCopied = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:mealBreak location:location project:project requestID:punchRequestID activity:activity client:client oefTypes:nil address:@"My House" userURI:@"user-uri" image:image task:task date:[NSDate date]];
                
                LocalPunch *copiedPunch = [punchToBeCopied copy];
                
                copiedPunch should equal(punchToBeCopied);
                copiedPunch should_not be_same_instance_as(punchToBeCopied);
                copiedPunch.location should_not be_same_instance_as(punchToBeCopied.location);
            });
        });
    });
    
    context(@"with OEF", ^{
        describe(@"isEqual:", ^{
            __block LocalPunch *punchA;
            __block LocalPunch *punchB;
            __block NSDate *dateA;
            __block NSDate *dateB;
            __block CLLocation *locationA;
            __block CLLocation *locationB;
            __block NSString *addressA;
            __block NSString *addressB;
            __block NSString *breakUriA;
            __block NSString *breakUriB;
            __block BreakType *breakTypeA;
            __block BreakType *breakTypeB;
            __block Activity *activityA;
            __block Activity *activityB;
            __block ProjectType *projectA;
            __block ProjectType *projectB;
            __block ClientType *clientA;
            __block ClientType *clientB;
            __block TaskType *taskA;
            __block TaskType *taskB;
            __block NSMutableArray *oefTypesArray;
            __block OEFType *oefType1;
            __block OEFType *oefType2;
            __block OEFType *oefType3;
            __block NSString *punchARequestId;
            __block NSString *punchBRequestId;
            
            beforeEach(^{
                breakTypeA = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
                breakTypeB = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
                activityA = [[Activity alloc] initWithName:@"Activity" uri:@"uri"];
                activityB = [[Activity alloc] initWithName:@"Activity" uri:@"uri"];
                projectA = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project" uri:@"uri"];
                projectB = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project" uri:@"uri"];
                clientA = [[ClientType alloc]initWithName:@"Client" uri:@"uri"];
                clientB = [[ClientType alloc]initWithName:@"Client" uri:@"uri"];
                taskA = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task" uri:@"uri"];
                taskB = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task" uri:@"uri"];
                
                oefType1 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType2 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-numeric" name:@"numeric 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefType3 = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 2" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                oefTypesArray = [NSMutableArray arrayWithObjects:oefType1,oefType2,oefType3, nil];
                
                punchARequestId = [[NSUUID UUID] UUIDString];
                punchBRequestId = [[NSUUID UUID] UUIDString];

            });
            
            it(@"should not be equal when compring a different type of object", ^{
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:nil image:nil task:nil date:nil];
                punchA should_not equal((LocalPunch *)[NSDate date]);
            });
            
            it(@"should be equal when all members are nil", ^{
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:nil image:nil task:nil date:nil];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:nil requestID:NULL activity:nil client:nil oefTypes:oefTypesArray address:nil userURI:nil image:nil task:nil date:nil];
                
                punchA should equal(punchB);
            });
            
            it(@"when all members are equal should be equal", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                NSString *userURIA = @"user-uri";
                NSString *userURIB = @"user-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:addressA userURI:userURIA image:image task:taskA date:dateA];
                
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:userURIB image:[image copy] task:taskB date:dateB];
                
                punchA should equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for date", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:101];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:nil image:[image copy] task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should be equal when all members are equal and there are two nil dates", ^{
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:addressA userURI:nil image:image task:taskA date:nil];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:nil image:[image copy] task:taskB date:nil];
                
                punchA should equal(punchB);
            });
            
            it(@"should not be equal when all members are equal and there is one nil date", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:nil image:[image copy] task:taskB date:nil];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should be equal when all members are equal and there are two nil locations", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:nil project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:nil project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:nil image:[image copy] task:taskB date:dateB];
                
                punchA should equal(punchB);
            });
            
            it(@"should be equal when all member are equal and there are two nil images", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:@"asdf" userURI:nil image:nil task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:@"asdf" userURI:nil image:nil task:taskB date:dateB];
                punchA should equal(punchB);
            });
            
            it(@"should not be equal when all members are equal and there are two nil addresses", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:nil userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:nil userURI:nil image:[image copy] task:taskB date:dateB];
                
                
                punchA should equal(punchB);
            });
            
            it(@"should be equal when all members are equal and there are two nil break URIs", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:@"asdf" userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:@"asdf" userURI:nil image:[image copy] task:taskB date:dateB];
                
                
                punchA should equal(punchB);
            });
            
            it(@"should be equal when all members are equal and there are two nil break types", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:@"asdf" userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:@"asdf" userURI:nil image:[image copy] task:taskB date:dateB];
                
                
                punchA should equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for location's latitude", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(60.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:nil image:image task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for location's longitude", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 4.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:nil image:image task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for horizontal accuracy", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.6 verticalAccuracy:-1 timestamp:dateB];
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:nil image:image task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for address", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"The White House";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:nil image:image task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for breakUri", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"asdf";
                breakUriB = @"zxcv";
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchOut lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:nil image:image task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for image", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *imageA = [UIImage imageNamed:ExpensesImageUp];
                UIImage *imageB = [UIImage imageNamed:ApprovalsImageUp];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:@"asdf" userURI:nil image:imageA task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:@"asdf" userURI:nil image:imageB task:taskB date:dateB];
                
                punchA should_not equal(punchB);
                
            });
            
            it(@"should not be equal when all members are equal except for break type", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:100];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *imageA = [UIImage imageNamed:ExpensesImageUp];
                UIImage *imageB = [UIImage imageNamed:ApprovalsImageUp];
                
                breakTypeA = [[BreakType alloc] initWithName:@"Talk about your feelings break" uri:@"feelings"];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:@"asdf" userURI:nil image:imageA task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:@"asdf" userURI:nil image:imageB task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when the user URI differs", ^{
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:nil userURI:@"whoops" image:nil task:taskA date:nil];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:nil userURI:@"we accidentally the user URI" image:nil task:taskB date:nil];
                punchA should_not equal(punchB);
            });
            it(@"should not be equal when the project differs", ^{
                ProjectType *projectC = [[ProjectType alloc] initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"New Project" uri:@"new uri"];
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:nil userURI:nil image:nil task:taskA date:nil];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectC requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:nil userURI:nil image:nil task:taskB date:nil];
                punchA should_not equal(punchB);
            });
            it(@"should not be equal when the client differs", ^{
                ClientType *clientC = [[ClientType alloc]initWithName:@"New Client" uri:@"new uri"];
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:nil userURI:nil image:nil task:taskA date:nil];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectB requestID:NULL activity:activityB client:clientC oefTypes:oefTypesArray address:nil userURI:nil image:nil task:taskB date:nil];
                punchA should_not equal(punchB);
            });
            it(@"should not be equal when the task differs", ^{
                TaskType *taskC = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"New Task" uri:@"new uri"];
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectA requestID:NULL activity:activityA client:clientA oefTypes:oefTypesArray address:nil userURI:nil image:nil task:taskA date:nil];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:nil location:nil project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:nil userURI:nil image:nil task:taskC date:nil];
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for oefTypes", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:101];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                NSMutableArray *tempOEFTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:tempOEFTypesArray address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:nil image:[image copy] task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when one of the punch oeftypes array is nil", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:101];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:nil image:[image copy] task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should be equal when all members are equal and there are two nil oef types", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:101];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:NULL activity:activityA client:clientA oefTypes:nil address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:NULL activity:activityB client:clientB oefTypes:nil address:addressB userURI:nil image:[image copy] task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal except for requestID", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:101];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                NSMutableArray *tempOEFTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:punchARequestId activity:activityA client:clientA oefTypes:tempOEFTypesArray address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:punchBRequestId activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:nil image:[image copy] task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
            
            it(@"should not be equal when all members are equal", ^{
                dateA = [NSDate dateWithTimeIntervalSince1970:100];
                dateB = [NSDate dateWithTimeIntervalSince1970:101];
                CLLocationCoordinate2D coordinateA = CLLocationCoordinate2DMake(50.0, 3.0);
                locationA = [[CLLocation alloc] initWithCoordinate:coordinateA altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateA];
                
                CLLocationCoordinate2D coordinateB = CLLocationCoordinate2DMake(50.0, 3.0);
                locationB = [[CLLocation alloc] initWithCoordinate:coordinateB altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:dateB];
                
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                
                addressA = @"875 Howard St, San Francisco, CA";
                addressB = @"875 Howard St, San Francisco, CA";
                
                breakUriA = @"break-uri";
                breakUriB = @"break-uri";
                
                
                
                punchA = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeA location:locationA project:projectA requestID:punchARequestId activity:activityA client:clientA oefTypes:oefTypesArray address:addressA userURI:nil image:image task:taskA date:dateA];
                punchB = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:breakTypeB location:locationB project:projectB requestID:punchARequestId activity:activityB client:clientB oefTypes:oefTypesArray address:addressB userURI:nil image:[image copy] task:taskB date:dateB];
                
                punchA should_not equal(punchB);
            });
        });
        
        it(@"should implement NSCoding", ^{
            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.0, 3.0);
            CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
            UIImage *image = [UIImage imageNamed:@"icon_tabBar_approvals"];
            NSString *address = @"875 Howard St, San Francisco, CA";
            BreakType *mealBreak = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
            Activity *activity = [[Activity alloc]initWithName:@"Activity-Name" uri:@"Activity-Uri"];
            ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
            ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
            TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task-Name" uri:@"Task-Uri"];
            OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
            NSMutableArray *oefTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];
            NSString*requestID = [[NSUUID UUID] UUIDString];
            LocalPunch *punchToBeEncoded = [[LocalPunch alloc] initWithPunchSyncStatus:UnsubmittedSyncStatus actionType:PunchActionTypePunchIn lastSyncTime:[NSDate date] breakType:mealBreak location:location project:project requestID:requestID activity:activity client:client oefTypes:oefTypesArray address:address userURI:@"user-uri" image:image task:task date:[NSDate date]];
            
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:punchToBeEncoded];
            LocalPunch *decodedPunch = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            LocalPunch *copiedPunch = [decodedPunch copyWithZone:nil];
            
            copiedPunch.activity should_not be_nil;
            copiedPunch.project should_not be_nil;
            copiedPunch.client should_not be_nil;
            copiedPunch.task should_not be_nil;
            copiedPunch.oefTypesArray should_not be_nil;
            copiedPunch should equal(punchToBeEncoded);
        });
        
        describe(@"copyWithZone:", ^{
            it(@"should return an exact copy of the object", ^{
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.0, 3.0);
                CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                BreakType *mealBreak = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
                Activity *activity = [[Activity alloc]initWithName:@"Activity-Name" uri:@"Activity-Uri"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
                ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task-Name" uri:@"Task-Uri"];
                OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                NSMutableArray *oefTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];
                
                NSString*requestID = [[NSUUID UUID] UUIDString];
                
                LocalPunch *punchToBeCopied = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:mealBreak location:location project:project requestID:requestID activity:activity client:client oefTypes:oefTypesArray address:@"My House" userURI:@"user-uri" image:image task:task date:[NSDate date]];
                
                LocalPunch *copiedPunch = [punchToBeCopied copyWithZone:nil];
                
                copiedPunch should equal(punchToBeCopied);
                copiedPunch should_not be_same_instance_as(punchToBeCopied);
                copiedPunch.location should_not be_same_instance_as(punchToBeCopied.location);
            });
        });
        
        describe(@"copy", ^{
            it(@"should return an exact copy of the object", ^{
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(50.0, 3.0);
                CLLocation *location = [[CLLocation alloc] initWithCoordinate:coordinate altitude:-1 horizontalAccuracy:44.4 verticalAccuracy:-1 timestamp:[NSDate date]];
                UIImage *image = [UIImage imageNamed:ExpensesImageUp];
                BreakType *mealBreak = [[BreakType alloc] initWithName:@"Meal Break" uri:@"meal-break"];
                Activity *activity = [[Activity alloc]initWithName:@"Activity-Name" uri:@"Activity-Uri"];
                ProjectType *project = [[ProjectType alloc]initWithTasksAvailableForTimeAllocation:NO isTimeAllocationAllowed:NO projectPeriod:nil clientType:nil name:@"Project-Name" uri:@"Project-Uri"];
                ClientType *client = [[ClientType alloc]initWithName:@"Client-Name" uri:@"Client-Uri"];
                TaskType *task = [[TaskType alloc]initWithProjectUri:nil taskPeriod:nil name:@"Task-Name" uri:@"Task-Uri"];
                OEFType *oefType = [[OEFType alloc] initWithUri:nil definitionTypeUri:@"urn:replicon:object-extension-definition-type:object-extension-type-text" name:@"text 1" punchActionType:nil numericValue:nil textValue:nil dropdownOptionUri:nil dropdownOptionValue:nil collectAtTimeOfPunch:NO disabled:NO];
                NSMutableArray *oefTypesArray = [NSMutableArray arrayWithObjects:oefType, nil];
                NSString*requestID = [[NSUUID UUID] UUIDString];
                LocalPunch *punchToBeCopied = [[LocalPunch alloc] initWithPunchSyncStatus:(UnsubmittedSyncStatus) actionType:PunchActionTypePunchIn lastSyncTime:NULL breakType:mealBreak location:location project:project requestID:requestID activity:activity client:client oefTypes:oefTypesArray address:@"My House" userURI:@"user-uri" image:image task:task date:[NSDate date]];
                
                LocalPunch *copiedPunch = [punchToBeCopied copy];
                
                copiedPunch should equal(punchToBeCopied);
                copiedPunch should_not be_same_instance_as(punchToBeCopied);
                copiedPunch.location should_not be_same_instance_as(punchToBeCopied.location);
            });
        });
    });
});

SPEC_END
