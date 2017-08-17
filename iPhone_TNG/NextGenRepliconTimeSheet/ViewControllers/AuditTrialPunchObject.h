//
//  AuditTrialPunchObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 07/07/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuditTrialPunchObject : NSObject
@property(nonatomic,strong)NSString *punchActionuri;
@property(nonatomic,strong)NSString *punchTime;
@property(nonatomic,strong)NSString *punchTimeFormat;
@property(nonatomic,strong)NSString *punchDate;
@property(nonatomic,strong)NSString *punchtimeInUtc;
@property(nonatomic,strong)NSArray *commentsList;
@property(nonatomic,strong)NSDictionary *commentsInfoDict;
@end
