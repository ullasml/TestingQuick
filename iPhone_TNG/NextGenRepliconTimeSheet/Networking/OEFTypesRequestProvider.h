//
//  OEFRequestProvider.h
//  NextGenRepliconTimeSheet
//
//  Created by Prakashini Pattabiraman on 04/11/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLStringProvider.h"

@interface OEFTypesRequestProvider : NSObject

@property (nonatomic, readonly) URLStringProvider *urlStringProvider;

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider;

- (NSURLRequest *)requestForOEFTypesForUserUri:(NSString *)UserUri;

@end
