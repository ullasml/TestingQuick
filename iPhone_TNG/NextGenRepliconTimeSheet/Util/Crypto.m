	//
	//  Crypto.m
	//  Untitled
	//
	//  Created by Hepciba on 5/12/11.
	//  Copyright 2011 __MyCompanyName__. All rights reserved.
	//

#import "Crypto.h"
#define LOGGING_FACILITY(X, Y)	\
if(!(X)) {			\
DLog(Y);		\
}					

#define LOGGING_FACILITY1(X, Y, Z)	\
if(!(X)) {				\
DLog(Y, Z);		\
}
@interface Crypto(Private)
- (NSData *)doCipher:(NSData *)plainText key:(NSData *)theSymmetricKey context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7;
- (NSString *)base64EncodeData:(NSData*)dataToConvert;
- (NSData*)base64DecodeString:(NSString *)string;
@end

@implementation Crypto
static Crypto *MyCryptoHelper = nil;

	//const uint8_t kKeyBytes[] = "abcdefgh0123456"; // Must be 16 bytes//Commented by :Swapna
const uint8_t kKeyBytes[] = "acegikmo0246802"; 
static CCOptions pad = 0;
static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

- (NSString*)encryptString:(NSString*)string
{
	NSRange fullRange;
    if (string!=nil && ![string isKindOfClass:[NSNull class]]) 
    {
        fullRange.length = [string length];
        fullRange.location = 0;
        
        uint8_t buffer[[string length]];
        
        [string getBytes:&buffer maxLength:[string length] usedLength:NULL encoding:NSUTF8StringEncoding options:0 range:fullRange remainingRange:NULL];
        
        NSData *plainText = [NSData dataWithBytes:buffer length:[string length]];
        
        NSData *encryptedResponse = [self doCipher:plainText key:symmetricKey context:kCCEncrypt padding:&pad];
        
        return [self base64EncodeData:encryptedResponse];
    }
	else
    {
        return nil;
    }

}

- (NSString*)decryptString:(NSString*)string
{
	if (!pad) {
		pad = kCCOptionPKCS7Padding;
	}
	NSData *decryptedResponse = [self doCipher:[self base64DecodeString:string] key:symmetricKey context:kCCDecrypt padding:&pad];
		//return [NSString stringWithCString:[decryptedResponse bytes] length:[decryptedResponse length]];//stringWithUTF8String//Commented to remove warning due to deprecated method
    
    if ([decryptedResponse bytes]!=nil)
    {
        return [NSString stringWithUTF8String:[decryptedResponse bytes] ];//stringWithUTF8String
        //return [NSString stringWithCString:[decryptedResponse bytes] encoding:NSUTF8StringEncoding];
        //return [NSString stringWithCString:[decryptedResponse bytes] length:[decryptedResponse length]];
    }
    else
    {
        return nil;
    }
}
- (NSData *)doCipher:(NSData *)plainText key:(NSData *)theSymmetricKey context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7
{
	CCCryptorStatus ccStatus = kCCSuccess;
		// Symmetric crypto reference.
	CCCryptorRef thisEncipher = NULL;
		// Cipher Text container.
	NSData * cipherOrPlainText = nil;
		// Pointer to output buffer.
	uint8_t * bufferPtr = NULL;
		// Total size of the buffer.
	size_t bufferPtrSize = 0;
		// Remaining bytes to be performed on.
	size_t remainingBytes = 0;
		// Number of bytes moved to buffer.
	size_t movedBytes = 0;
		// Length of plainText buffer.
	size_t plainTextBufferSize = 0;
		// Placeholder for total written.
	size_t totalBytesWritten = 0;
		// A friendly helper pointer.
	uint8_t * ptr;
	
		// Initialization vector; dummy in this case 0's.
	uint8_t iv[kCCBlockSizeAES128];
	memset((void *) iv, 0x0, (size_t) sizeof(iv));
	
	LOGGING_FACILITY(plainText != nil, @"PlainText object cannot be nil." );
	LOGGING_FACILITY(theSymmetricKey != nil, @"Symmetric key object cannot be nil." );
	LOGGING_FACILITY(pkcs7 != NULL, @"CCOptions * pkcs7 cannot be NULL." );
	LOGGING_FACILITY([theSymmetricKey length] == kCCKeySizeAES128, @"Disjoint choices for key size." );
	
    if (plainText!=nil && ![plainText isKindOfClass:[NSNull class]])
    {
        plainTextBufferSize = [plainText length];
    }
	
	
	LOGGING_FACILITY(plainTextBufferSize > 0, @"Empty plaintext passed in." );
	
		// We don't want to toss padding on if we don't need to
	if(encryptOrDecrypt == kCCEncrypt)
	{
		if(*pkcs7 != kCCOptionECBMode)
		{
			if((plainTextBufferSize % kCCBlockSizeAES128) == 0)
			{
				*pkcs7 = 0x0000;
			}
			else
			{
				*pkcs7 = kCCOptionPKCS7Padding;
			}
		}
	}
	else if(encryptOrDecrypt != kCCDecrypt)
	{
		LOGGING_FACILITY1( 0, @"Invalid CCOperation parameter [%d] for cipher context.", *pkcs7 );
	} 
	
		// Create and Initialize the crypto reference.
	ccStatus = CCCryptorCreate(	encryptOrDecrypt, 
							   kCCAlgorithmAES128, 
							   *pkcs7, 
							   (const void *)[theSymmetricKey bytes], 
							   kCCKeySizeAES128, 
							   (const void *)iv, 
							   &thisEncipher
							   );
	
	LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem creating the context, ccStatus == %d.", ccStatus );
	
		// Calculate byte block alignment for all calls through to and including final.
	bufferPtrSize = CCCryptorGetOutputLength(thisEncipher, plainTextBufferSize, true);
	
		// Allocate buffer.
	bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t) );
	
		// Zero out buffer.
	memset((void *)bufferPtr, 0x0, bufferPtrSize);
	
		// Initialize some necessary book keeping.
	
	ptr = bufferPtr;
	
		// Set up initial size.
	remainingBytes = bufferPtrSize;
	
		// Actually perform the encryption or decryption.
	ccStatus = CCCryptorUpdate( thisEncipher,
							   (const void *) [plainText bytes],
							   plainTextBufferSize,
							   ptr,
							   remainingBytes,
							   &movedBytes
							   );
	
	LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem with CCCryptorUpdate, ccStatus == %d.", ccStatus );
	
		// Handle book keeping.
	ptr += movedBytes;
	remainingBytes -= movedBytes;
	totalBytesWritten += movedBytes;
	
		// Finalize everything to the output buffer.
	ccStatus = CCCryptorFinal(	thisEncipher,
							  ptr,
							  remainingBytes,
							  &movedBytes
							  );
	
	totalBytesWritten += movedBytes;
	
	if(thisEncipher)
	{
		(void) CCCryptorRelease(thisEncipher);
		thisEncipher = NULL;
	}
	
	LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem with encipherment ccStatus == %d", ccStatus );
	
	cipherOrPlainText = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)totalBytesWritten];
	
	if(bufferPtr) free(bufferPtr);
	
	return cipherOrPlainText;
}
#pragma mark -
#pragma mark Base64 Encode/Decoder
- (NSString *)base64EncodeData:(NSData*)dataToConvert
{
    
    if (dataToConvert!=nil && ![dataToConvert isKindOfClass:[NSNull class]])
    {
        if ([dataToConvert length] == 0)
            return @"";
        
      char *characters = malloc((([dataToConvert length] + 2) / 3) * 4);
        
        if (characters == NULL)
            return nil;
        
        NSUInteger length = 0;
        
        NSUInteger i = 0;
        while (i < [dataToConvert length])
        {
            char buffer[3] = {0,0,0};
            short bufferLength = 0;
            while (bufferLength < 3 && i < [dataToConvert length])
                buffer[bufferLength++] = ((char *)[dataToConvert bytes])[i++];
            
			//  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
            characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
            characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
            if (bufferLength > 1)
                characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
            else characters[length++] = '=';
            if (bufferLength > 2)
                characters[length++] = encodingTable[buffer[2] & 0x3F];
            else characters[length++] = '=';	
        }
        
        return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
    }
	
    
    else
    {
        return nil;
    }
    
	
}

