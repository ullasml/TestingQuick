//
//  ProjectBillingType.h
//  NextGenRepliconTimeSheet
//
//  Created by Prakashini Pattabiraman on 15/12/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProjectBillingType : NSObject <NSCoding, NSCopying>

@property (nonatomic, readonly, copy) NSString *displayText;
@property (nonatomic, readonly, copy) NSString *projectBillingTypeUri;

- (instancetype)initWithUri:(NSString *)uri displayText:(NSString *)displayText;

@end
