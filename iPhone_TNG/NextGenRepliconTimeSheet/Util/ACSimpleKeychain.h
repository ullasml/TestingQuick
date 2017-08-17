//
//  ACSimpleKeychain.h
//  ACSimpleKeychain
//
//  Created by Alex Chugunov on 2/3/11.
//  Copyright 2011 Alex Chugunov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

extern NSString *const ACKeychainPassword;
extern NSString *const ACKeychainUsername;
extern NSString *const ACKeychainCompanyName;
extern NSString *const ACKeychainService;
extern NSString *const ACKeychainExpirationDate;
extern NSString *const ACKeychainInfo;

@interface ACSimpleKeychain : NSObject {
    
}

+ (id)defaultKeychain;

// Creates new item with the provided values and deletes the old ones if those existed.
// Returns YES on success and NO on failure.
- (BOOL)storeUsername:(NSString *)username password:(NSString *)password companyName:(NSString *)companyName forService:(NSString *)service;
- (BOOL)storeUsername:(NSString *)username password:(NSString *)password companyName:(NSString *)companyName info:(NSDictionary *)info forService:(NSString *)service;

- (BOOL)storeUsername:(NSString *)username password:(NSString *)password companyName:(NSString *)companyName expirationDate:(NSDate *)expirationDate forService:(NSString *)service;


// On success returns a dictionary with the following keys:
//  ACKeychainUsername
//  ACKeychainPassword
//  ACKeychainIdentifier
//  ACKeychainService
//  ACKeychainExpirationDate
- (NSDictionary *)credentialsForCompanyName:(NSString *)companyName service:(NSString *)service;

// On success returns a dictionary with the following keys:
//  ACKeychainUsername
//  ACKeychainPassword
//  ACKeychainIdentifier
//  ACKeychainService
//  ACKeychainExpirationDate
- (NSDictionary *)credentialsForUsername:(NSString *)username service:(NSString *)service;



// On success returns an array of dictionaries with the following keys:
//  ACKeychainUsername
//  ACKeychainPassword
//  ACKeychainIdentifier
//  ACKeychainService
//  ACKeychainExpirationDate
//
// limit - the amount of entries to return. Should be > 0
- (NSArray *)allCredentialsForService:(NSString *)service limit:(NSUInteger)limit;

// Deletes credentials matching the provided identifier and service, returns YES on sucess
- (BOOL)deleteCredentialsForCompanyName:(NSString *)companyName service:(NSString *)service;

// Deletes credentials matching the provided username and service, returns YES on sucess
- (BOOL)deleteCredentialsForService:(NSString *)service;

// Deletes all entries for the given service
- (BOOL)deleteAllCredentialsForService:(NSString *)service;

@end
