#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "RemotePunch.h"
#import "PunchActionTypes.h"

@class BreakType;

@protocol PunchProvider <NSObject>

- (RemotePunch *)providePunchWithDate:(NSDate *)date
                           actionType:(PunchActionType)actionType
                            breakType:(BreakType *)breakType
                             location:(CLLocation *)location
                              address:(NSString *)address
                             imageURL:(NSURL *)imageURL
                              userURI:(NSString *)userURI
                                  uri:(NSString *)uri
                 isTimeEntryAvailable:(BOOL)isTimeEntryAvailable;

@end
