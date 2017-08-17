//
//  DataListViewController.h
//  Replicon
//
//  Created by Dipta Rakshit on 8/31/12.
//
//

#import <UIKit/UIKit.h>
#import "G2OverlayViewController.h"
#import "G2Constants.h"
@interface G2DataListViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UIScrollViewDelegate>

{
    
    UITableView *mainTableView;
    NSString *titleStr;
    NSMutableArray *listOfItems;
    NSMutableArray *listOfItemsCopy;
    UISearchBar *searchBar;
	BOOL searching;
	BOOL letUserSelectRow;
    G2OverlayViewController *ovController;
    NSString *selectedRowIdentity;
    id __weak parentDelegate;
    UIView *footerView,*loadingFooterView;
    UIButton *moreButton;
    UIImageView *moreImageView;
     UILabel *noResultsLabel;
    BOOL isShowMoreButton;
    UISegmentedControl *segmentedCtrl;
    int setViewTag;
    NSMutableArray *allProjectsArr,*recentProjectsArr;
    NSInteger selectedIndex;
    UIView *progressView;
    enum ProjectPermissionType		permissionType;
}
@property(nonatomic,strong) UIView *progressView;
@property(nonatomic,strong) NSMutableArray *allProjectsArr,*recentProjectsArr;
@property(nonatomic,strong) UISegmentedControl *segmentedCtrl;
@property(nonatomic,assign) BOOL isShowMoreButton;
@property(nonatomic,strong) UILabel *noResultsLabel;
@property(nonatomic,strong) UITableView *mainTableView;
@property(nonatomic,strong)  NSString *titleStr;
@property(nonatomic,strong) NSMutableArray *listOfItems;
@property(nonatomic,strong) NSMutableArray *listOfItemsCopy;
@property(nonatomic,strong) UISearchBar *searchBar;
@property(nonatomic,assign) BOOL searching;
@property(nonatomic,assign) BOOL letUserSelectRow;
@property(nonatomic,strong) NSString *selectedRowIdentity;
@property(nonatomic,weak) id parentDelegate;
@property(nonatomic,strong) UIView *footerView,*loadingFooterView;
@property(nonatomic,strong) UIButton *moreButton;
@property(nonatomic,strong) UIImageView *moreImageView;
@property(nonatomic,assign) int setViewTag;

- (void) doneSearching_Clicked:(id)sender;
-(void)expensesFinishedDownloadingProjects: (id)notificationObject ;

-(void)addAllView:(float )delayTime;
-(void)addRecentView:(BOOL)flag;
-(void) changeUISegmentFont:(UIView*) myView;
-(void)showLoadingFooterView;
-(void)addTransparentOverlay;
- (void) searchTableView;
@end
