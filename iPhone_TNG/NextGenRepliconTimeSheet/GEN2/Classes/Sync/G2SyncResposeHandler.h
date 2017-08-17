//
//  SyncResposeHandler.h
//  Replicon
//
//  Created by vijaysai on 10/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "G2ExpensesModel.h"
#import "G2RepliconServiceManager.h"
#import "G2Constants.h"
#import "FrameworkImport.h"

@interface G2SyncResposeHandler : NSObject<G2ServerResponseProtocol,NetworkServiceProtocol> {

}

-(void)showErrorAlert:(NSError *) error;
@end
