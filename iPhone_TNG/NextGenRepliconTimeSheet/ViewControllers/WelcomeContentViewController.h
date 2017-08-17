
#import <UIKit/UIKit.h>
#import "RepliconBaseController.h"
#import <MediaPlayer/MediaPlayer.h>

@protocol WelcomeContentViewControllerDelegate;


@interface WelcomeContentViewController : RepliconBaseController

@property (weak, nonatomic,readonly)UILabel             *titleLabel;
@property (weak, nonatomic,readonly)UILabel             *detailsLabel;
@property (weak, nonatomic,readonly)UIView              *videoView;
@property (weak, nonatomic,readonly)UIView              *bottomView;
@property (nonatomic,readonly) MPMoviePlayerController  *player;
@property (nonatomic,assign,readonly) NSUInteger        pageIndex;
@property (nonatomic, readonly) NSNotificationCenter    *notificationCenter;
@property (weak, nonatomic, readonly) id<WelcomeContentViewControllerDelegate>delegate;
@property (nonatomic, readonly) UIImage *slideImage;
@property (weak, nonatomic, readonly)  UIImageView *slideImageView;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter
 NS_DESIGNATED_INITIALIZER;


-(void)setUpWithPageTitle:(NSString*)pageTitle pageDetailsText:(NSString*)pageDetailsText pageIndex:(NSUInteger)pageIndex delegate:(id<WelcomeContentViewControllerDelegate>)delegate;
- (void)playVideo;
- (void)stopVideo;
- (void)addObserver;
-(void)removeObserver;
@end

@protocol WelcomeContentViewControllerDelegate <NSObject>

- (void)welcomeContentVideoDidFinished:(WelcomeContentViewController *)welcomeContentViewController;


@end
