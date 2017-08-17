//
//  BookmarkValidationRequestProvider.h
//  NextGenRepliconTimeSheet
//
//  Created by Prakashini Pattabiraman on 04/03/17.
//  Copyright © 2017 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "URLStringProvider.h"


@interface BookmarkValidationRequestProvider : NSObject

@property (nonatomic, readonly) URLStringProvider *urlStringProvider;

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider;
- (NSURLRequest *)requestForBookmarkValidation:(NSArray *)bookmarkslist;
- (void)setupUserUri:(NSString *)userUri;

@end
