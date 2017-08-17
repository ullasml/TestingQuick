//
//  BaseService.h
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "G2URLReader.h"
@interface G2BaseService : NSObject {

	G2URLReader *urlReader;
	//NSMutableDictionary *refDict;
	id request ;
	id __weak serviceDelegate;
	id serviceID;
}

//@property (nonatomic,retain)NSMutableDictionary *refDict;
@property (nonatomic,strong)id request ;
@property (nonatomic,weak)id serviceDelegate;
@property (nonatomic,strong)id serviceID;

-(void)executeRequest;
-(void)executeRequest:(id)params;
-(void)terminateAsyncronousService;
-(void)executeSynchronusRequest;
-(void)executeSynchronusRequest:(id)params;
-(void)removeUserInformationWithCookies;
-(void)executeRequestWithTimeOut:(int)timeOutVal;
@end
