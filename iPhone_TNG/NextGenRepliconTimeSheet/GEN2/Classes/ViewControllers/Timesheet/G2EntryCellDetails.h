//
//  EntryCellDetails.h
//  Replicon
//
//  Created by vijaysai on 8/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface G2EntryCellDetails : NSObject {

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


//Method Declarations

-(id)initWithDefaultValue :(id)_defaultValue;
-(void)checkAndRelease;

@end
