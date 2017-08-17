//
//  URLReader.h
//  Replicon
//
//  Created by Devi Malladi on 2/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JsonWrapper.h"
#import "AppProperties.h"

@protocol ServerResponseProtocol

@required
- (void) serverDidRespondWithResponse:(id) response;
- (void) serverDidFailWithError:(NSError *) error applicationState:(ApplicateState)applicationState;

@optional
- (void) serverDidRespondWithNonJSONResponse:(id)response;
- (void) serverDidRespondWithDownloadCancelled:(id)response;

@end

@interface URLReader : NSObject
{
	
    id<ServerResponseProtocol>__weak delegate;
	NSMutableData *recievedData;
	NSURLConnection *urlConnection;
    NSNumber *refID;
    NSString *urlStr;
	NSDictionary *refDict;
	int timeOutValue;
	long startTime;
	
}
-(id) initWithRequest:(NSMutableURLRequest *)request delegate:(id<ServerResponseProtocol>) theDelegate;
-(void)start;
-(void)errorAlert :(NSString *) title	 errorMessage:(NSString*) errorMessage;
-(void)handleCookiesResponse:(id)response;
-(void)cancelRequest;
-(void)startSynchronusRequest :(NSMutableURLRequest *)request;
-(void)handleResponseToShowErrorMessages:(id)message;
-(void)startRequestWithTimeOutVal:(int)timeOutVal;
-(BOOL)checkForExceptions:(NSDictionary *)response;

@property int timeOutValue;
@property long startTime;
@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSString *urlStr;
@property (nonatomic, strong) NSNumber *refID;
@property (nonatomic,strong)NSDictionary *refDict;
@property (nonatomic,assign)NSInteger testCode;;

-(BOOL)validateForFailureURIWithURI:(NSString *)errorURI forErrorDict:(NSDictionary *)responseDictionary;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response;

@end
