//
//  UdfObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 1/14/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@interface UdfObject : NSObject
@property (nonatomic,strong)    NSString    *udfUri;
@property (nonatomic,strong)	NSString    *udfName;
@property (nonatomic,strong)	NSString    *defaultValue;
@property (nonatomic,strong)	NSString    *dropDownOptionUri;
@property (nonatomic,assign)	float    maxValue;
@property (nonatomic,assign)    float    minValue;
@property (nonatomic,assign)	int    decimalPlaces;
@property (nonatomic,assign)   UDFType     udfType;

-(id)initWithDictionary:(NSDictionary *)dict;

@end
