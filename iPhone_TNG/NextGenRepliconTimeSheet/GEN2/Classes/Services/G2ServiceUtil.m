//
//  ServiceUtil.m
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "G2ServiceUtil.h"

static G2ServiceUtil *service = nil;
@implementation G2ServiceUtil
#pragma mark Make ServiceUtil a singleton

+ (G2ServiceUtil *) sharedInstance {
	
	@synchronized(self) {
		if(service  == nil) {
			service = [[G2ServiceUtil alloc] init];
		}
	}
	return service;
}

+(NSString *)getServiceURLToFetchCompanyURL{
	
	NSString *serviceURL = [[G2AppProperties getInstance]getAppPropertyFor:@"ServiceURL_ToFetchCompanyURL"];
	
	return serviceURL;
}

+(NSString *)getServiceURLWithCompanyName:(NSString*)_companyName{
	NSString *serviceURL = [[G2AppProperties getInstance]getAppPropertyFor:@"ServiceURL_Production"];//@"ServiceURL_Staging"];//@"ServiceURL_Production"];////////
	serviceURL = [serviceURL 
				  stringByReplacingOccurrencesOfString:@"CompanyName" withString:_companyName];
	
	return serviceURL;
}

+(NSString *)getServiceURLForSupportPageWithCompanyName:(NSString*)_companyName{
	NSString *serviceURL = [[G2AppProperties getInstance]getAppPropertyFor:@"ForgotPasswordURL"];
	serviceURL = [serviceURL 
				  stringByReplacingOccurrencesOfString:@"CompanyName" withString:_companyName];
	
	return serviceURL;
}

+(NSString *)getServiceURLFor:(NSString*)reqName replaceString:(NSString*)repStr WithCompanyName:(NSString*)_companyName{
	NSString *serviceURL = [[G2AppProperties getInstance]getAppPropertyFor:reqName];
	serviceURL = [serviceURL 
				  stringByReplacingOccurrencesOfString:repStr withString:_companyName];
	
	return serviceURL;
}
+(NSNumber *)getServiceIDForServiceName:(NSString *)_serviceName{
	
	NSNumber *serviceId = [[G2AppProperties getInstance]getServiceMappingPropertyFor:_serviceName];
	return serviceId;
}


@end


