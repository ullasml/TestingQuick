//
//  TeamTimePunchObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 27/03/14.
//  Copyright (c) 2014 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamTimePunchObject : NSObject

@property(nonatomic,strong)NSString *PunchInAddress;
@property(nonatomic,strong)NSString *PunchInDate;
@property(nonatomic,strong)NSString *PunchInDateTimestamp;
@property(nonatomic,strong)NSString *PunchInLatitude;
@property(nonatomic,strong)NSString *PunchInLongitude;
@property(nonatomic,strong)NSString *PunchInTime;
@property(nonatomic,strong)NSString *PunchOutAddress;
@property(nonatomic,strong)NSString *PunchOutDate;
@property(nonatomic,strong)NSString *PunchOutDateTimestamp;
@property(nonatomic,strong)NSString *PunchOutLatitude;
@property(nonatomic,strong)NSString *PunchOutLongitude;
@property(nonatomic,strong)NSString *PunchOutTime;
@property(nonatomic,strong)NSString *activityName;
@property(nonatomic,strong)NSString *activityUri;
@property(nonatomic,strong)NSString *punchInAgent;
@property(nonatomic,strong)NSString *punchInAgentUri;
@property(nonatomic,strong)NSString *punchInCloudClockUri;
@property(nonatomic,strong)NSString *punchInFullSizeImageLink;
@property(nonatomic,strong)NSString *punchInFullSizeImageUri;
@property(nonatomic,strong)NSString *punchInThumbnailSizeImageLink;
@property(nonatomic,strong)NSString *punchInThumbnailSizeImageUri;
@property(nonatomic,strong)NSString *punchInUri;
@property(nonatomic,strong)NSString *punchOutAgent;
@property(nonatomic,strong)NSString *punchOutAgentUri;
@property(nonatomic,strong)NSString *punchOutCloudClockUri;
@property(nonatomic,strong)NSString *punchOutFullSizeImageLink;
@property(nonatomic,strong)NSString *punchOutFullSizeImageUri;
@property(nonatomic,strong)NSString *punchOutThumbnailSizeImageLink;
@property(nonatomic,strong)NSString *punchOutThumbnailSizeImageUri;
@property(nonatomic,strong)NSString *punchOutUri;
@property(nonatomic,strong)NSString *punchUserName;
@property(nonatomic,strong)NSString *punchUserUri;
@property(nonatomic,strong)NSString *totalHours;
@property(nonatomic,strong)NSString *CellIdentifier;
@property(nonatomic,strong)NSString *breakName;
@property(nonatomic,strong)NSString *breakUri;
@property(nonatomic,strong)NSString *punchTransferredStatus;
@property(nonatomic,assign)BOOL isBreakPunch;
@property(nonatomic,strong)NSString *punchInAccuracyInMeters;
@property(nonatomic,strong)NSString *punchOutAccuracyInMeters;
@property(nonatomic,assign)BOOL isInManualEditPunch;
@property(nonatomic,assign)BOOL isOutManualEditPunch;
@property(nonatomic,strong)NSString *punchInActionUri;
@property(nonatomic,strong)NSString *punchOutActionUri;
@end
