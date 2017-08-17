

#import <Foundation/Foundation.h>
#import "SQLiteDB.h"

@interface AppLevelModel : NSObject {
    
}

-(void)upgradeDB: (NSString *) newVersion;
-(void) updateFromVersionCurrentToVersionNew;

@end
