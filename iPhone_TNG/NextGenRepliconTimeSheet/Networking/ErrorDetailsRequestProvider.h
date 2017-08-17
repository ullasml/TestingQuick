//
//  ErrorDetailsRequestProvider.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 6/2/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
@class URLStringProvider;
@class DateProvider;

@interface ErrorDetailsRequestProvider : NSObject

@property (nonatomic,readonly) URLStringProvider *urlStringProvider;
@property (nonatomic,readonly) DateProvider *dateProvider;
@property (nonatomic, readonly) NSUserDefaults *userDefaults;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithURLStringProvider:(URLStringProvider *)urlStringProvider dateProvider:(DateProvider *)dateProvider defaults:(NSUserDefaults *)userDefaults NS_DESIGNATED_INITIALIZER;

- (NSURLRequest *)requestForValidationErrorsWithURI:(NSArray *)uris;

- (NSURLRequest *)requestForTimeSheetUpdateDataForUserUri:(NSString *)strUserURI;

@end
