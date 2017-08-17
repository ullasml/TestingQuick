#import "ApprovalsPendingCustomCell.h"
#import "Constants.h"
#import "Util.h"
#import "ApprovalsTimesheetHistoryViewController.h"
#import "ApprovalsPendingTimesheetViewController.h"
#import "ApprovalsPendingExpenseViewController.h"
#import "ApprovalsExpenseHistoryViewController.h"
#import "ApprovalsTimeOffHistoryViewController.h"
#import "ApprovalsPendingTimeOffViewController.h"
#import "DefaultTheme.h"

@interface ApprovalsPendingCustomCell ()

@property(nonatomic) id<Theme> theme;

@end

@implementation ApprovalsPendingCustomCell
@synthesize leftLbl;
@synthesize rightLbl;
@synthesize radioButton;
@synthesize userSelected;
@synthesize delegate;
@synthesize leftLowerLb;
@synthesize tableDelegate;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.theme = [[DefaultTheme alloc] init];

        if ([self respondsToSelector:@selector(setLayoutMargins:)])
        {
            self.preservesSuperviewLayoutMargins = NO;
            self.layoutMargins = UIEdgeInsetsZero;
        }
    }
    return self;
}

- (void)createCellLayoutWithParams:(NSString *)leftString
                   leftLowerString:(NSString *)lowerLeftString
                          rightstr:(NSString *)rightString
                    radioButtonTag:(NSInteger)tagValue
                       overTimeStr:(NSString *)overTimeString
                           mealStr:(NSString *)mealString
                        timeOffStr:(NSString *)timeOffString
                        regularStr:(NSString *)regularString
                    projectHourStr:(NSString *)projectHourString
           displaySummaryByPayCode:(BOOL)displaySummaryByPayCode
{
    CGFloat cellWidth = CGRectGetWidth(self.contentView.bounds);

    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }

    UIImage *radioDeselectedImage = [UIImage imageNamed:@"icon_crewEmpty"];

    radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [radioButton setFrame:CGRectMake(0.0, 0.0, radioDeselectedImage.size.width + 20.0, radioDeselectedImage.size.height + 19.0)];
    [radioButton setImage:radioDeselectedImage forState:UIControlStateNormal];
    [radioButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [radioButton setUserInteractionEnabled:YES];
    [radioButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 8.0, -6, 0.0)];
    [radioButton setHidden:NO];
    [radioButton setTag:tagValue];
    [radioButton setAccessibilityLabel:@"approval_radio_btn_label"];

    [radioButton addTarget:self
                    action:@selector(selectTaskRadioButton:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:radioButton];
    

    self.leftLbl = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 11.0, 155.0, 20.0)];
    [self.leftLbl setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_14]];
    [self.leftLbl setTextAlignment:NSTextAlignmentLeft];
    [self.leftLbl setText:leftString];
    [self.leftLbl setTag:tagValue+1];
    [self.contentView addSubview:self.leftLbl];


    self.leftLowerLb = [[UILabel alloc] initWithFrame:CGRectMake(40.0, 28.0, 110, 20.0)];
    if ([tableDelegate isKindOfClass:[ApprovalsPendingTimesheetViewController class]])
    {
        [self.leftLowerLb setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
    }
    else
    {
        [self.leftLowerLb setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
    }
    [self.leftLowerLb setTextAlignment:NSTextAlignmentLeft];
    [self.leftLowerLb setText:lowerLeftString];
    [self.leftLowerLb setTag:tagValue+2];
    [self.contentView addSubview:self.leftLowerLb];

    if ([tableDelegate isKindOfClass:[ApprovalsTimesheetHistoryViewController class]]) {
        self.radioButton.hidden = YES;
        self.leftLbl.frame = CGRectMake(9.0, 11.0, 155.0, 20.0);
        self.leftLowerLb.frame = CGRectMake(9.0, 28.0, 145.0, 20.0);
    }


    if (mealString != nil &&
        ![mealString isKindOfClass:[NSNull class]] &&
        [mealString newFloatValue] != 0) {
        //MEAL BREAK IMAGE VIEW
        UIImage *mealImage = [Util thumbnailImage:Mealbreaks_Box];
        UIImageView *mealBreakImageView = [[UIImageView alloc] initWithFrame:CGRectMake(210, 15.0, mealImage.size.width, mealImage.size.height)];

        if ([tableDelegate isKindOfClass:[ApprovalsTimesheetHistoryViewController class]])
            mealBreakImageView.frame = CGRectMake(195, 15.0, mealImage.size.width, mealImage.size.height);

        [mealBreakImageView setImage:mealImage];
        [mealBreakImageView setTag:tagValue+3];
        [self.contentView addSubview:mealBreakImageView];


        UILabel *mealLabel = [[UILabel alloc] initWithFrame:CGRectMake(230.0, 10.0, 50.0, 20.0)];

        if ([tableDelegate isKindOfClass:[ApprovalsTimesheetHistoryViewController class]])
            mealLabel.frame = CGRectMake(215.0, 11.0, 50.0, 20.0);

        [mealLabel setTextColor:[UIColor redColor]];
        [mealLabel setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
        [mealLabel setText:mealString];
        [mealLabel setTag:tagValue+4];
        [self.contentView addSubview:mealLabel];
    }

    self.rightLbl = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth - 53.0, 11.0, 53.0, 20.0)];
    self.rightLbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.rightLbl setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_14]];
    [self.rightLbl setTextAlignment:NSTextAlignmentRight];
    [self.rightLbl setText:rightString];
    [self.rightLbl setTag:tagValue+5];
    [self.contentView addSubview:self.rightLbl];

    [self createRightLowerWithOverTimestr:overTimeString
                               timeOffStr:timeOffString
                               regularStr:regularString
                               projectStr:projectHourString
                                 tagValue:tagValue
                  displaySummaryByPayCode:displaySummaryByPayCode];
    
}

