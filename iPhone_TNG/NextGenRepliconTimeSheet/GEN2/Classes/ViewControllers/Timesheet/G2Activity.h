//
//  Activities.h
//  Replicon
//
//  Created by Hepciba on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface G2Activity : NSObject {
	NSString *name;
	NSString *code;
	NSString *description;
	BOOL isEnabled;
	NSString *identity;

}
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *code;
@property(nonatomic,strong)NSString *description;
@property(nonatomic,assign)BOOL isEnabled;
@property(nonatomic,strong)NSString *identity;


@end