- (NSData*)base64DecodeString:(NSString *)string
{
    if (string!=nil && ![string isKindOfClass:[NSNull class]])
    {
        if (string ==nil)
			//[NSException raise:NSInvalidArgumentException format:nil];//Commented due to warning,for not supporting nil format
            [NSException raise:NSInvalidArgumentException format:@""];
        
        if ([string length] == 0)
            return [NSData data];
        
        static char *decodingTable = NULL;
        if (decodingTable == NULL)
        {
            decodingTable = malloc(256);
            if (decodingTable == NULL)
                return nil;
            memset(decodingTable, CHAR_MAX, 256);
            NSUInteger i;
            for (i = 0; i < 64; i++)
                decodingTable[(short)encodingTable[i]] = i;
        }
        
        const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
        if (characters == NULL)     //  Not an ASCII string!
            return nil;
        char *bytes = malloc((([string length] + 3) / 4) * 3);
        if (bytes == NULL)
            return nil;
        NSUInteger length = 0;
        
        NSUInteger i = 0;
        while (YES)
        {
            char buffer[4];
            short bufferLength;
            for (bufferLength = 0; bufferLength < 4; i++)
            {
                if (characters[i] == '\0')
                    break;
                if (isspace(characters[i]) || characters[i] == '=')
                    continue;
                buffer[bufferLength] = decodingTable[(short)characters[i]];
                if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
                {
                    free(bytes);
                    return nil;
                }
            }
            
            if (bufferLength == 0)
                break;
            if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
            {
                free(bytes);
                return nil;
            }
            
			//  Decode the characters in the buffer to bytes.
            bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
            if (bufferLength > 2)
                bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
            if (bufferLength > 3)
                bytes[length++] = (buffer[2] << 6) | buffer[3];
        }
        
        bytes = realloc(bytes, length);
        
        return [NSData dataWithBytesNoCopy:bytes length:length];
    }
    
    else
    {
        return nil;
    }
}
#pragma mark -
#pragma mark Singleton methods
- (id)init
{
	if(self = [super init])
	{
		symmetricKey = [NSData dataWithBytes:kKeyBytes length:sizeof(kKeyBytes)];
	}
	return self;
}

+ (Crypto*)sharedInstance
{
    @synchronized(self)
	{
        if (MyCryptoHelper == nil)
		{
           MyCryptoHelper= [[self alloc] init];
        }
    }
    return MyCryptoHelper;
}
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
	{
        if (MyCryptoHelper == nil)
		{
            MyCryptoHelper = [super allocWithZone:zone];
            return MyCryptoHelper;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}



- (unsigned)count
{
    return UINT_MAX;  // denotes an object that cannot be released
}

//- (void)release
//{
//		//do nothing
//}


@end
