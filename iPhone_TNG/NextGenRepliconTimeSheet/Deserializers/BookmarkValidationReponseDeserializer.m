//
//  BookmarkValidationReponseDeserializer.m
//  NextGenRepliconTimeSheet


#import "BookmarkValidationReponseDeserializer.h"
#import "PunchCardObject.h"
#import "ClientType.h"
#import "ProjectType.h"
#import "TaskType.h"
#import "ClientDeserializer.h"
#import "ProjectDeserializer.h"
#import "TaskDeserializer.h"

@implementation BookmarkValidationReponseDeserializer

- (NSArray *)deserializeValidBookmark:(NSArray *)validBookMarksjsonArray {
    
    NSMutableArray *validBookmarksArray = [[NSMutableArray alloc] initWithCapacity:1];
    for (NSDictionary *cpt in validBookMarksjsonArray) {
        
        if ([cpt respondsToSelector:@selector(objectForKey:)])
        {
            NSDictionary *clientMap = [cpt objectForKey:@"client"];
            NSDictionary *projectMap = [cpt objectForKey:@"project"];
            NSDictionary *taskMap = [cpt objectForKey:@"task"];
            
            NSDictionary *cptMap = @{
                                     @"client": @{
                                             @"uri" :[self getValidString:clientMap[@"uri"]],
                                             @"name":[self getValidString:clientMap[@"name"]]
                                             },
                                     @"project":@{
                                             @"uri" :[self getValidString:projectMap[@"uri"]],
                                             @"name":[self getValidString:projectMap[@"name"]]
                                             },
                                     @"task" : @{
                                             @"uri" :[self getValidString:taskMap[@"uri"]],
                                             @"name":[self getValidString:taskMap[@"displayText"]]
                                             }
                                     };
            
            [validBookmarksArray addObject:cptMap];
        }

    }

    return validBookmarksArray;
}

#pragma mark - Private method

- (id)getValidString:(NSString *)string {
    if(!IsValidString(string)) {
        return [NSNull null];
    }
    return string;
}


@end
