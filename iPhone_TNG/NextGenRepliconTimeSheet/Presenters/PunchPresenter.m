#import "PunchPresenter.h"
#import "LocalPunch.h"
#import "Activity.h"
#import "BreakType.h"
#import "Punch.h"
#import "ImageFetcher.h"
#import <KSDeferred/KSPromise.h>
#import "ProjectType.h"
#import "ClientType.h"
#import "TaskType.h"
#import "Theme.h"
#import "OEFType.h"
#import "NSString+TruncateToWidth.h"
#import "TimelineCellAttributedTextPresenter.h"




@interface PunchPresenter ()

@property (nonatomic) NSDateFormatter *timeOnly12HrsFormatter;
@property (nonatomic) NSDateFormatter *timeOnly24HrsFormatter;
@property (nonatomic) NSDateFormatter *dateAndTimeFormatter;
@property (nonatomic) NSDateFormatter *ampmFormatter;
@property (nonatomic) ImageFetcher *imageFetcher;
@property (nonatomic) id <Theme> theme;


@end


typedef NS_ENUM(NSInteger, FontType)
{
    Regular=0,
    Light=1,
};

@implementation PunchPresenter

- (instancetype)initWithTimeOnly12HrsFormatter:(NSDateFormatter *)timeOnly12HrsFormatter
                        timeOnly24HrsFormatter:(NSDateFormatter *)timeOnly24HrsFormatter
                          dateAndTimeFormatter:(NSDateFormatter *)dateAndTimeFormatter
                                 amPmFormatter:(NSDateFormatter *)amPmFormatter
                                  imageFetcher:(ImageFetcher *)imageFetcher
                                         theme:(id <Theme>)theme {
    self = [super init];
    if (self) {
        self.timeOnly12HrsFormatter = timeOnly12HrsFormatter;
        self.timeOnly24HrsFormatter = timeOnly24HrsFormatter;
        self.dateAndTimeFormatter = dateAndTimeFormatter;
        self.imageFetcher = imageFetcher;
        self.ampmFormatter = amPmFormatter;
        self.theme = theme;
    }

    return self;
}

#pragma mark - NSObject

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSString *)dateTimeLabelTextWithPunch:(id<Punch>)punch
{
    return [self.dateAndTimeFormatter stringFromDate:punch.date];
}

- (NSString *)timeLabelTextWithPunch:(id<Punch>)punch
{
    return [self.timeOnly24HrsFormatter stringFromDate:punch.date];
}

- (NSString *)ampmLabelTextWithPunch:(id<Punch>)punch
{
    return [self.ampmFormatter stringFromDate:punch.date];
}

- (NSString *)timeWithAmPmLabelTextForPunch:(id<Punch>)punch
{
    return [NSString stringWithFormat:@"%@ %@",[self.timeOnly12HrsFormatter stringFromDate:punch.date],[self.ampmFormatter stringFromDate:punch.date]];
}


- (NSString *)descriptionLabelTextWithPunch:(id<Punch>)punch
{
    NSDictionary *descriptionsMap = @{@(PunchActionTypePunchIn): RPLocalizedString(@"Clocked In", nil),
                                      @(PunchActionTypeTransfer): RPLocalizedString(@"Clocked In", nil),
                                      @(PunchActionTypeStartBreak): RPLocalizedString(@"Started Break", nil),
                                      @(PunchActionTypePunchOut): RPLocalizedString(@"Clocked Out", nil),};


    return descriptionsMap[@(punch.actionType)];
}

