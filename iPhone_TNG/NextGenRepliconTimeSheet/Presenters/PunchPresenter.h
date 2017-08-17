#import <UIKit/UIKit.h>

@protocol Punch;
@protocol Theme ;
@class ImageFetcher;
#import "PunchActionTypes.h"

@interface PunchPresenter : NSObject

@property (nonatomic, readonly) NSDateFormatter *timeOnly12HrsFormatter;
@property (nonatomic, readonly) NSDateFormatter *timeOnly24HrsFormatter;
@property (nonatomic, readonly) NSDateFormatter *dateAndTimeFormatter;
@property (nonatomic, readonly) NSDateFormatter *ampmFormatter;
@property (nonatomic, readonly) ImageFetcher *imageFetcher;


+ (instancetype)new UNAVAILABLE_ATTRIBUTE;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
- (instancetype)initWithDataDictionary:(NSDictionary *)dictionary UNAVAILABLE_ATTRIBUTE;

- (instancetype)initWithTimeOnly12HrsFormatter:(NSDateFormatter *)timeOnly12HrsFormatter
                        timeOnly24HrsFormatter:(NSDateFormatter *)timeOnly24HrsFormatter
                          dateAndTimeFormatter:(NSDateFormatter *)dateAndTimeFormatter
                                 amPmFormatter:(NSDateFormatter *)amPmFormatter
                                  imageFetcher:(ImageFetcher *)imageFetcher
                                         theme:(id <Theme>)theme;

- (NSString *)dateTimeLabelTextWithPunch:(id<Punch>)punch;

- (UIColor *)descendingLineViewColorForPunchActionType:(PunchActionType)actionType;

- (NSString *)timeWithAmPmLabelTextForPunch:(id<Punch>)punch;

- (NSString *)timeLabelTextWithPunch:(id<Punch>)punch;

- (NSString *)ampmLabelTextWithPunch:(id<Punch>)punch;

- (NSString *)descriptionLabelTextWithPunch:(id<Punch>)punch;

- (UIImage *)punchActionIconImageWithPunch:(id<Punch>)punch;

- (NSString *)sourceOfPunchLabelTextWithPunch:(id<Punch>)punch;

- (void)presentImageForPunch:(id<Punch>)punch inImageView:(__weak UIImageView *)imageView;

- (NSMutableAttributedString * )descriptionLabelForTimelineCellTextWithPunch:(id <Punch>)punch
                                                                 regularFont:(UIFont *)regularFont
                                                                   lightFont:(UIFont *)lightFont
                                                                   textColor:(UIColor *)textColor
                                                                    forWidth:(CGFloat)width;

- (NSMutableAttributedString * )descriptionLabelForDayTimelineCellTextWithPunch:(id <Punch>)punch
                                                                    regularFont:(UIFont *)regularFont
                                                                      lightFont:(UIFont *)lightFont
                                                                      textColor:(UIColor *)textColor
                                                                       forWidth:(CGFloat)width;
@end
