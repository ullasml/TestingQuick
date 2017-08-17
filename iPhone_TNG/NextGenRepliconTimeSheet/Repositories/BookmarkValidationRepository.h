//
//  BookmarkValidationRepository.h
//  NextGenRepliconTimeSheet

#import <Foundation/Foundation.h>

@class BookmarkValidationRepository;
@class BookmarkValidationRequestProvider;
@class BookmarkValidationReponseDeserializer;
@class PunchCardStorage;
@class KSPromise;
@class JSONClient;

@protocol UserSession;


@interface BookmarkValidationRepository : NSObject

@property (nonatomic, readonly) BookmarkValidationReponseDeserializer *deserializer;
@property (nonatomic, readonly) BookmarkValidationRequestProvider *requestProvider;
@property (nonatomic, readonly) PunchCardStorage *bookmarkStorage;

@property (nonatomic, readonly) JSONClient *client;
@property (nonatomic, readonly) id <UserSession>userSession;

- (instancetype)initWithRequestProvider:(BookmarkValidationRequestProvider *)requestProvider
                           deserializer:(BookmarkValidationReponseDeserializer *)deserializer
                        bookmarkStorage:(PunchCardStorage *)bookmarkStorage
                                 client:(JSONClient *)client
                            userSession:(id<UserSession>) userSession;

- (KSPromise *)validateBookmarks;

@end