- (NSString *)sourceOfPunchLabelTextWithPunch:(id<Punch>)punch
{
    NSString *via = RPLocalizedString(@"Via",nil);
    
    NSDictionary *descriptionsMap = @{@(Web): RPLocalizedString(@"Web",nil),
                                      @(CloudClock): RPLocalizedString(@"CloudClock",nil),
                                      @(Mobile): RPLocalizedString(@"Mobile",nil),
                                      @(UnknownSourceOfPunch) : RPLocalizedString(@"Unknown", nil)};
    NSString *sourceOFPunchText = descriptionsMap[@(punch.sourceOfPunch)];
    if (punch.sourceOfPunch == UnknownSourceOfPunch) {
        return [NSString stringWithFormat:@"%@",sourceOFPunchText];
    }
    return [NSString stringWithFormat:@"%@ %@",via,sourceOFPunchText];
}

- (UIImage *)punchActionIconImageWithPunch:(id<Punch>)punch
{
    UIImage *clockedInImage = [UIImage imageNamed:@"icon_timeline_clock_in"];
    UIImage *clockedOutImage = [UIImage imageNamed:@"icon_timeline_clock_out"];
    UIImage *breakImage = [UIImage imageNamed:@"icon_timeline_break"];

    NSDictionary *imageMap = @{@(PunchActionTypePunchIn): clockedInImage,
                               @(PunchActionTypeTransfer): clockedInImage,
                               @(PunchActionTypeStartBreak): breakImage,
                               @(PunchActionTypePunchOut): clockedOutImage};

    return imageMap[@(punch.actionType)];
}

- (void)presentImageForPunch:(id<Punch>)punch inImageView:(__weak UIImageView *)imageView
{
    imageView.layer.cornerRadius = 6.0f;
    imageView.clipsToBounds = YES;
    if ([punch respondsToSelector:@selector(image)] && punch.image) {
        imageView.image = punch.image;
    } else if ([punch respondsToSelector:@selector(imageURL)] && punch.imageURL) {
        KSPromise *imagePromise = [self.imageFetcher promiseWithImageURL:punch.imageURL];

        [imagePromise then:^id(UIImage *image) {
            imageView.image = image;
            return nil;
        } error:nil];
    }
}

