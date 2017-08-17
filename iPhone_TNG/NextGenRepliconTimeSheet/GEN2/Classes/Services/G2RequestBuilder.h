//
//  RequestBuilder.h
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "G2Constants.h"
@interface G2RequestBuilder : NSObject {

}

// methods for building request - contain all static methods
+ (NSMutableURLRequest *)buildPOSTRequestWithParamDict:(NSDictionary *)dict;
+ (NSMutableURLRequest *)buildGETRequestWithParamDict:(NSDictionary *)dict;
+ (NSMutableURLRequest *)buildPOSTRequestWithParamDictToHandleCookies:(NSDictionary *)_paramdict;
+ (NSMutableURLRequest *)buildPOSTRequestWithParamDictForApprovals:(NSDictionary *)_paramdict;
+ (NSMutableURLRequest *)buildPOSTRequestWithParamDictWithNoSecurityContext:(NSDictionary *)_paramdict;
+ (NSMutableURLRequest *)buildPOSTRequestWithParamDictForGen3:(NSDictionary *)_paramdict;
@end
