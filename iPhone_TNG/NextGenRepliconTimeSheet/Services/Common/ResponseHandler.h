//
//  ResponseHandler.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 2/4/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enum.h"

@interface ResponseHandler : NSObject


+ (id)sharedResponseHandler;

- (void)handleServerResponseError:(NSDictionary *)errorDict serviceURL:(NSString *)serviceURL;
-(void)handleHTTPResponseError:(NSInteger)statusCode andDescription:(NSString *)responseHeaders andError:(NSError *)error applicationState:(ApplicateState)applicationState;
-(void)handleNSURLErrorDomainCodes:(NSError *)error applicationState:(ApplicateState)applicationState;

- (BOOL)checkForExceptions:(NSDictionary *)response serviceURL:(NSString *)serviceURL;
@end