- (NSMutableAttributedString * )descriptionLabelForTimelineCellTextWithPunch:(id <Punch>)punch
                                                                 regularFont:(UIFont *)regularFont
                                                                   lightFont:(UIFont *)lightFont
                                                                   textColor:(UIColor *)textColor
                                                                    forWidth:(CGFloat)width
{
    NSString *highlightedText;
    BOOL areThereAnyPunchAttributesPresentForPunch = [self areThereAnyPunchAttributesPresentForPunch:punch];
    if (areThereAnyPunchAttributesPresentForPunch) {
        NSMutableArray *allStrings = [NSMutableArray array];
        NSString *client = punch.client.name;
        if (client) {
            UIFont *font = regularFont;
            NSString *constrainedAttributedText = [client stringByTruncatingToWidth:width withFont:font];
            [allStrings addObject:constrainedAttributedText];
            highlightedText = constrainedAttributedText;
        }
        
        NSString *project = punch.project.name;
        if (project) {
            UIFont *font = client? lightFont:regularFont;
            NSString *constrainedAttributedText = [project stringByTruncatingToWidth:width withFont:font];
            [allStrings addObject:constrainedAttributedText];

            if (!client) {
                highlightedText = constrainedAttributedText;
            }
        }
        
        NSString *task = punch.task.name;
        if (task) {
            UIFont *font = lightFont;
            NSString *constrainedAttributedText = [task stringByTruncatingToWidth:width withFont:font];
            [allStrings addObject:constrainedAttributedText];
            BOOL clientPresent = (client != nil && client != (id)[NSNull null] && client.length > 0);
            BOOL projectPresent = (project != nil && project != (id)[NSNull null] && project.length > 0);
            if(!clientPresent && !projectPresent)
            {
                highlightedText = constrainedAttributedText;
            }
        }

        NSString *activity = punch.activity.name;
        if (activity) {
            UIFont *font = regularFont;
            NSString *constrainedAttributedText = [activity stringByTruncatingToWidth:width withFont:font];
            [allStrings addObject:constrainedAttributedText];
            highlightedText = constrainedAttributedText;
        }
        
        NSString *breakType = punch.breakType.name;
        if (breakType) {
            UIFont *font = regularFont;
            NSString *constrainedAttributedText = [breakType stringByTruncatingToWidth:width withFont:font];
            [allStrings addObject:constrainedAttributedText];
            highlightedText = constrainedAttributedText;
        }

        NSArray *oefTypesArray = punch.oefTypesArray;
        for (OEFType *oef in oefTypesArray) {
            NSString *oefValue;
            if ([oef.oefDefinitionTypeUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI]) {
                oefValue = oef.oefNumericValue;
            }
            else if ([oef.oefDefinitionTypeUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI]){
                oefValue = oef.oefTextValue;
            }
            else{
                oefValue = oef.oefDropdownOptionValue;
            }

            if (oefValue==nil || [oefValue isKindOfClass:[NSNull class]])
            {
                oefValue = RPLocalizedString(@"None", nil);
            }

            else
            {
                if (oefValue.length > 0)
                {
                    NSString *oefString = [NSString stringWithFormat:@"%@ : %@",oef.oefName,oefValue];
                    UIFont *font = lightFont;
                    NSString *constrainedAttributedText = [oefString stringByTruncatingToWidth:width withFont:font];
                    [allStrings addObject:constrainedAttributedText];
                }

            }


        }

        NSString *completelyAppendedString = @"";
        for (int k =0; k< [allStrings count]; k++)
        {
            NSString *constrainedString = allStrings[k];
            BOOL isLastObject = (k != [allStrings count]-1);
            if (isLastObject)
            {
                completelyAppendedString = [completelyAppendedString stringByAppendingString:[NSString stringWithFormat:@"%@\n",constrainedString]];
            }
            else
            {
                completelyAppendedString = [completelyAppendedString stringByAppendingString:constrainedString];
            }
        }
        highlightedText = SpecialCharsEscapedString(highlightedText);
        return [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                      withHighlightedText:highlightedText
                                                          highligthedFont:regularFont
                                                              defaultFont:lightFont
                                                                textColor:textColor];
    }
    else
    {
        NSMutableArray *allStrings = [NSMutableArray array];

        NSDictionary *descriptionsMap = @{@(PunchActionTypePunchIn): RPLocalizedString(@"Clocked In", nil),
                                          @(PunchActionTypeTransfer): RPLocalizedString(@"Clocked In", nil),
                                          @(PunchActionTypeStartBreak): punch.breakType.name ?: @"",
                                          @(PunchActionTypePunchOut): RPLocalizedString(@"Clocked Out", nil),};

        NSString *constrainedString = descriptionsMap[@(punch.actionType)];

        [allStrings addObject:constrainedString];


        NSArray *oefTypesArray = punch.oefTypesArray;
        for (OEFType *oef in oefTypesArray) {

            NSString *oefValue;
            if ([oef.oefDefinitionTypeUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI]) {
                oefValue = oef.oefNumericValue;
            }
            else if ([oef.oefDefinitionTypeUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI]){
                oefValue = oef.oefTextValue;
            }
            else{
                oefValue = oef.oefDropdownOptionValue;
            }

            if (oefValue==nil || [oefValue isKindOfClass:[NSNull class]])
            {
                oefValue = RPLocalizedString(@"None", nil);
            }
            else
            {
                if (oefValue.length > 0)
                {
                    NSString *oefString = [NSString stringWithFormat:@"%@ : %@",oef.oefName,oefValue];
                    UIFont *font = lightFont;
                    NSString *constrainedAttributedText = [oefString stringByTruncatingToWidth:width withFont:font];
                    [allStrings addObject:constrainedAttributedText];
                }

            }



        }

        NSString *completelyAppendedString = @"";
        for (int k =0; k< [allStrings count]; k++)
        {
            NSString *constrainedString = allStrings[k];
            BOOL isLastObject = (k != [allStrings count]-1);
            if (isLastObject)
            {
                completelyAppendedString = [completelyAppendedString stringByAppendingString:[NSString stringWithFormat:@"%@\n",constrainedString]];
            }
            else
            {
                completelyAppendedString = [completelyAppendedString stringByAppendingString:constrainedString];
            }
        }

        highlightedText = SpecialCharsEscapedString(constrainedString);
        return [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                      withHighlightedText:constrainedString
                                                          highligthedFont:regularFont
                                                              defaultFont:lightFont
                                                                textColor:textColor];
    }
}


