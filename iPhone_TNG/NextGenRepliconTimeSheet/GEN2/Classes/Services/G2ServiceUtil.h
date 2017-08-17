//
//  ServiceUtil.h
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2AppProperties.h"


@interface G2ServiceUtil : NSObject {
	
}
+ (G2ServiceUtil *) sharedInstance ;
+(NSString *)getServiceURLToFetchCompanyURL;
+(NSNumber *)getServiceIDForServiceName:(NSString *)_serviceName;
+(NSString *)getServiceURLWithCompanyName:(NSString*)_companyName;
+(NSString *)getServiceURLForSupportPageWithCompanyName:(NSString*)_companyName;
+(NSString *)getServiceURLFor:(NSString*)reqName replaceString:(NSString*)repStr WithCompanyName:(NSString*)_companyName;
@end
