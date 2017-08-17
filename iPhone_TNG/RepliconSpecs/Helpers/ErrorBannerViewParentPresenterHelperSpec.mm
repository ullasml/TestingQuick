#import <Cedar/Cedar.h>
#import "ErrorBannerViewParentPresenterHelper.h"
#import "ErrorBannerViewController.h"
#import "InjectorProvider.h"
#import "InjectorKeys.h"
#import <Blindside/BSBinder.h>
#import <Blindside/BSInjector.h>
#import "Constants.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(ErrorBannerViewParentPresenterHelperSpec)

describe(@"ErrorBannerViewParentPresenterHelper", ^{
    __block ErrorBannerViewParentPresenterHelper    *subject;
    __block ErrorBannerViewController               *errorBannerViewController;
    __block id<BSBinder, BSInjector>                injector;
    beforeEach(^{
        injector = [InjectorProvider injector];
        
        errorBannerViewController = [injector getInstance:InjectorKeyErrorBannerViewController];
        
        subject = [injector getInstance:[ErrorBannerViewParentPresenterHelper class]];
    });
    
    beforeEach(^{
        spy_on(errorBannerViewController.view);
    });
    
    afterEach(^{
        stop_spying_on(errorBannerViewController.view);
    });
    
    describe(@"setTableViewInsetWithErrorBannerPresentation:", ^{
        __block UITableView *tableView;
        beforeEach(^{
            tableView = [[UITableView alloc]init];
        });
        context(@"when error banner view is not hidden", ^{
            beforeEach(^{
                errorBannerViewController.view stub_method(@selector(isHidden)).and_return(NO);
                [subject setTableViewInsetWithErrorBannerPresentation:tableView];
            });
            
            it(@"set to 0 bottom value", ^{
                tableView.contentInset should equal(UIEdgeInsetsMake(0, 0, errorBannerHeight, 0));
            });
        });
        
        context(@"when error banner view is hidden", ^{
            beforeEach(^{
                errorBannerViewController.view stub_method(@selector(isHidden)).and_return(YES);
                [subject setTableViewInsetWithErrorBannerPresentation:tableView];
            });
            
            it(@"set to 0 bottom value", ^{
                tableView.contentInset should equal(UIEdgeInsetsMake(0, 0, 0, 0));
            });
        });
    });
    
    describe(@"setScrollViewInsetWithErrorBannerPresentation:", ^{
        __block UIScrollView *scrollView;
        beforeEach(^{
            scrollView = [[UIScrollView alloc]init];
        });
        context(@"when error banner view is not hidden", ^{
            beforeEach(^{
                errorBannerViewController.view stub_method(@selector(isHidden)).and_return(NO);
                [subject setScrollViewInsetWithErrorBannerPresentation:scrollView];
            });
            
            it(@"set bottom value", ^{
                scrollView.contentInset should equal(UIEdgeInsetsMake(0, 0, errorBannerHeight, 0));
            });
        });
        
        context(@"when error banner view is hidden", ^{
            beforeEach(^{
                errorBannerViewController.view stub_method(@selector(isHidden)).and_return(YES);
                [subject setScrollViewInsetWithErrorBannerPresentation:scrollView];
            });
            
            it(@"set to 0 bottom value", ^{
                scrollView.contentInset should equal(UIEdgeInsetsMake(0, 0, 0, 0));
            });
        });
    });
});

SPEC_END
