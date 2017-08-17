
#import "TimelineCellAttributedTextPresenter.h"

@implementation TimelineCellAttributedTextPresenter

+(NSMutableAttributedString *)attributedTextForText:(NSString *)completelyAppendedString
                                withHighlightedText:(NSString *)highlightedText
                                    highligthedFont:(UIFont *)highlightedFont
                                        defaultFont:(UIFont *)defaultFont
                                          textColor:(UIColor *)textColor
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:highlightedText options:0 error:nil];
    NSTextCheckingResult *match = [regex firstMatchInString:completelyAppendedString options:0 range: NSMakeRange(0, [completelyAppendedString length])];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:completelyAppendedString];
    NSRange range = NSMakeRange(0,completelyAppendedString.length);
    [regex enumerateMatchesInString:completelyAppendedString options:kNilOptions range:range usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:textColor range:NSMakeRange(0, [completelyAppendedString length])];
        [mutableAttributedString addAttribute:NSFontAttributeName value:defaultFont range:NSMakeRange(0, [completelyAppendedString length])];
        [mutableAttributedString addAttribute:NSFontAttributeName value:highlightedFont range:match.range];

    }];
    return mutableAttributedString;
}

@end
