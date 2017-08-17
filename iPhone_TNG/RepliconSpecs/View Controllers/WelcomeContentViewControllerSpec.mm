#import <Cedar/Cedar.h>
#import "WelcomeContentViewController.h"
#import "Theme.h"
#import "InjectorProvider.h"
#import <Blindside/Blindside.h>
#import "Constants.h"
#import <MediaPlayer/MediaPlayer.h>

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(WelcomeContentViewControllerSpec)

describe(@"WelcomeContentViewController", ^{
    __block WelcomeContentViewController            *subject;
    __block id <Theme>                              theme;
    __block id <BSBinder,BSInjector>                injector;
    __block NSArray                                 *pageTitles;
    __block NSArray                                 *pageDetailsText;
    __block id<WelcomeContentViewControllerDelegate> delegate;
    __block NSNotificationCenter                    *notificationCenter;
    __block MPMoviePlayerController *player1;
    __block BOOL isiPhone4;
    __block UIImage *image;

    beforeEach(^{

        isiPhone4   = ([[UIScreen mainScreen] bounds].size.height == 480)? TRUE:FALSE;
        pageDetailsText = @[RPLocalizedString(attendanceDetailsText, @""),
                             RPLocalizedString(approvalAttendanceDetailsText,@""),
                             RPLocalizedString(clientBillingDetailsText,@""),
                             RPLocalizedString(approvalClientBillingDetailsText,@"")];
        pageTitles = @[RPLocalizedString(attendanceTitle,@""), RPLocalizedString(approvalAttendanceTitle,@""), RPLocalizedString(clientBillingTitle,@""), RPLocalizedString(approvalClientBillingTitle,@"")];

        notificationCenter = [[NSNotificationCenter alloc] init];
        spy_on(notificationCenter);
        
        delegate = nice_fake_for(@protocol(WelcomeContentViewControllerDelegate));

        injector = [InjectorProvider injector];
        
        subject = [[WelcomeContentViewController alloc] initWithNotificationCenter:notificationCenter];
        [subject setUpWithPageTitle:pageTitles[0] pageDetailsText:pageDetailsText[0] pageIndex:0 delegate:delegate];
        
        theme = subject.theme;
        
        spy_on(theme);
        spy_on(subject);
        
        theme stub_method(@selector(welcomeViewSlideTitleColor)).and_return([UIColor redColor]);
        theme stub_method(@selector(welcomeViewSlideTitleFont)).and_return([UIFont systemFontOfSize:14.0f]);
        theme stub_method(@selector(welcomeViewSlideDetailColor)).and_return([UIColor greenColor]);
        theme stub_method(@selector(welcomeViewSlideDetailFont)).and_return([UIFont systemFontOfSize:12.0f]);

        image = nice_fake_for([UIImage class]);
        subject stub_method(@selector(slideImage)).and_return(image);
    });
    
    describe(@"styling", ^{
        __block MPMoviePlayerController *player;
        beforeEach(^{
            theme stub_method(@selector(welcomeViewBGColor)).and_return([UIColor whiteColor]);
            player =[[MPMoviePlayerController alloc] init];
            subject.view should_not be_nil;
        });
        
        it(@"should style the background", ^{
            subject.view.backgroundColor should equal([UIColor whiteColor]);
        });
        
        it(@"should style the data label", ^{
            subject.titleLabel.textColor should equal([UIColor redColor]);
            subject.titleLabel.font should equal([UIFont systemFontOfSize:14.0f]);
            subject.detailsLabel.textColor should equal([UIColor greenColor]);
            subject.detailsLabel.font should equal([UIFont systemFontOfSize:12.0f]);
        });

        
        it(@"should add the mediaplayer view as a subview of the topView", ^{


            if (isiPhone4)
            {
                subject.videoView.subviews.count should equal(1);
              subject.videoView.subviews.firstObject should be_instance_of([UIImageView class]);
            }
            else
            {
               subject.videoView.subviews.count should equal(2);
                subject.videoView.subviews.firstObject should be_instance_of([UIImageView class]);
              subject.videoView.subviews.lastObject should be_instance_of([player.view class]);
            }

        });

    });
    
    describe(@"first view content", ^{

        beforeEach(^{

            [subject setUpWithPageTitle:pageTitles[0] pageDetailsText:pageDetailsText[0] pageIndex:0 delegate:(id)subject];
            subject.view should_not be_nil;
        });
        
        it(@"should show first view with setup details", ^{
            subject.titleLabel.text should equal(RPLocalizedString(attendanceTitle, attendanceTitle));
            subject.detailsLabel.text should equal(RPLocalizedString(attendanceDetailsText, attendanceDetailsText));
            
        });
        
        it(@"should play video with given url", ^{
            NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"slide1" ofType:@"mp4"]];

            if (isiPhone4)
            {
                subject.player.contentURL should be_nil;
            }
            else
            {
               subject.player.contentURL should equal(url);
            }

        });

        it(@"should show correct placeholder image", ^{

            if (!isiPhone4)
            {
                subject.slideImageView.image should equal(image);
            }
        });
    });

    describe(@"second view content", ^{
        beforeEach(^{
            [subject setUpWithPageTitle:pageTitles[1] pageDetailsText:pageDetailsText[1] pageIndex:1 delegate:(id)subject];
            subject.view should_not be_nil;
        });
        
        it(@"should show first view with setup details", ^{
            subject.titleLabel.text should equal(RPLocalizedString(approvalAttendanceTitle, approvalAttendanceTitle));
            subject.detailsLabel.text should equal(RPLocalizedString(approvalAttendanceDetailsText, approvalAttendanceDetailsText));
        });
        
        it(@"should play video with given url", ^{
            NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"slide2" ofType:@"mp4"]];

            if (isiPhone4)
            {
                subject.player.contentURL should be_nil;
            }
            else
            {
                subject.player.contentURL should equal(url);
            }
        });

        it(@"should show correct placeholder image", ^{

            if (!isiPhone4)
            {
                subject.slideImageView.image should equal(image);
            }
        });

    });
    describe(@"third view content", ^{
        beforeEach(^{
            [subject setUpWithPageTitle:pageTitles[2] pageDetailsText:pageDetailsText[2] pageIndex:2 delegate:(id)subject];
            subject.view should_not be_nil;
        });
        
        it(@"should show first view with setup details", ^{
            subject.titleLabel.text should equal(RPLocalizedString(clientBillingTitle, clientBillingTitle));
            subject.detailsLabel.text should equal(RPLocalizedString(clientBillingDetailsText, clientBillingDetailsText));
        });
        
        it(@"should play video with given url", ^{
            NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"slide3" ofType:@"mp4"]];

            if (isiPhone4)
            {
                subject.player.contentURL should be_nil;
            }
            else
            {
                subject.player.contentURL should equal(url);
            }
        });

        it(@"should show correct placeholder image", ^{

            if (!isiPhone4)
            {
                subject.slideImageView.image should equal(image);
            }
        });
    });
    
    describe(@"fourth view content", ^{
        beforeEach(^{
            [subject setUpWithPageTitle:pageTitles[3] pageDetailsText:pageDetailsText[3] pageIndex:3 delegate:(id)subject];
            subject.view should_not be_nil;
        });
        
        it(@"should show first view with setup details", ^{
            subject.titleLabel.text should equal(RPLocalizedString(approvalClientBillingTitle, approvalClientBillingTitle));
            subject.detailsLabel.text should equal(RPLocalizedString(approvalClientBillingDetailsText, approvalClientBillingDetailsText));
        });
        
        it(@"should play video with given url", ^{
            NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"slide4" ofType:@"mp4"]];

            if (isiPhone4)
            {
                subject.player.contentURL should be_nil;
            }
            else
            {
                subject.player.contentURL should equal(url);
            }
        });

        it(@"should show correct placeholder image", ^{

            if (!isiPhone4)
            {
                subject.slideImageView.image should equal(image);
            }
        });
    });
    
    describe(@"<WelcomeContentViewControllerDelegate>", ^{
        beforeEach(^{
            subject.view should_not be_nil;

            if (!isiPhone4)
            {
                player1 = subject.player;
                spy_on(player1);
                player1 stub_method(@selector(playbackState)).and_return(MPMoviePlaybackStatePaused);
                [subject addObserver];
                [subject.notificationCenter postNotificationName:MPMoviePlayerPlaybackDidFinishNotification object:subject.player];
            }

        });
        
        it(@"should unsubscribe from MPMoviePlayerPlaybackDidFinishNotification", ^{
            if (isiPhone4)
            {
                subject.notificationCenter should_not have_received(@selector(removeObserver:name:object:));
            }
            else
            {
                subject.notificationCenter should have_received(@selector(removeObserver:name:object:));
            }
        });

        it(@"should call video finished method in parent class", ^{
            if (isiPhone4)
            {
                delegate should_not have_received(@selector(welcomeContentVideoDidFinished:));
            }
            else
            {
                delegate should have_received(@selector(welcomeContentVideoDidFinished:));
            }

        });
    });
});

SPEC_END
