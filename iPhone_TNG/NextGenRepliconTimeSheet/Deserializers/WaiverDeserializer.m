#import "WaiverDeserializer.h"
#import "Waiver.h"
#import "WaiverOption.h"


@implementation WaiverDeserializer

- (Waiver *)deserialize:(NSDictionary *)waiverDictionary
{
    Waiver *waiver = nil;
    if (waiverDictionary != (id)[NSNull null])
    {
        NSString *displayText = waiverDictionary[@"displayText"];

        NSMutableArray *mutableOptions = [NSMutableArray array];
        for (NSDictionary *waiverOptionsDictionary in waiverDictionary[@"options"]) {
            NSString *waiverOptionDisplayText = waiverOptionsDictionary[@"displayText"];
            NSString *waiverOptionValue = waiverOptionsDictionary[@"value"];
            WaiverOption *waiverOption = [[WaiverOption alloc] initWithDisplayText:waiverOptionDisplayText value:waiverOptionValue];
            [mutableOptions addObject:waiverOption];
        }

        WaiverOption *selectedOption = nil;
        NSDictionary *selectedOptionDictionary = waiverDictionary[@"selectedOption"];
        if (selectedOptionDictionary != (id)[NSNull null]) {
            NSString *selectedOptionValue = selectedOptionDictionary[@"optionValue"];
            for (WaiverOption *waiverOption in mutableOptions) {
                if ([waiverOption.value isEqualToString:selectedOptionValue]) {
                    selectedOption = waiverOption;
                }
            }
        }

        waiver = [[Waiver alloc] initWithURI:waiverDictionary[@"uri"]
                                 displayText:displayText
                                     options:[mutableOptions copy]
                              selectedOption:selectedOption];
    }
    return waiver;
}

@end
