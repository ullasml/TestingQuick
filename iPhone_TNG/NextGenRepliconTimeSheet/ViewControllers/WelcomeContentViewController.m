
#import "WelcomeContentViewController.h"
#import "Theme.h"

@interface WelcomeContentViewController ()

@property (weak, nonatomic) IBOutlet UILabel     *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel     *detailsLabel;
@property (weak, nonatomic) IBOutlet UIView      *videoView;
@property (weak, nonatomic) IBOutlet UIImageView *slideImageView;
@property (weak, nonatomic) IBOutlet UIView      *bottomView;
@property (nonatomic) NSNotificationCenter       *notificationCenter;
@property (copy, nonatomic) NSString             *pageTitle;
@property (copy, nonatomic) NSString             *pageDetailsText;
@property (assign,nonatomic) NSUInteger          pageIndex;
@property (nonatomic) MPMoviePlayerController    *player;
@property (weak, nonatomic) id<WelcomeContentViewControllerDelegate> delegate;
@property (nonatomic) UIImage *slideImage;


@end

@implementation WelcomeContentViewController

- (instancetype)initWithNotificationCenter:(NSNotificationCenter *)notificationCenter
{
    self = [super initWithNibName:nil bundle:nil];
    if (self)
    {
        self.notificationCenter = notificationCenter;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.titleLabel setTextColor:[self.theme welcomeViewSlideTitleColor]];
    [self.titleLabel setFont:[self.theme welcomeViewSlideTitleFont]];
    [self.detailsLabel setTextColor:[self.theme welcomeViewSlideDetailColor]];
    [self.detailsLabel setFont:[self.theme welcomeViewSlideDetailFont]];
    self.titleLabel.text = [NSString stringWithFormat:@"%@",RPLocalizedString(self.pageTitle, @"")];
    self.detailsLabel.text = [NSString stringWithFormat:@"%@",RPLocalizedString(self.pageDetailsText, @"")];
    [self addVideoView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
}


-(void)setUpWithPageTitle:(NSString*)pageTitle pageDetailsText:(NSString*)pageDetailsText pageIndex:(NSUInteger)pageIndex delegate:(id<WelcomeContentViewControllerDelegate>)delegate{
    self.pageTitle = pageTitle;
    self.pageDetailsText = pageDetailsText;
    self.pageIndex = pageIndex;
    self.delegate = delegate;
}

-(void)addVideoView{
    BOOL isiPhone4   = ([[UIScreen mainScreen] bounds].size.height == 480)? TRUE:FALSE;
    if (isiPhone4) {
        NSString *fileName = [NSString stringWithFormat:@"slide%lu.png",self.pageIndex+1];
        self.slideImage = [UIImage imageNamed:fileName];
        [self.slideImageView setImage:self.slideImage];
    }
    else{
        NSString *fileName = [NSString stringWithFormat:@"slide%lu",self.pageIndex+1];
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"mp4"]];
        if (self.player == nil) {

            NSString *fileName = [NSString stringWithFormat:@"slide_placeholder_%lu.jpg",self.pageIndex+1];
            self.slideImage = [UIImage imageNamed:fileName];
            [self.slideImageView setImage:self.slideImage];

            self.player = [[MPMoviePlayerController alloc] initWithContentURL:url];
            [self.player setRepeatMode:(MPMovieRepeatModeNone)];
            [self.player.view setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self.player setControlStyle:MPMovieControlStyleNone];
            [self.player setMovieSourceType:(MPMovieSourceTypeFile)];
            [self.player.view setBackgroundColor:[UIColor clearColor]];
            [self.player.backgroundView setBackgroundColor:[UIColor clearColor]];
            for(UIView *playerSubView in self.player.view.subviews) {
                playerSubView.backgroundColor = [UIColor clearColor];
            }
            [self.player setScalingMode:MPMovieScalingModeFill];
            [self.videoView addSubview:self.player.view];
            
            id views = @{ @"player": self.player.view };
            
            [self.videoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[player]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:views]];
            
            [self.videoView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[player]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:views]];

        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - MPMoviePlayerController Methods

- (void) playVideo
{
    [self performSelector:@selector(play) withObject:nil afterDelay:2];
}

-(void)play
{
    if (self.player){
        [self.player stop];
        [self.player play];
        [self addObserver];
    }
}

- (void) stopVideo {
    [self removeObserver];
    if (self.player){
        [self.player stop];
    }
}


-(void)playbackFinished:(NSNotification*)notification
{
    BOOL playbackEnded = ([[[notification userInfo] valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue] == MPMovieFinishReasonPlaybackEnded);
    BOOL finished = (self.player.playbackState == MPMoviePlaybackStatePaused);
    
    if (playbackEnded && finished) {
        // Movie Ended
        [self removeObserver];
        [self.delegate welcomeContentVideoDidFinished:self];
    }
}

#pragma mark - Oberver Methods

-(void)addObserver
{
    [self removeObserver];
    [self.notificationCenter addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
}

-(void)removeObserver
{
    [self.notificationCenter removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
