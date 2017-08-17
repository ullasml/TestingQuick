//
//  RequestBuilder.h
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Constants.h"
@interface RequestBuilder : NSObject {

}

// methods for building request - contain all static methods
+ (NSMutableURLRequest *)buildPOSTRequestWithParamDict:(NSDictionary *)dict;
+ (NSMutableURLRequest *)buildGETRequestWithParamDict:(NSDictionary *)dict;
+ (NSMutableURLRequest *)buildPOSTRequestWithParamDictToHandleCookies:(NSDictionary *)_paramdict;
+ (NSMutableURLRequest *)buildGETRequestWithParamDictToHandleCookies:(NSDictionary *)_paramdict;
+ (NSMutableURLRequest *)buildPOSTRequestWithParamDictAndBasicAuth:(NSDictionary *)_paramdict;
+ (NSMutableURLRequest *)buildPOSTRequestForFreeTrialWithParamDict:(NSDictionary *)_paramdict;
+ (NSMutableURLRequest *)buildPOSTRequestForContactingSupportWithParamDict:(NSDictionary *)_paramdict;

@end
