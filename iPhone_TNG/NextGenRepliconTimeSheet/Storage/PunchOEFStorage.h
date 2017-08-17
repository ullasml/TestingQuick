//
//  PunchOEFStorage.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 9/29/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SQLiteTableStore;
@protocol Punch;
@class DoorKeeper;

@interface PunchOEFStorage : NSObject
@property (nonatomic,readonly) SQLiteTableStore *sqliteStore;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithSqliteStore:(SQLiteTableStore *)sqliteStore NS_DESIGNATED_INITIALIZER;


- (void)storePunchOEFArray:(NSArray *)oefArray forPunch:(id<Punch>)punch;
-(NSArray *)getPunchOEFTypesForRequestID:(NSString *)requestID;
- (void)deletePunchOEFWithRequestID:(NSString *)requestID;
- (void)deleteAllPunchOEF;
@end
