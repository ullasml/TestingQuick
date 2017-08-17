//
//  OEFRequestProvider.m
//  NextGenRepliconTimeSheet
//
//  Created by Prakashini Pattabiraman on 04/11/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import "OEFTypesRequestProvider.h"
#import "RequestBuilder.h"

@interface OEFTypesRequestProvider()

@property (nonatomic) URLStringProvider *urlStringProvider;

@end

@implementation OEFTypesRequestProvider

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider
{
    self = [super init];
    if (self) {
        self.urlStringProvider = urlStringProvider;
    }
    return self;
}


- (NSURLRequest *)requestForOEFTypesForUserUri:(NSString *)UserUri {
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"BulkGetObjectExtensionFieldBindingsForUsers"];
    
    NSDictionary *requestBody = @{@"userUris": @[UserUri]};
    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:requestBody options:0 error:nil];
    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];
    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};
    
    return [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];
}


#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


@end
