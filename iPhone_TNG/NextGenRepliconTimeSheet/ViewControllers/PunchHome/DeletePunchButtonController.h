#import <UIKit/UIKit.h>
#import "DeletePunchButtonController.h"


@class ButtonStylist;
@protocol Theme ;
@protocol DeletePunchButtonControllerDelegate;


@interface DeletePunchButtonController : UIViewController

@property (nonatomic, weak, readonly) UIButton *deletePunchButton;
@property (nonatomic, readonly) ButtonStylist *buttonStylist;
@property (nonatomic, readonly) id<Theme> theme;
@property (nonatomic, weak, readonly) id <DeletePunchButtonControllerDelegate> delegate;

+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (id)initWithCoder:(NSCoder *)aDecoder UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithButtonStylist:(ButtonStylist *)buttonStylist
                                theme:(id<Theme>)theme NS_DESIGNATED_INITIALIZER;

- (void)setupWithDelegate:(id <DeletePunchButtonControllerDelegate>) delegate;

@end

@protocol DeletePunchButtonControllerDelegate <NSObject>

- (void)deletePunchButtonControllerDidSignalIntentToDeletePunch:(DeletePunchButtonController *)deletePunchButtonController;

@end
