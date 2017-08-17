//
//  ErrorDetailsDeserializer.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 5/12/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DateProvider.h"


@class TimesheetModel;

@interface ErrorDetailsDeserializer : NSObject

@property (nonatomic,readonly) DateProvider *dateProvider;
@property (nonatomic,readonly) NSDateFormatter *dateFormatter;
@property (nonatomic,readonly) TimesheetModel *timeSheetModel;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithDateProvider:(DateProvider *)dateProvider
                       dateFormatter:(NSDateFormatter *)dateFormatter timeSheetModel:(TimesheetModel *) timeSheetModel NS_DESIGNATED_INITIALIZER;

-(NSArray *)deserialize:(NSDictionary *)jsonDictionary;
-(NSArray *)deserializeValidationServiceResponse:(NSDictionary *)jsonDictionary;
-(NSMutableArray *)deserializeTimeSheetUpdateData:(NSDictionary *)jsonDictionary;
@end
