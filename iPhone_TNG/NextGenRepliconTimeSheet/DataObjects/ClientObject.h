//
//  ClientObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Ullas ML on 07/02/13.
//  Copyright (c) 2013 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientObject : NSObject
{
    NSString *clientName;
    NSString *clientUri;
    NSString *clientCode;
    
}
@property (nonatomic,strong)NSString *clientName;
@property (nonatomic,strong)NSString *clientUri;
@property (nonatomic,strong)NSString *clientCode;
@end
