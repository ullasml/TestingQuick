//
//  BadgesDelegate.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 12/14/15.
//  Copyright © 2015 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BadgesDelegate <NSObject>

-(void)updateBadgeValue:(NSNotification*)notification;
@end

