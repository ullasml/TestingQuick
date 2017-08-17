//
//  UIViewController+OEFValuePopulation.h
//  NextGenRepliconTimeSheet
//
//  Created by Prakashini Pattabiraman on 07/12/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enum.h"
#import <Blindside/Blindside.h>

@class OEFType;

@interface UIViewController (OEFValuePopulation)

- (NSString *)getPlaceholderTextByOEFType:(OEFType *)oefType screenType:(PunchAttributeScreentype)screenType;
- (OEFType *)getUpdatedOEFTypeFromOEFTypeObject:(OEFType *)oefType textView:(UITextView *)textView;
- (NSError *)validateOEFType:(OEFType *)oefType injector:(id <BSInjector>)injector;

@end
