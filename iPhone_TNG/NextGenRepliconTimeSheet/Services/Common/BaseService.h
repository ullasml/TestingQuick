//
//  BaseService.h
//  Replicon
//
//  Created by Hemabindu on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLReader.h"

@interface BaseService : NSObject
{

	URLReader *urlReader;
	id request ;
	id __weak serviceDelegate;
	id serviceID;
}


@property (nonatomic,strong)id request ;
@property (nonatomic,weak)id serviceDelegate;
@property (nonatomic,strong)id serviceID;

-(void)executeRequest;
-(void)executeRequest:(id)params;
-(void)terminateAsyncronousService;
-(void)executeSynchronusRequest;
-(void)executeSynchronusRequest:(id)params;

-(void)executeRequestWithTimeOut:(int)timeOutVal;
@end
