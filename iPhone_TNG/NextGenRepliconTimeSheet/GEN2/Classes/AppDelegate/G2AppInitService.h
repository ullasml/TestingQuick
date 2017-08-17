#import "G2AppProperties.h"
#import "G2SQLiteDB.h"
#import "G2Util.h"

@interface G2AppInitService : NSObject {
    
	G2AppProperties	*appProperties;
	
}

@property	(nonatomic , strong)	G2AppProperties *appProperties;


+ (G2AppInitService *) getInstance;

- (BOOL) initApplication;
-(void)upgradeDataBaseByAppVersion: (NSString *)newVersion;

@end