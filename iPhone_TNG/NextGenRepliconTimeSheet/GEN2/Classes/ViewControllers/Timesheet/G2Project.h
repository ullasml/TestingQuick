//
//  Projects.h
//  Replicon
//
//  Created by Hepciba on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface G2Project : NSObject {
	
	NSString *name;
	NSString *code;
	BOOL	projectStatus;
	NSString *timeEntryStartDate;
	NSString *timeEntryEndDate;
	NSString *clientIdentity;
	NSString *identity;
	
}
@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *code;
@property(nonatomic,assign)BOOL projectStatus;
@property(nonatomic,strong)NSString *timeEntryStartDate;
@property(nonatomic,strong)NSString *timeEntryEndDate;
@property(nonatomic,strong)NSString *clientIdentity;
@property(nonatomic,strong)NSString *identity;

@end
