#import <UIKit/UIKit.h>

@interface ListOfTimeSheetsCustomCell : UITableViewCell


-(void)createCellLayoutWithParams:(NSString *)upperleftString
               upperlefttextcolor:(UIColor *)_lefttextcolor
                    upperrightstr:(NSString *)upperrightString
              upperRighttextcolor:(UIColor *)_righttextcolor
                      overTimeStr:(NSString *)overTimeString
                          mealStr:(NSString *)mealCount
                       timeOffStr:(NSString *)timeOffString
                       regularStr:(NSString *)regularString
                   approvalStatus:(NSString *)approvalStatus
                            width:(CGFloat)width
                      pendingSync:(BOOL)isPendingSync;

@end
