//
//  URLReader.h
//  Replicon
//
//  Created by Devi Malladi on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JsonWrapper.h"
#import "G2AppProperties.h"

@protocol G2ServerResponseProtocol

@required
- (void) serverDidRespondWithResponse:(id) response;
- (void) serverDidFailWithError:(NSError *) error;

@optional
- (void) serverDidRespondWithNonJSONResponse:(id)response;
- (void) serverDidRespondWithDownloadCancelled:(id)response;

@end

@interface G2URLReader : NSObject {
	
	NSMutableData *recievedData;
	//NSMutableString *receivedDataStr;
	id __weak delegate;
	NSString *urlStr;
	NSURLConnection *urlConnection;
	//NSString *userName;
	//NSString *password;
    //NSString *companyName;
	NSNumber *refID;
	
	//NSString *dbRefId;
	NSDictionary *refDict;
	
	int timeOutValue;
	long startTime;
	
}
- (id) initWithRequest:(NSMutableURLRequest *)request delegate:(id<G2ServerResponseProtocol>) theDelegate;
- (void) start;
- (void) errorAlert :(NSString *) title	 errorMessage:(NSString*) errorMessage;
-(void)handleCookiesResponse:(id)response;
- (void) cancelRequest;
-(void)startSynchronusRequest :(NSMutableURLRequest *)request;
-(void)handleResponseToShowErrorMessages:(id)message;
-(void)startRequestWithTimeOutVal:(int)timeOutVal;
-(BOOL)handleExceptionsWithExceptionTypes:(id)responseInfo;

@property int timeOutValue;
@property long startTime;
//@property (nonatomic, retain) NSMutableData *recievedData;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSString *urlStr;
//@property (nonatomic, retain) NSString *dbRefId;
//@property (nonatomic, retain) NSString *userName;
//@property (nonatomic, retain) NSString *password;
//@property (nonatomic, retain) NSString *companyName;
@property (nonatomic, strong) NSNumber *refID;
@property (nonatomic,strong)NSDictionary *refDict;
@end
