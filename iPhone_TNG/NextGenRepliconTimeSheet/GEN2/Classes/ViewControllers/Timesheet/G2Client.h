//
//  Client.h
//  Replicon
//
//  Created by Hepciba on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface G2Client : NSObject {
	NSString *clientName;
	NSString *clientIdentity;
	
}
@property(nonatomic,strong)NSString *clientName;
@property(nonatomic,strong)NSString *clientIdentity;

@end
