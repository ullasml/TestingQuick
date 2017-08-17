//
//  BookmarkValidationRequestProvider.m
//  NextGenRepliconTimeSheet


#import "BookmarkValidationRequestProvider.h"
#import "URLStringProvider.h"
#import "PunchCardObject.h"
#import "RequestBuilder.h"

@interface BookmarkValidationRequestProvider()

@property (nonatomic) URLStringProvider *urlStringProvider;
@property (nonatomic) NSString *userUri;

@end

@implementation BookmarkValidationRequestProvider

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider {
    if(self = [super init]) {
        self.urlStringProvider = urlStringProvider;
    }
    return self;
}

- (void)setupUserUri:(NSString *)userUri {
    self.userUri = userUri;
}

- (NSURLRequest *)requestForBookmarkValidation:(NSArray *)bookmarkslist {
    NSString *urlString = [self.urlStringProvider urlStringWithEndpointName:@"BookmarkValidation"];

    NSMutableArray *cpts = [self getClientProjectTaskMapFromBookmarkList:bookmarkslist];
    NSDictionary *postBody = @{
                                @"userUri":self.userUri,
                                @"clientsProjectsTasks" : cpts
                              };

    NSData *requestBodyData = [NSJSONSerialization dataWithJSONObject:postBody options:0 error:nil];

    NSString *requestBodyString = [[NSString alloc] initWithData:requestBodyData encoding:NSUTF8StringEncoding];

    NSDictionary *parameterDictionary = @{@"URLString": urlString,
                                          @"PayLoadStr":  requestBodyString};

    NSMutableURLRequest *request = [RequestBuilder buildPOSTRequestWithParamDict:parameterDictionary];

    return request;
}

#pragma mark - Helper Methods

- (NSMutableArray *)getClientProjectTaskMapFromBookmarkList:(NSArray *)bookmarkList {

    NSMutableArray *cptArray = [[NSMutableArray alloc] initWithCapacity:1];

    for (PunchCardObject *punchCard in bookmarkList) {

        NSDictionary *clientType = [self getClient:punchCard];
        NSDictionary *projectType = [self getProject:punchCard];
        NSDictionary *taskType = [self getTask:punchCard];
        
        if (projectType && projectType!=(id)[NSNull null])
        {
            
            NSDictionary *cpt =   @{
                                    @"client": clientType,
                                    @"project": projectType,
                                    @"task": taskType
                                    };
            
            
            [cptArray addObject:cpt];
        }

    }

    return cptArray;
}

- (id)checkforNilOrEmptyAndReturnStringOrNull:(NSString *)string {
    if(!IsValidString(string)) {
        return [NSNull null];
    }
    return string;
}

- (id)getTask:(PunchCardObject *)punchCard {
    if(!IsValidString(punchCard.taskType.uri) || !IsValidString(punchCard.taskType.name)) {
        return [NSNull null];
    }

    NSDictionary *task = @{
                           @"uri": punchCard.taskType.uri,
                           @"displayText": punchCard.taskType.name
                         };

    return task;
}

- (id)getProject:(PunchCardObject *)punchCard {
    if(!IsValidString(punchCard.projectType.uri) || !IsValidString(punchCard.projectType.name)) {
        return [NSNull null];
    }

    NSDictionary *project = @{
                           @"uri": punchCard.projectType.uri,
                           @"displayText": punchCard.projectType.name
                           };

    return project;
}

- (id)getClient:(PunchCardObject *)punchCard {
    if(!IsValidString(punchCard.clientType.uri) || !IsValidString(punchCard.clientType.name)) {
        return [NSNull null];
    }

    NSDictionary *client = @{
                              @"uri": punchCard.clientType.uri,
                              @"displayText": punchCard.clientType.name
                              };

    return client;
}

@end
