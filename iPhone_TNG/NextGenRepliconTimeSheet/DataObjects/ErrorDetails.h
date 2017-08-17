//
//  ErrorDetails.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 5/11/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ErrorDetails : NSObject <NSCoding, NSCopying>
@property (nonatomic, readonly) NSString * uri;
@property (nonatomic, readonly) NSString * errorMessage;
@property (nonatomic, readonly) NSString *errorDate;
@property (nonatomic, readonly) NSString *moduleName;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary NS_UNAVAILABLE;

- (instancetype)initWithUri:(NSString *)uri errorMessage:(NSString *)errorMessage errorDate:(NSString *)errorDate moduleName:(NSString *)moduleName;

@end
