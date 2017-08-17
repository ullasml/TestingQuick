#import "SelectedWaiverOptionPresenter.h"
#import "WaiverOption.h"


@implementation SelectedWaiverOptionPresenter

- (NSString *)displayTextFromSelectedWaiverOption:(WaiverOption *)waiverOption {
    if (waiverOption) {
        return waiverOption.displayText;
    }

    return RPLocalizedString(@"No Response", nil);
}

@end