- (NSMutableAttributedString * )descriptionLabelForDayTimelineCellTextWithPunch:(id <Punch>)punch
                                                                    regularFont:(UIFont *)regularFont
                                                                      lightFont:(UIFont *)lightFont
                                                                      textColor:(UIColor *)textColor
                                                                       forWidth:(CGFloat)width
{
    NSString *highlightedText;
    BOOL areThereAnyPunchAttributesPresentForPunch = [self areThereAnyPunchAttributesPresentForPunch:punch];
    if (areThereAnyPunchAttributesPresentForPunch) {
        NSMutableArray *allStrings = [NSMutableArray array];
        NSString *client = punch.client.name;
        NSString *project = punch.project.name;
        NSString *task = punch.task.name;
        NSString *activity = punch.activity.name;
        NSString *breakType = punch.breakType.name;

        BOOL isClientPresent = [self isValidString:client] ? true : false;
        BOOL isProjectPresent = [self isValidString:project] ? true : false;
        BOOL isTaskPresent = [self isValidString:task] ? true : false;
        BOOL isActivityPresent = [self isValidString:activity] ? true : false;
        BOOL isBreakPresent = [self isValidString:breakType] ? true : false;

        if (isClientPresent) {
            [allStrings addObject:client];
            highlightedText = client;
        }
        
        if (isProjectPresent) {
            [allStrings addObject:project];
            if (!isClientPresent) {
                highlightedText = project;
            }
        }
        
        if (isTaskPresent) {
            [allStrings addObject:task];
            if(!isClientPresent && !isProjectPresent)
            {
                highlightedText = task;
            }
        }
        
        if (isActivityPresent) {
            [allStrings addObject:activity];
            highlightedText = activity;
        }
        
        if (isBreakPresent) {
            [allStrings addObject:breakType];
            highlightedText = breakType;
        }
        
        NSArray *oefTypesArray = punch.oefTypesArray;
        for (OEFType *oef in oefTypesArray) {
            NSString *oefValue;
            if ([oef.oefDefinitionTypeUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI]) {
                oefValue = oef.oefNumericValue;
            }
            else if ([oef.oefDefinitionTypeUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI]){
                oefValue = oef.oefTextValue;
            }
            else{
                oefValue = oef.oefDropdownOptionValue;
            }
            
            if (oefValue==nil || [oefValue isKindOfClass:[NSNull class]])
            {
                oefValue = RPLocalizedString(@"None", nil);
            }
            
            else
            {
                if (oefValue.length > 0)
                {
                    NSString *oefString = [NSString stringWithFormat:@"%@ : %@",oef.oefName,oefValue];
                    NSString *constrainedAttributedText = oefString;
                    [allStrings addObject:constrainedAttributedText];
                }
                
            }
            
            
        }
        
        NSString *completelyAppendedString = @"";
        for (int k =0; k< [allStrings count]; k++)
        {
            NSString *constrainedString = allStrings[k];
            BOOL isLastObject = (k != [allStrings count]-1);
            if (isLastObject)
            {
                completelyAppendedString = [completelyAppendedString stringByAppendingString:[NSString stringWithFormat:@"%@\n",constrainedString]];
            }
            else
            {
                completelyAppendedString = [completelyAppendedString stringByAppendingString:constrainedString];
            }
        }
        highlightedText = SpecialCharsEscapedString(highlightedText);
        return [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                      withHighlightedText:highlightedText
                                                          highligthedFont:regularFont
                                                              defaultFont:lightFont
                                                                textColor:textColor];
    }
    else
    {
        NSMutableArray *allStrings = [NSMutableArray array];
        NSString *constrainedString = @"";
        
        NSArray *oefTypesArray = punch.oefTypesArray;
        for (OEFType *oef in oefTypesArray) {
            
            NSString *oefValue;
            if ([oef.oefDefinitionTypeUri isEqualToString:OEF_NUMERIC_DEFINITION_TYPE_URI]) {
                oefValue = oef.oefNumericValue;
            }
            else if ([oef.oefDefinitionTypeUri isEqualToString:OEF_TEXT_DEFINITION_TYPE_URI]){
                oefValue = oef.oefTextValue;
            }
            else{
                oefValue = oef.oefDropdownOptionValue;
            }
            
            if (oefValue==nil || [oefValue isKindOfClass:[NSNull class]])
            {
                oefValue = RPLocalizedString(@"None", nil);
            }
            else
            {
                if (oefValue.length > 0)
                {
                    NSString *oefString = [NSString stringWithFormat:@"%@ : %@",oef.oefName,oefValue];
                    NSString *constrainedAttributedText = oefString;
                    [allStrings addObject:constrainedAttributedText];
                }
                
            }
        }
        
        NSString *completelyAppendedString = @"";
        for (int k =0; k< [allStrings count]; k++)
        {
            NSString *constrainedString = allStrings[k];
            BOOL isLastObject = (k != [allStrings count]-1);
            if (isLastObject)
            {
                completelyAppendedString = [completelyAppendedString stringByAppendingString:[NSString stringWithFormat:@"%@\n",constrainedString]];
            }
            else
            {
                completelyAppendedString = [completelyAppendedString stringByAppendingString:constrainedString];
            }
        }
        
        highlightedText = SpecialCharsEscapedString(constrainedString);
        return [TimelineCellAttributedTextPresenter attributedTextForText:completelyAppendedString
                                                      withHighlightedText:constrainedString
                                                          highligthedFont:regularFont
                                                              defaultFont:lightFont
                                                                textColor:textColor];
    }
}


