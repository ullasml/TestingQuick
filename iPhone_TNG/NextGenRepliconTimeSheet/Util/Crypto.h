//
//  Crypto.h
//  Untitled
//
//  Created by Hepciba on 5/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>

@interface Crypto : NSObject {
	NSData *symmetricKey;

}
+(Crypto *)sharedInstance;
- (NSString*)encryptString:(NSString*)string;
- (NSString*)decryptString:(NSString*)string;

@end
