//
//  AppLevelModel.h
//  Replicon
//
//  Created by vijaysai on 9/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2SQLiteDB.h"

@interface G2AppLevelModel : NSObject {
    
}

-(void)upgradeDB: (NSString *) newVersion;
-(void) updateFromVersionCurrentToVersionNew;

@end
