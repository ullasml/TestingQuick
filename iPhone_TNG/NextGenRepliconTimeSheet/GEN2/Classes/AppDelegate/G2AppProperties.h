#import <UIKit/UIKit.h>
#import "G2Constants.h"
/*
 * This calss takes care of just reading the App Properties from a pList and showing them.
 * Specifically, this class doesn't set the properties back into the pList
 */ 
@interface G2AppProperties : NSObject {

	NSDictionary *propertiesDict;
	NSDictionary *serviceMappingDict;
	
}

 @property(nonatomic,strong ) NSDictionary *propertiesDict;
 @property(nonatomic,strong ) NSDictionary *serviceMappingDict;

+ (G2AppProperties *) getInstance;

// - (BOOL) initWithpList: (NSString *) path;

- (id) getAppPropertyFor: (NSString *) propertyName;
- (id) getServiceMappingPropertyFor:(NSString *) propertyName;

@end
