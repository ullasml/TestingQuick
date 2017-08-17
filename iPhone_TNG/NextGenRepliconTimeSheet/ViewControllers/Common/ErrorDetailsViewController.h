//
//  ErrorDetailsViewController.h
//  NextGenRepliconTimeSheet
//
//  Created by Dipta on 6/1/16.
//  Copyright © 2016 Replicon. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol Theme;
@class ErrorDetailsDeserializer;
@class ErrorDetailsStorage;
@class ErrorBannerViewController;
@class ErrorDetailsRepository;

@interface ErrorDetailsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic, readonly) UITableView *tableView;

@property (nonatomic, readonly)  id<Theme> theme;
@property (nonatomic, readonly) NSNotificationCenter *notificationCenter;
@property (nonatomic, readonly) ErrorDetailsDeserializer *errorDetailsDeserializer;
@property (nonatomic, readonly) ErrorDetailsStorage *errorDetailsStorage;
@property (nonatomic, readonly) ErrorBannerViewController *errorBannerViewController;
@property (nonatomic, readonly) ErrorDetailsRepository *errorDetailsRepository;
@property (nonatomic, readonly) NSArray *tableRows;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary  UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTheme:(id <Theme>)theme
           notificationCenter:(NSNotificationCenter *)notificationCenter
     errorDetailsDeserializer:(ErrorDetailsDeserializer *)errorDetailsDeserializer
          errorDetailsStorage:(ErrorDetailsStorage *)errorDetailsStorage
    errorBannerViewController:(ErrorBannerViewController *)errorBannerViewController
                 errorDetailsRepository:(ErrorDetailsRepository *)errorDetailsRepository;

@end
