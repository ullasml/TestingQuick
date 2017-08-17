//
//  OEFObject.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta Rakshit on 9/10/15.
//  Copyright (c) 2015 Replicon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OEFObject : NSObject


@property (nonatomic,strong)    NSString    *oefUri;
@property (nonatomic,strong)    NSString    *oefDefinitionTypeUri;
@property (nonatomic,strong)	NSString    *oefName;
@property (nonatomic,strong)	NSString    *oefLevelType;
@property (nonatomic,strong)	NSString    *oefNumericValue;
@property (nonatomic,strong)	NSString    *oefTextValue;
@property (nonatomic,strong)	NSString    *oefDropdownOptionUri;
@property (nonatomic,strong)	NSString    *oefDropdownOptionValue;

@end
