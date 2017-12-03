//
//  SPTabController.m
//  Radio
//
//  Created by sparrow on 16/01/2017.
//  Copyright © 2017 qzone. All rights reserved.
//

#import "SPTabController.h"
#import "SPTagBarScrollView.h"
#import "SPPageController.h"

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

@interface SPTabController () <SPPageControllerDelegate, SPPageControllerDataSource, SPTabDataSource, SPTabDelegate>

@property (nonatomic, strong) UIView *tabView;

@property (nonatomic, strong) SPPageController *pageController;

@property (nonatomic, assign) CGFloat tabViewTop;

@property (nonatomic, assign) BOOL cannotScrollWithPageOffset;//为解决pagecontroller的横向滑动问题

@end

@implementation SPTabController


- (void)tabDragWithOffset:(CGFloat)offset
{
    
    [self setTabViewTop:[self tabScrollTopWithContentOffset:offset]];
}

- (CGFloat)tabScrollTopWithContentOffset:(CGFloat)offset
{
    CGFloat top = [self preferTabY]-offset;
    if (offset >= 0) {//上滑
        if (top <= self.minYPullUp) {
            top = self.minYPullUp;
        }
    } else {//下拉
        if (top >= self.maxYPullDown) {
            top = self.maxYPullDown;
        }
    }
    return top;
}


- (void)setTabViewTop:(CGFloat)tabViewTop
{
    self.tabView.frame = CGRectMake(self.tabView.frame.origin.x, tabViewTop, self.tabView.frame.size.width, self.tabView.frame.size.height);
}

- (CGFloat)tabViewTop
{
    return self.tabView.frame.origin.y;
}

- (void)reloadTab
{
    [self.tabView removeFromSuperview];
    self.tabView = nil;

    [self __setupTabBar];
}

- (void)pageviewControllerDidTransitiontoViewController:(UIViewController *)toVC fromVC:(UIViewController *)fromVC
{

    if ([fromVC conformsToProtocol:@protocol(SPPageSubControllerDataSource) ]) {
        UIViewController<SPPageSubControllerDataSource> *fromVCTemp =  (UIViewController<SPPageSubControllerDataSource> *)fromVC;
        fromVCTemp.preferScrollView.scrollsToTop = NO;
    }

    if ([toVC conformsToProtocol:@protocol(SPPageSubControllerDataSource) ]) {
        UIViewController<SPPageSubControllerDataSource> *toVCTemp =  (UIViewController<SPPageSubControllerDataSource> *)toVC;
        toVCTemp.preferScrollView.scrollsToTop = YES;
    }

    [self changeToSubControllerOffset:toVC isDelay:YES];

}

- (CGFloat)scrollViewOffsetAtIndex:(NSInteger)index
{
    return ([self preferTabY]- self.tabViewTop)- [self pageTopAtIndex:index];
}

- (void)changeToSubControllerOffset:(UIViewController *)toVC isDelay:(BOOL)isDelay
{
    if (!toVC || [self numberOfControllers] <=1) {
        self.cannotScrollWithPageOffset = NO;
        return;
    }
    
    if ([toVC conformsToProtocol:@protocol(SPPageSubControllerDataSource)]) {
        UIViewController<SPPageSubControllerDataSource> *toVCTemp =  (UIViewController<SPPageSubControllerDataSource> *)toVC;
        NSInteger newIndex = [self.pageController indexOfController:toVCTemp];
        CGFloat pageTop = [self pageTopAtIndex:newIndex];
        CGFloat top =  [self tabScrollTopWithContentOffset:[toVCTemp preferScrollView].contentOffset.y+pageTop];
        
        //如果计算出来的高度一样，不用去修改offset
        if ( fabs(top -self.tabViewTop) > 0.1) {
            CGFloat scrollOffset = [self scrollViewOffsetAtIndex:newIndex];
            self.cannotScrollWithPageOffset = NO;
            [toVCTemp preferScrollView].contentOffset =  CGPointMake(0, scrollOffset);
            
        } else {
            self.cannotScrollWithPageOffset = NO;
        }
        
    } else {
        self.cannotScrollWithPageOffset = NO;
    }
}



