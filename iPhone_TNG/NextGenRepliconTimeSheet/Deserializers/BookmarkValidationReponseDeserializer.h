//
//  BookmarkValidationReponseDeserializer.h
//  NextGenRepliconTimeSheet

#import <Foundation/Foundation.h>

@interface BookmarkValidationReponseDeserializer : NSObject

- (NSMutableArray *)deserializeValidBookmark:(NSArray *)validBookMarksjsonArray;

@end
