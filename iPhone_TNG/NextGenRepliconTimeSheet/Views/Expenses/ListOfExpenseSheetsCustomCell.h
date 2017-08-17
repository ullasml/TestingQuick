#import <UIKit/UIKit.h>

@interface ListOfExpenseSheetsCustomCell : UITableViewCell

-(void)createCellLayoutWithParams:(NSString *)upperleftString
                    upperrightstr:(NSString *)upperrightString
                    lowerrightStr:(NSString *)lowerrightStr
                   lowerleftImage:(UIImage *)lowerleftImage
                   approvalStatus:(NSString *)approvalStatus;

- (id)initWithStyle:(enum UITableViewCellStyle)style
    reuseIdentifier:(NSString *)identifier
              width:(CGFloat)width;


@end
