#import <Foundation/Foundation.h>

@interface EntryCellDetails : NSObject <NSCoding, NSCopying>{
    NSMutableArray				*dataSourceArray;
	NSString					*fieldName;
	id							fieldValue;
	NSString					*fieldType;
	NSMutableArray				*componentSelectedIndexArray;
	id							defaultValue;
	id							maxValue;
	id							minValue;
	int							decimalPoints;
	BOOL						required;
	NSString					*udfIdentity;
	NSString					*udfModule;
    NSString                    *dropdownOptionUri;
    id                          systemDefaultValue;
}
@property(nonatomic,strong) NSMutableArray				*dataSourceArray;
@property(nonatomic,strong) NSString					*fieldName;
@property(nonatomic,strong) id							fieldValue;
@property(nonatomic,strong) NSString					*fieldType;
@property(nonatomic,strong) NSMutableArray				*componentSelectedIndexArray;
@property(nonatomic,strong) id							defaultValue;
@property(nonatomic,strong) id							maxValue;
@property(nonatomic,strong) id							minValue;
@property(nonatomic,strong) NSString					*udfIdentity;
@property(nonatomic,strong) NSString					*udfModule;
@property(nonatomic,assign) int							decimalPoints;
@property(nonatomic,assign) BOOL						required;
@property(nonatomic,strong) NSString                    *dropdownOptionUri;
@property(nonatomic,strong) id                          systemDefaultValue;

-(id)initWithDefaultValue :(id)_defaultValue;

@end
