
#import "NSString+TruncateToWidth.h"

@implementation NSString (TruncateToWidth)

- (NSString*)stringByTruncatingToWidth:(CGFloat)labelWidth withFont:(UIFont *)font
{
    // Create ellipsis string that could be appended in case of exceeding widths
    NSString *ellipsis = @"...";

    // Create mutable copy that will be the returned result after modifications
    NSMutableString *truncatedString = [self mutableCopy];
    if (truncatedString!=nil && ![truncatedString isKindOfClass:[NSNull class]])
    {
        NSArray *newLineStringArr = [truncatedString componentsSeparatedByString:@"\n"];
        if (newLineStringArr.count>1)
        {
            truncatedString = [NSMutableString stringWithFormat:@"%@%@",newLineStringArr[0],ellipsis];
        }
    }
    NSDictionary *attributes = @{NSFontAttributeName: font};
    CGFloat widthOfTheAttribute = [self sizeWithAttributes:attributes].width;

    // if the string is longer than requested label width
    if (widthOfTheAttribute > labelWidth)
    {
        // Accommodate for ellipsis we'll tack on the end
        labelWidth -= [ellipsis sizeWithAttributes:attributes].width;

        // Get range for last character in string
        NSRange range = {truncatedString.length - 1, 1};

        // Loop, deleting characters until string fits within width
        while ([truncatedString sizeWithAttributes:attributes].width > labelWidth)
        {
            // Delete character at end
            [truncatedString deleteCharactersInRange:range];

            // Move back another character
            range.location--;
        }

        // Append ellipsis
        [truncatedString replaceCharactersInRange:range withString:ellipsis];
    }
    return truncatedString;
}
@end