- (void)createCellLayoutWithParams:(NSString *)leftString
                   leftLowerString:(NSString *)lowerLeftString
                          rightstr:(NSString *)rightString
                  rightLowerString:(NSString *)lowerRightString
                    radioButtonTag:(NSInteger)tagValue {

    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }

    CGFloat cellWidth = CGRectGetWidth(self.contentView.bounds);

    UIImage *radioDeselectedImage = [UIImage imageNamed:@"icon_crewEmpty"];

    radioButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [radioButton setFrame:CGRectMake(0, 0.0, radioDeselectedImage.size.width + 20.0,
                                     radioDeselectedImage.size.height + 19.0)];
    [radioButton setImage:radioDeselectedImage forState:UIControlStateNormal];
    [radioButton setBackgroundColor:[UIColor clearColor]];

    [radioButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [radioButton setUserInteractionEnabled:YES];
    [radioButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 8.0, -6, 0.0)];
    [radioButton setHidden:NO];
    [radioButton setTag:tagValue];

    [radioButton addTarget:self
                    action:@selector(selectTaskRadioButton:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:radioButton];

    self.leftLbl = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 11.0, 155.0, 20.0)];
    [self.leftLbl setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_14]];
    [self.contentView addSubview:self.leftLbl];
    [self.leftLbl setText:leftString];

    self.leftLowerLb = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 28.0, 125, 20.0)];
    [self.leftLowerLb setTextColor:[self.theme defaultTableViewSecondRowTextColor]];
    [self.leftLowerLb setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
    [self.leftLowerLb setText:lowerLeftString];
    [self.contentView addSubview:self.leftLowerLb];

    if ([tableDelegate isKindOfClass:[ApprovalsExpenseHistoryViewController class]] || [tableDelegate isKindOfClass:[ApprovalsTimeOffHistoryViewController class]]) {
        self.radioButton.hidden = YES;
        self.leftLbl.frame = CGRectMake(9.0, 11.0, 155.0, 20.0);
        self.leftLowerLb.frame = CGRectMake(9.0, 28.0, 90.0, 20.0);
    }

    self.rightLbl = [[UILabel alloc] initWithFrame:CGRectMake(cellWidth - 93.0, 11.0, 93.0, 20.0)];
    self.rightLbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.rightLbl setFont:[UIFont fontWithName:RepliconFontFamilyRegular size:RepliconFontSize_14]];
    [self.rightLbl setTextAlignment:NSTextAlignmentRight];
    [self.rightLbl setText:rightString];
    [self.contentView addSubview:self.rightLbl];

    UILabel *rightLowerLbl = [[UILabel alloc] init];
    rightLowerLbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [rightLowerLbl setTextColor:[self.theme defaultTableViewSecondRowTextColor]];
    [rightLowerLbl setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
    [rightLowerLbl setText:lowerRightString];
    [rightLowerLbl setTextAlignment:NSTextAlignmentRight];
    if ([tableDelegate isKindOfClass:[ApprovalsPendingExpenseViewController class]] || [tableDelegate isKindOfClass:[ApprovalsPendingExpenseViewController class]])
    {
        [rightLowerLbl setFrame:CGRectMake(cellWidth - 145, 28, 145, 20)];
    }
    else
    {
        [rightLowerLbl setFrame:CGRectMake(cellWidth - 150, 28, 150, 20)];
    }

    [self.contentView addSubview:rightLowerLbl];
}


