#import "G2AppProperties.h"


@implementation G2AppProperties

@synthesize propertiesDict;
@synthesize serviceMappingDict;

static G2AppProperties *myAppProperties = nil;


+ (G2AppProperties *) getInstance {
	
	@synchronized(self) {
		
		if(myAppProperties == nil) { // First time invocation

			myAppProperties = [[G2AppProperties alloc] init];
			id plist;
			NSBundle *mainBundle = [NSBundle mainBundle];
			
			NSString *path = [mainBundle pathForResource:G2CommonPlistFile ofType:@"plist"];
			NSData *plistData = [NSData dataWithContentsOfFile:path];
			NSError *error;
			NSPropertyListFormat format;
			if(plistData != nil && plistData != NULL && plistData) {
                plist = [NSPropertyListSerialization propertyListWithData:plistData
                                                                  options:NSPropertyListImmutable
                                                                   format:&format
                                                                    error:&error];
				if(!plist) {
					
								
				}
				myAppProperties.propertiesDict = (NSDictionary *) plist;
				
			}
			path = [mainBundle pathForResource:G2ServiceMappingFile ofType:@"plist"];
			plistData = [NSData dataWithContentsOfFile:path];
			if(plistData != nil && plistData != NULL && plistData) {
                plist = [NSPropertyListSerialization propertyListWithData:plistData
                                                                  options:NSPropertyListImmutable
                                                                   format:&format
                                                                    error:&error];
				if(!plist) {
					
								
				}
				
				myAppProperties.serviceMappingDict = (NSDictionary *)plist;
			}
			
	}
	}
	return myAppProperties;
}

- (id) getAppPropertyFor:(NSString *) propertyName {
	
	if(propertiesDict == nil) {	// No initialization has ocurred yet! so initialize
		G2AppProperties *appProps = [G2AppProperties getInstance];
		return [appProps getAppPropertyFor:propertyName];
	}
	
	if(propertyName != nil) {
		return [propertiesDict objectForKey:propertyName];
	}
	return nil;
}
	
- (id) getServiceMappingPropertyFor:(NSString *) propertyName {
		
		if(serviceMappingDict == nil) {	// No initialization has ocurred yet! so initialize
			G2AppProperties *appProps = [G2AppProperties getInstance];
			return [appProps getAppPropertyFor:propertyName];
		}
	
		if(propertyName != nil) {
			return [serviceMappingDict objectForKey:propertyName];
		}
		return nil;
}
	



+ (id) allocWithZone: (NSZone *)zone{
	
    @synchronized(self) {
        
		if (myAppProperties == nil) {
            myAppProperties = [super allocWithZone:zone];			
            return myAppProperties;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil	
}
  
- (id) copyWithZone: (NSZone *)zone {

    return self;
}





@end
