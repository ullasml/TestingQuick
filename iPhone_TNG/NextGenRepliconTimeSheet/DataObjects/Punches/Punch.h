#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PunchActionTypes.h"
#import "Enum.h"

@class BreakType;
@class Activity;
@class ProjectType;
@class ClientType;
@class TaskType;


@protocol Punch <NSObject, NSCoding, NSCopying>

- (NSDate *)date;

- (PunchActionType)actionType;

- (BreakType *)breakType;

- (Activity *)activity;

- (ProjectType *)project;

- (ClientType *)client;

- (TaskType *)task;

- (CLLocation *)location;

- (NSString *)address;

- (NSString *)userURI;

- (NSArray *)oefTypesArray;

- (PunchSyncStatus)punchSyncStatus;

- (NSDate*)lastSyncTime;

- (NSString *)requestID;


@optional

- (BOOL)offline;

- (BOOL)authentic;

- (BOOL)manual;

- (UIImage *)image;

- (NSURL *)imageURL;

- (BOOL)syncedWithServer;

- (BOOL)isTimeEntryAvailable;

- (NSArray *)auditHstory;

- (NSArray *)violations;

- (NSInteger)nonActionedValidationsCount;

- (SourceOfPunch )sourceOfPunch;

- (NSDateComponents *)duration;

- (PunchPairStatus )nextPunchPairStatus;

- (PunchPairStatus)previousPunchPairStatus;


@end
