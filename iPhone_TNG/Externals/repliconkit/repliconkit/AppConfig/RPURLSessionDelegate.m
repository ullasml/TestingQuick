//
//  URLSessionDelegate.m
//  repliconkit
//
//  Created by Ravikumar Duvvuri on 24/04/17.
//  Copyright © 2017 replicon. All rights reserved.
//

#import "RPURLSessionDelegate.h"

@implementation RPURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {
    [session resetWithCompletionHandler:^{
    }];
}

@end
