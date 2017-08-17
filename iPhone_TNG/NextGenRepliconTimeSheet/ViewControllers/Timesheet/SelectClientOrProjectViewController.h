#import <UIKit/UIKit.h>
#import "OverlayViewController.h"

@interface SelectClientOrProjectViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UISegmentedControl *segmentedCtrl;
    UITextField *searchTextField;
    UITableView *mainTableView;
    NSMutableArray *listOfItems;
    id __weak delegate;
    NSMutableArray *arrayOfCharacters;
    NSMutableDictionary *objectsForCharacters;
    id __weak viewDelegate;
    OverlayViewController *ovController;
    NSTimer *searchTimer;
    NSString *selectedTimesheetUri;
    NSString *selectedExpensesheetURI;
        
    NSString *searchProjectString;
    BOOL isPreFilledSearchString;
    
    NSString *selectedClientName;
    NSString *selectedClientUri;
    
}

@property(nonatomic,strong) NSString *selectedClientName;
@property(nonatomic,strong) NSString *selectedClientUri;
@property(nonatomic,assign) BOOL isPreFilledSearchString,isProgramAccess;
@property(nonatomic,strong)  NSString *searchProjectString;
@property(nonatomic,strong) UISegmentedControl *segmentedCtrl;
@property(nonatomic,strong) UITextField *searchTextField;
@property(nonatomic,strong) UITableView *mainTableView;
@property(nonatomic,strong) NSMutableArray *listOfItems;
@property(nonatomic,weak) id delegate;
@property(nonatomic,strong) NSMutableArray *arrayOfCharacters;
@property(nonatomic,strong) NSMutableDictionary *objectsForCharacters;
@property(nonatomic,weak) id viewDelegate;
@property(nonatomic,strong) NSTimer *searchTimer;
@property(nonatomic,strong) NSString *selectedTimesheetUri;
@property(nonatomic,strong) NSString *selectedExpensesheetURI;
@property(nonatomic,assign) BOOL isTextFieldFirstResponder;
@property(nonatomic,assign) BOOL isFromLockedInOut,isFromAttendance;

-(void)doneSearching_Clicked:(id)sender;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end
