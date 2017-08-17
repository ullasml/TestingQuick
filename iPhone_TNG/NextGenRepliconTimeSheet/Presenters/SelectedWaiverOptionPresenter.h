#import <Foundation/Foundation.h>


@class WaiverOption;


@interface SelectedWaiverOptionPresenter : NSObject

- (NSString *)displayTextFromSelectedWaiverOption:(WaiverOption *)waiverOption;

@end