- (void)selectTaskRadioButton:(UIButton *)sender
{
    //self.userSelected = !self.userSelected;

    if ([sender.currentImage isEqual: [UIImage imageNamed:@"icon_crewCheck"]])
    {
        self.userSelected = NO;
    }
    else
    {
         self.userSelected = YES;
    }

    if (self.userSelected) {
        UIImage *selectedRadioImage = [UIImage imageNamed:@"icon_crewCheck"];
        [radioButton setImage:selectedRadioImage forState:UIControlStateNormal];
    }
    else {
        UIImage *deselectedRadioImage = [UIImage imageNamed:@"icon_crewEmpty"];
        [radioButton setImage:deselectedRadioImage forState:UIControlStateNormal];
    }

    NSIndexPath *indexPath = [(UITableView *)self.superview.superview indexPathForCell:self];

    if ([delegate respondsToSelector:@selector(handleButtonClickforSelectedUser:isSelected:)])
        [delegate handleButtonClickforSelectedUser:indexPath
                                        isSelected:self.userSelected];
}

- (void)createRightLowerWithOverTimestr:(NSString *)overTimeString
                             timeOffStr:(NSString *)timeOffString
                             regularStr:(NSString *)regularString
                             projectStr:(NSString *)projectHourString
                               tagValue:(NSInteger)tagValue
                displaySummaryByPayCode:(BOOL)displaySummaryByPayCode
{

    CGFloat cellWidth = CGRectGetWidth(self.contentView.bounds);

    NSString *strHours = @"";

    if (projectHourString != nil &&
        ![projectHourString isKindOfClass:[NSNull class]] &&
        [projectHourString newFloatValue] != 0) {
        if (![strHours isEqualToString:@""]) {
            strHours = [NSString stringWithFormat:@"%@, %@ %@",
                        strHours, RPLocalizedString(@"Proj", @""),
                        projectHourString];
        }
        else {
            strHours = [NSString stringWithFormat:@"%@ %@", RPLocalizedString(@"Proj", @""),
                        projectHourString];
        }
    }
    
    if (timeOffString != nil &&
        ![timeOffString isKindOfClass:[NSNull class]] &&
        [timeOffString newFloatValue] != 0) {

        if (![strHours isEqualToString:@""])
        {
            strHours = [NSString stringWithFormat:@"%@, %@ %@",
                        strHours, RPLocalizedString(@"TO", @""),
                        timeOffString];
        }
        else {
            strHours = [NSString stringWithFormat:@"%@ %@", RPLocalizedString(@"TO", @""),
                        timeOffString];
        }


    }

    if (overTimeString != nil &&
        ![overTimeString isKindOfClass:[NSNull class]] &&
        [overTimeString newFloatValue] != 0) {

        if (![strHours isEqualToString:@""]) {
            strHours = [NSString stringWithFormat:@"%@, %@ %@",
                                                  strHours, RPLocalizedString(@"OT", @""),
                                                  overTimeString];
        }
        else {
            strHours = [NSString stringWithFormat:@"%@ %@", RPLocalizedString(@"OT", @""),
                                                  overTimeString];
        }
    }

    if (regularString != nil &&
        ![regularString isKindOfClass:[NSNull class]] &&
        [regularString newFloatValue] != 0) {
        if (![strHours isEqualToString:@""]) {
            strHours = [NSString stringWithFormat:@"%@, %@ %@",
                                                  strHours, RPLocalizedString(@"Reg", @""),
                                                  regularString];
        }
        else {
            strHours = [NSString stringWithFormat:@"%@ %@", RPLocalizedString(@"Reg", @""),
                                                  regularString];
        }
    }

    
    UILabel *rightLowerLbl = [[UILabel alloc] init];
    [rightLowerLbl setFont:[UIFont fontWithName:RepliconFontFamilyLight size:RepliconFontSize_12]];
    [rightLowerLbl setText:regularString];
    [rightLowerLbl setTextAlignment:NSTextAlignmentRight];
    [rightLowerLbl setText:strHours];
    if ([tableDelegate isKindOfClass:[ApprovalsTimesheetHistoryViewController class]]){
        [rightLowerLbl setFrame:CGRectMake(cellWidth - 175, 28, 175, 20)];

    }
    else{
        [rightLowerLbl setFrame:CGRectMake(cellWidth - 155, 28, 155, 20)];
    }
    rightLowerLbl.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [rightLowerLbl setTag:tagValue+6];
    [self.contentView addSubview:rightLowerLbl];
    if(!displaySummaryByPayCode){
        self.rightLbl.hidden = true;
        rightLowerLbl.hidden = true;
    }
}

@end