- (void)__setupPage
{
    self.pageController = [[SPPageController alloc] init];
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    [self.pageController updateCurrentIndex:[self preferPageFirstAtIndex]];
    self.pageController.view.frame = [self preferPageFrame];

    [self addChildViewController:self.pageController];
    [self.view addSubview:self.pageController.view];
    [self.pageController didMoveToParentViewController:self];

}

- (UIView *)customTabView
{
    return nil;
}

- (void)__setupTabBar
{
    if ([self preferSingleTabNotShow] && [self numberOfControllers] <=1) {

        return ;
    }

    UIView *tabView = [self customTabView];
    if (!tabView) {
        tabView = [[SPTagBarScrollView alloc] initWithFrame:[self preferTabFrame] dataSource:self delegate:self];

    }

    [self.view addSubview:tabView];
    self.tabView = tabView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __setupData];
    [self __setupPage];
    [self __setupTabBar];
}

- (CGRect)preferTabFrame
{
    return CGRectMake([self preferTabX], [self preferTabY], [self preferTabW], [self preferTabHAtIndex:self.pageController.currentPageIndex]);
}

- (void)__setupData
{
    self.maxYPullDown = SCREEN_HEIGHT;
    self.minYPullUp = 64;//默认的navbar和statusbar的高度
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.cannotScrollWithPageOffset = NO;
    [self.pageController beginAppearanceTransition:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.pageController endAppearanceTransition];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.cannotScrollWithPageOffset = YES;
    [self.pageController beginAppearanceTransition:NO animated:animated];

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.pageController endAppearanceTransition];
}

- (BOOL)preferSingleTabNotShow
{
    return NO;
}

- (void)reloadData
{
    [self reloadPage];
    [self reloadTab];
}

- (void)reloadPage
{
    [self.pageController updateCurrentIndex:[self preferPageFirstAtIndex]];
    self.pageController.view.frame = [self preferPageFrame];
    [self.pageController reloadPage];
}

- (void)updateTabBarWithIndex:(NSInteger)index
{
    if ([self.tabView isKindOfClass:[SPTagBarScrollView class]]) {
        SPTagBarScrollView *tabView = (SPTagBarScrollView *)self.tabView;
        [tabView reloadHighlightToIndex:index];
    }

}


- (void)reloadTabH:(BOOL)isTabScroll
{
    if (self.currentIndex < 0) {
        return;
    }
    self.tabView.frame  = [self preferTabFrame];

    if (!isTabScroll) {
        self.pageController.view.frame = [self preferPageFrame];
    } else {
        [self.pageController resizePageAtIndex:self.pageController.currentPageIndex offset:[self scrollViewOffsetAtIndex:self.currentIndex] isNeedChangeOffset:self.tabViewTop > self.minYPullUp atBeginOffsetChangeOffset:self.tabViewTop == self.minYPullUp];
    }
}

- (NSInteger)currentIndex
{
    return self.pageController.currentPageIndex;
}

#pragma SPPageControllerDelegate

-(void)scrollViewContentOffsetWithRatio:(CGFloat)ratio draging:(BOOL)draging
{
    if ([self.tabView isKindOfClass:[SPTagBarScrollView class]]) {

        if (!draging) {
            __weak SPTabController *wSelf = self;
            [UIView animateWithDuration:0.3 animations:^{
                SPTabController *bSelf = wSelf;
                SPTagBarScrollView *scrollView = (SPTagBarScrollView *)bSelf.tabView;
                [scrollView markViewScrollToIndex:ratio];
                scrollView.markViewScroll = NO;
            } completion:^(BOOL finished) {
                SPTabController *bSelf = wSelf;
                SPTagBarScrollView *scrollView = (SPTagBarScrollView *)bSelf.tabView;
                scrollView.markViewScroll = YES;
                [self updateTabBarWithIndex:floor(ratio+0.5)];

            }];
        } else {
            SPTagBarScrollView *scrollView = (SPTagBarScrollView *)self.tabView;
            [scrollView markViewScrollToContentRatio:ratio];
            [self updateTabBarWithIndex:floor(ratio+0.5)];
        }
    }

}

- (void)scrollWithPageOffset:(CGFloat)offset index:(NSInteger)index
{
    [self tabDragWithOffset:offset+[self pageTopAtIndex:index]];
}


- (void)pageviewController:(SPPageController*)pageController willTransitionFromVC:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{

    [self changeToSubControllerOffset:toVC isDelay:NO];
}