- (UIColor *)descendingLineViewColorForPunchActionType:(PunchActionType)actionType
{
    UIColor *punchInLineColor = [Util colorWithHex:@"#22C064" alpha:1.0];
    UIColor *punchOutLineColor = [Util colorWithHex:@"#3D4552" alpha:1.0];
    UIColor *punchBreakLineColor = [Util colorWithHex:@"#F7A72E" alpha:1.0];
    NSDictionary *imageMap = @{@(PunchActionTypePunchIn): punchInLineColor,
                               @(PunchActionTypeTransfer): punchInLineColor,
                               @(PunchActionTypeStartBreak): punchBreakLineColor,
                               @(PunchActionTypePunchOut): punchOutLineColor};
    
    return imageMap[@(actionType)];
}

#pragma mark - Private

-(BOOL)areThereAnyPunchAttributesPresentForPunch:(id <Punch>)punch
{
    BOOL hasClient =  punch.client ? [self isValidString:punch.client.name] : NO;
    BOOL hasProject =  punch.project ? [self isValidString:punch.project.name] :NO;
    BOOL hasTask =  punch.task ? [self isValidString:punch.task.name] :NO;
    BOOL hasActivity =  punch.activity ? [self isValidString:punch.activity.name] :NO;
    BOOL hasBreak =  punch.breakType ? [self isValidString:punch.breakType.name] :NO;

    return (hasClient || hasProject || hasTask || hasActivity || hasBreak);
}

-(BOOL)isValidString:(NSString *)value
{
    if (value != nil && value != (id) [NSNull null] && value.length > 0 && ![value isEqualToString:NULL_STRING]) {
        return YES;
    }
    return NO;
}

@end
