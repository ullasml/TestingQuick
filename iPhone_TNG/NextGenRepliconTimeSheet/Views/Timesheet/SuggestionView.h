#import <UIKit/UIKit.h>

@interface SuggestionView : UIView

@property (nonatomic, strong) NSMutableAttributedString *attributedString;

- (id)initWithFrame:(CGRect)frame
    andWithDataDict:(NSMutableDictionary *)heightDict
      suggestionObj:(NSMutableDictionary *)suggestionObj
            withTag:(int)tag
       withDelegate:(id)delegate;

@end
