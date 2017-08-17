//
//  BookmarkValidationRepository.m
//  NextGenRepliconTimeSheet


#import "BookmarkValidationRepository.h"
#import "URLStringProvider.h"
#import "BookmarkValidationRequestProvider.h"
#import "BookmarkValidationReponseDeserializer.h"
#import "PunchCardStorage.h"
#import <KSDeferred/KSDeferred.h>
#import "JSONClient.h"
#import "UserSession.h"

@interface BookmarkValidationRepository()

@property (nonatomic) BookmarkValidationReponseDeserializer *deserializer;
@property (nonatomic) BookmarkValidationRequestProvider *requestProvider;
@property (nonatomic) PunchCardStorage *bookmarkStorage;
@property (nonatomic) JSONClient *client;
@property (nonatomic) id <UserSession>userSession;

@end

@implementation BookmarkValidationRepository

- (instancetype)initWithRequestProvider:(BookmarkValidationRequestProvider *)requestProvider
                           deserializer:(BookmarkValidationReponseDeserializer *)deserializer
                        bookmarkStorage:(PunchCardStorage *)bookmarkStorage
                                 client:(JSONClient *)client
                            userSession:(id<UserSession>) userSession {

    if(self  = [super init]) {
        self.bookmarkStorage = bookmarkStorage;
        self.deserializer = deserializer;
        self.requestProvider = requestProvider;
        self.client = client;
        self.userSession = userSession;

    }
    return self;
}

#pragma mark - Public Methods

- (KSPromise *)validateBookmarks {
    NSArray *bookmarks = [self.bookmarkStorage getPunchCards];

    [self.requestProvider setupUserUri:[self.userSession currentUserURI]];
    NSURLRequest *request = [self.requestProvider requestForBookmarkValidation:bookmarks];
    KSPromise *promise = [self.client promiseWithRequest:request];
    return [promise then:^id(NSArray *validBookMarks) {
        if(validBookMarks != nil) {
            NSArray *validBookmarks_ = [self.deserializer deserializeValidBookmark:validBookMarks];
            return validBookmarks_;
        }
        return nil;
    } error:^id(NSError *error) {
        return error;
    }];
}

@end