- (void)pageviewController:(SPPageController*)pageController didTransitionFromVC:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    [self pageviewControllerDidTransitiontoViewController:toVC fromVC:fromVC];
    if ([self.tabView isKindOfClass:[SPTagBarScrollView class]]) {
        SPTagBarScrollView *scrollView = (SPTagBarScrollView *)self.tabView;
        [scrollView scrollTagToIndex:self.pageController.currentPageIndex];

    }

}

- (void)pageviewController:(SPPageController*)pageController willLeaveFromVC:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    [self changeToSubControllerOffset:toVC isDelay:NO];
}

- (void)pageviewController:(SPPageController*)pageController didLeaveFromVC:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    [self pageviewControllerDidTransitiontoViewController:toVC fromVC:fromVC];
}

#pragma SPPageControllerDataSource

- (NSInteger)numberOfControllers
{
    return 0;
}

- (CGRect)preferPageFrame
{
    return CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
}

- (UIViewController *)controllerAtIndex:(NSInteger)index
{
    return nil;
}

- (CGFloat)pageTopAtIndex:(NSInteger)index
{
    return [self preferTabY] + [self preferTabHAtIndex:index]-[self preferPageFrame].origin.y;
}

- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer
{
    UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = nil;
    if (self.navigationController.view.gestureRecognizers.count > 0)
    {
        for (UIGestureRecognizer *recognizer in self.navigationController.view.gestureRecognizers)
        {
            if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
            {
                screenEdgePanGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)recognizer;
                break;
            }
        }
    }

    return screenEdgePanGestureRecognizer;
}

- (BOOL)isPreLoad
{
    return NO;
}

#pragma SPTabDataSource 规范化的TAB设计样式可以放在这里

- (NSString *)titleForIndex:(NSInteger)index
{
    return nil;
}

- (CGFloat)preferTabHAtIndex:(NSInteger)index
{
    return 40;
}

- (CGFloat)preferTabY
{
    return KNAVIGATIONANDSTATUSBARHEIGHT;
}

- (CGFloat)preferTabX
{
    return 0;
}

- (CGFloat)preferTabW
{
    return SCREEN_WIDTH;
}

-(NSInteger)preferPageFirstAtIndex
{
    return 0;
}

- (NSInteger)numberOfTab
{
    return [self numberOfControllers];
}


-(CGFloat)tabTopForIndex:(NSInteger)index
{
    return 0;
}

- (CGFloat)tabWidthForIndex:(NSInteger)index
{
    NSString *text = [self titleForIndex:index];
    if (text.length <=3) {
        return 73;
    } else {
        return 105;
    }
}

- (UIColor *)titleColorForIndex:(NSInteger)index
{
    return [UIColor blackColor];
}

- (UIColor *)titleHighlightColorForIndex:(NSInteger)index
{
    return [UIColor orangeColor];
}

- (UIFont *)titleFontForIndex:(NSInteger)index
{
    return [UIFont systemFontOfSize:13.0];
}

- (UIColor *)tabBackgroundColor
{
    return [UIColor whiteColor];
}

- (NSInteger)preferTabIndex{
    return [self preferPageFirstAtIndex];
}

- (BOOL)needMarkView
{
    return YES;
}

- (CGFloat)markViewBottom
{
    return [self preferTabHAtIndex:self.pageController.currentPageIndex]-7;
}

-(CGFloat)markViewWidthForIndex:(NSInteger)index
{
    NSString *text = [self titleForIndex:index];

    CGRect rect = [text boundingRectWithSize:CGSizeMake(20000, 40) options:NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[self titleFontForIndex:index ]} context:nil];

    return rect.size.width;
}

-(UIColor *)markViewColorForIndex:(NSInteger)index
{
    return [UIColor orangeColor];
}

#pragma SPTabDelegate
- (void)didPressTabForIndex:(NSInteger)index
{
    if ([self isSubPageCanScrollForIndex:index]) {
        [self.pageController showPageAtIndex:index animated:YES];

    }
    
}

- (void)willChangeInit
{
    self.cannotScrollWithPageOffset = YES;
}

-(BOOL)isTabCanPressForIndex:(NSInteger)index
{
    return [self isSubPageCanScrollForIndex:index];
}

-(BOOL)isSubPageCanScrollForIndex:(NSInteger)index
{
    return YES;
}


@end
