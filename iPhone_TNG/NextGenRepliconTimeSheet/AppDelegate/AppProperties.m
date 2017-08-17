#import "AppProperties.h"
#import <Blindside/Blindside.h>
#import <repliconkit/AppConfig.h>
#import "AppDelegate.h"

/*  originalServicesURLDict - contains non node backend url
 *  mobileBackendURLDict - contains node backend url (by appending mobile-backend/ to the url). To ignore appending mobile-backend/, please add the end point to IgnoreServices.plist
 */

@interface AppProperties()

@property(nonatomic) NSDictionary *propertiesDict;
@property(nonatomic) NSDictionary *serviceMappingDict;
@property(nonatomic) NSDictionary *mobileBackendURLDict;
@property(nonatomic) NSDictionary *originalServicesURLDict;
@property(nonatomic) NSArray *timesheetURIArray;
@property(nonatomic) NSArray *expenseUriArray;
@property(nonatomic) NSArray *timeoffUriArray;
@property(nonatomic) NSArray *teamTimeUriArray;

@end

@implementation AppProperties

+(AppProperties *)getInstance
{
    static AppProperties *getInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        getInstance = [[AppProperties alloc] initPrivate];
    });
    
    return getInstance;
}

- (instancetype)initPrivate {
    if(self = [super init]) {
        [self loadPlist];
    }
    return self;
}

-(void)loadPlist{
    [self propertiesDict];
    [self serviceMappingDict];
    [self mobileBackendURLDict];
    [self originalServicesURLDict];
    [self timesheetURIArray];
    [self expenseUriArray];
    [self timeoffUriArray];
    [self teamTimeUriArray];
}

-(NSDictionary *)getDictionaryFromPlist:(NSString *)file{
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"plist"];
    return [[NSDictionary alloc] initWithContentsOfFile:path];
}

-(NSArray *)getArrayFromPlist:(NSString *)file{
    NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"plist"];
    return [[NSArray alloc] initWithContentsOfFile:path];
}

-(NSDictionary *)propertiesDict{
    if(!_propertiesDict){
        _propertiesDict = [self getDictionaryFromPlist:CommonPlistFile];
    }
    return _propertiesDict;
}

-(NSDictionary *)serviceMappingDict{
    if(!_serviceMappingDict){
        _serviceMappingDict = [self getDictionaryFromPlist:ServiceMappingFile];
    }
    return _serviceMappingDict;
}

-(NSDictionary *)originalServicesURLDict{
    if(!_originalServicesURLDict){
        _originalServicesURLDict = [self getDictionaryFromPlist:ServiceURLsFile];
    }
    return _originalServicesURLDict;
}

-(BOOL)isNodeBackendEnabled{
    
    id<BSInjector>injector = [(AppDelegate *)[[UIApplication sharedApplication] delegate] injector];
    AppConfig *appConfig = [injector getInstance:[AppConfig class]];
    BOOL inTests = (BOOL)NSClassFromString(@"XCTest");
    if (inTests){
        return NO;
    }
    return [appConfig getNodeBackend];
    
}

-(NSDictionary *)getMobileBackendURLDictionary{
    
    NSArray *ignoreList = [self getArrayFromPlist:IgnoreURLFile];
    
    NSMutableDictionary *updatedDict = [self.originalServicesURLDict mutableCopy];
    [updatedDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
        BOOL __block match = false;
        [ignoreList enumerateObjectsUsingBlock:^(id  _Nonnull subString, NSUInteger idx, BOOL * _Nonnull stop) {
            *stop = match = [[value lowercaseString] containsString:[subString lowercaseString]];
        }];
        if(!match){
            value = [NSString stringWithFormat:@"mobile-backend/%@",[value stringByReplacingOccurrencesOfString:@"mobile/" withString:@""]];
            [updatedDict setValue:value forKey:key];
        }
        
    }];
    return [updatedDict copy];
}

-(NSDictionary *)mobileBackendURLDict{
    if(!_mobileBackendURLDict){
        _mobileBackendURLDict = [self getMobileBackendURLDictionary];
    }
    return _mobileBackendURLDict;
}

-(NSArray *)timesheetURIArray{
    if(!_timesheetURIArray){
        _timesheetURIArray = [self getArrayFromPlist:TimesheetColumnURIFile];
    }
    return _timesheetURIArray;
}

-(NSArray *)expenseUriArray{
    if(!_expenseUriArray){
        _expenseUriArray = [self getArrayFromPlist:ExpenseColumnURIFile];
    }
    return _expenseUriArray;
}

-(NSArray *)timeoffUriArray{
    if(!_timeoffUriArray){
        _timeoffUriArray = [self getArrayFromPlist:TimeoffColumnURIFile];
    }
    return _timeoffUriArray;
}

-(NSArray *)teamTimeUriArray{
    if(!_teamTimeUriArray){
        _teamTimeUriArray = [self getArrayFromPlist:TeamTimeColumnURIFile];
    }
    return _teamTimeUriArray;
}


- (id) getAppPropertyFor:(NSString *) propertyName
{
    if(propertyName != nil)
    {
        return [self.propertiesDict objectForKey:propertyName];
    }
    return nil;
}

- (id) getServiceURLFor:(NSString *) propertyName
{
    if(propertyName != nil)
    {
        if([self isNodeBackendEnabled]){
            return [self.mobileBackendURLDict objectForKey:propertyName];
        }else{
            return [self.originalServicesURLDict objectForKey:propertyName];
        }
    }
    return nil;
}


- (id) getServiceMappingPropertyFor:(NSString *) propertyName
{
    if(propertyName != nil)
    {
        return [self.serviceMappingDict objectForKey:propertyName];
    }
    return nil;
}

- (NSString *) getServiceKeyForValue:(int) propertyValue
{
    
    NSArray *temp = [self.serviceMappingDict allKeysForObject:[NSString stringWithFormat:@"%d",propertyValue]];
    if (temp.count>0)
    {
        return [temp objectAtIndex:0];
    }
    return @"";
}


- (id) getTimesheetColumnURIFromPlist
{
    return self.timesheetURIArray;
}

-(id)getExpenseSheetColumnURIFromPlist{
    return self.expenseUriArray;
}

-(id)getTimeOffColumnURIFromPlist
{
    return self.timeoffUriArray;
}

-(id)getTeamTimeColumnURIFromPlist
{
    return self.teamTimeUriArray;
}

@end
