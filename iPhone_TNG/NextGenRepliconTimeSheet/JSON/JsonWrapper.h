//
//  JsonWrapper.h
//  Pictage
//
//  Created by HemaBindu on 4/20/10.
//  Copyright 2010 EnLume. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SBJson.h"


@interface JsonWrapper : NSObject {

}

+ (id) parseJson:(id)receivedData error:(NSError **)error;
+ (id) writeJson:(id)jsonObj error:(NSError **)error;

@end
