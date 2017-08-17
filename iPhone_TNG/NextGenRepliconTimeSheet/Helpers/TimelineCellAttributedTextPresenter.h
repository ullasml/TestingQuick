
#import <Foundation/Foundation.h>

@interface TimelineCellAttributedTextPresenter : NSObject
+(NSMutableAttributedString *)attributedTextForText:(NSString *)completelyAppendedString
                                withHighlightedText:(NSString *)highlightedText
                                    highligthedFont:(UIFont *)highlightedFont
                                        defaultFont:(UIFont *)defaultFont
                                          textColor:(UIColor *)textColor;
@end
