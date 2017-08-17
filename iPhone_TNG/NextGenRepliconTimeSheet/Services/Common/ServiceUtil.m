//
//  ServiceUtil.m
//  Replicon
//
//  Created by Devi Malladi on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ServiceUtil.h"

static ServiceUtil *service = nil;
@implementation ServiceUtil
#pragma mark Make ServiceUtil a singleton

+ (ServiceUtil *) sharedInstance {
	
	@synchronized(self) {
		if(service  == nil) {
			service = [[ServiceUtil alloc] init];
		}
	}
	return service;
}

+(NSString *)getServiceURLToFetchCompanyURL{
	
	NSString *serviceURL = [[AppProperties getInstance]getAppPropertyFor:@"ServiceURL_ToFetchCompanyURL"];
	
	return serviceURL;
}

+(NSString *)getServiceURLWithCompanyName:(NSString*)_companyName{
	NSString *serviceURL = [[AppProperties getInstance]getAppPropertyFor:@"ServiceURL_Production"];
	serviceURL = [serviceURL 
				  stringByReplacingOccurrencesOfString:@"CompanyName" withString:_companyName];
	
	return serviceURL;
}

+(NSString *)getServiceURLForSupportPageWithCompanyName:(NSString*)_companyName{
	NSString *serviceURL = [[AppProperties getInstance]getAppPropertyFor:@"ForgotPasswordURL"];
	serviceURL = [serviceURL 
				  stringByReplacingOccurrencesOfString:@"CompanyName" withString:_companyName];
	
	return serviceURL;
}

+(NSString *)getServiceURLFor:(NSString*)reqName replaceString:(NSString*)repStr WithCompanyName:(NSString*)_companyName{
	NSString *serviceURL = [[AppProperties getInstance]getAppPropertyFor:reqName];
	serviceURL = [serviceURL 
				  stringByReplacingOccurrencesOfString:repStr withString:_companyName];
	
	return serviceURL;
}
+(NSNumber *)getServiceIDForServiceName:(NSString *)_serviceName{
	
	NSNumber *serviceId = [[AppProperties getInstance]getServiceMappingPropertyFor:_serviceName];
	return serviceId;
}

+(NSString *)getServiceURLForServiceID:(int)serviceID{

    NSString *serviceURL = [[AppProperties getInstance]getServiceKeyForValue:serviceID];
    return serviceURL;
}

+(NSNumber *)getServiceAppendURLForServiceName:(NSString *)_serviceName{
	
	NSNumber *serviceId = [[AppProperties getInstance]getServiceMappingPropertyFor:_serviceName];
	return serviceId;
}

@end


