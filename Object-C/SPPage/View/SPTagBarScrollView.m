//
//  SPTagBarScrollView.m
//  Radio
//
//  Created by sparrow on 20/10/2016.
//  Copyright © 2016 qzone. All rights reserved.
//

#import "SPTagBarScrollView.h"
#import "SPPageTagView.h"

@interface SPTagBarScrollView () <UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray <SPPageTagView *> *tagViewsCache;

@property (strong, nonatomic) UIView *markView;

@property (assign, nonatomic) NSInteger index;

@property (nonatomic, weak, readwrite) id<SPTabDataSource> tabDataSource;

@property (nonatomic, weak, readwrite) id<SPTabDelegate> tabDelegate;


@end

@implementation SPTagBarScrollView

- (instancetype)initWithFrame:(CGRect)frame dataSource:(id<SPTabDataSource>)dataSource delegate:(id<SPTabDelegate>) delegate
{
    self = [super init];

    if (self) {
        self.frame = frame;
        self.tabDataSource = dataSource;
        self.tabDelegate = delegate;
        [self __setupProperty];
        [self __setupTagBarView];
        [self __setupMaskView];
        [self __setupFirstIndex];

    }

    return self;
}

- (void)__setupProperty
{
    self.contentSize = CGSizeZero;
    self.directionalLockEnabled = YES;
    self.scrollsToTop = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.backgroundColor = [UIColor clearColor];
}

- (void)__setupTagBarView
{


    self.tagViewsCache = [NSMutableArray new];

    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }

    CGFloat tabContentWidth = 0;

    NSInteger offset = 0;
    NSInteger preferTabOffset = [self.tabDataSource respondsToSelector:@selector(preferTabLeftOffset)]?[self.tabDataSource preferTabLeftOffset]:5;
    for (int i=0;i<[self.tabDataSource numberOfTab];i++) {
        tabContentWidth += [self.tabDataSource respondsToSelector:@selector(tabWidthForIndex:)]?[self.tabDataSource tabWidthForIndex:i]:73;
    }
    if ((tabContentWidth+2*preferTabOffset ) > self.frame.size.width) {
        offset = preferTabOffset;
    } else {
        offset = (self.frame.size.width-tabContentWidth)/2.0;
    }


    for (int i=0;i<[self.tabDataSource numberOfTab];i++) {
        NSInteger tagWidth = [self.tabDataSource respondsToSelector:@selector(tabWidthForIndex:)]?[self.tabDataSource tabWidthForIndex:i]:73;
        CGFloat top = [self.tabDataSource respondsToSelector:@selector(tabTopForIndex:)]? [self.tabDataSource tabTopForIndex:i]:0;
        SPPageTagTitleView *titleView = [[SPPageTagTitleView alloc] initWithFrame:CGRectMake(offset, top, tagWidth, self.frame.size.height)];
        if ([self.tabDataSource respondsToSelector:@selector(titleColorForIndex:)]) {
            titleView.normalTitleColor = [self.tabDataSource titleColorForIndex:i];
        }
        if ([self.tabDataSource respondsToSelector:@selector(titleHighlightColorForIndex:)]) {
            titleView.highlightedTitleColor = [self.tabDataSource titleHighlightColorForIndex:i];
        }
        titleView.title.text = [self.tabDataSource titleForIndex:i];
        titleView.title.font = [self.tabDataSource respondsToSelector:@selector(titleFontForIndex:)]? [self.tabDataSource titleFontForIndex:i]:[UIFont systemFontOfSize:15.0];
        titleView.tag = i;

        titleView.userInteractionEnabled = YES;

        [titleView addTarget:self action:@selector(pressTab:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:titleView];
        [self.tagViewsCache addObject:titleView];
        offset += tagWidth;
    }

    [self reloadHighlight];

    self.contentSize = CGSizeMake(offset, self.frame.size.height);
    if ([self.tabDataSource respondsToSelector:@selector(tabBackgroundColor)]) {
        self.backgroundColor = [self.tabDataSource tabBackgroundColor];
    } else {
        self.backgroundColor = [UIColor clearColor];
    }
}

- (void)pressTab:(UIControl *)sender
{
   
    NSInteger i = sender.tag;

    [self.tabDelegate didPressTabForIndex:i];

    if  (self.index == i) {
        return;
    }
    
    if ([self.tabDataSource respondsToSelector:@selector(isTabCanPressForIndex:)] && ![self.tabDataSource isTabCanPressForIndex:i]) {
        return;
    }
    

    self.index = i;
    [self reloadHighlight];
    [self scrollTagToIndex:i];
    [self markViewToIndex:i animatied:YES];

}

- (void)__setupFirstIndex
{
    NSInteger index = [self.tabDataSource respondsToSelector:@selector(preferTabIndex)]?[self.tabDataSource preferTabIndex]:0;
    self.index = index;
    [self scrollTagToIndex:index];
    [self markViewToIndex:index animatied:NO];
}

- (void)__setupMaskView
{


    if ([self needMarkView]) {
        self.markView = [[UIView alloc] init];
        self.markView.frame = CGRectMake(0, [self.tabDataSource respondsToSelector:@selector(markViewBottom)]?[self.tabDataSource markViewBottom]:-13, [self.tabDataSource markViewWidthForIndex:self.index], 2);

        self.markView.layer.cornerRadius = 1.0;
        self.markView.layer.masksToBounds = YES;
        self.markView.backgroundColor = [self.tabDataSource markViewColorForIndex:self.index];
        [self addSubview:self.markView];
        self.markViewScroll = YES;
    }
}

//点击 和初始化使用
- (void)markViewToIndex:(NSInteger)index animatied:(BOOL)animated
{
    if  (index >= self.tagViewsCache.count || index < 0) {
        return;
    }

    if (![self needMarkView]) {
        [self reloadHighlight];
    } else {
        SPPageTagView *nextTagView = self.tagViewsCache[index];
        if (animated) {
            __weak SPTagBarScrollView *wScrollView =self;
            [UIView animateWithDuration:0.3 animations:^{
                __weak SPTagBarScrollView *bScrollView =wScrollView;

                bScrollView.markView.center = CGPointMake(nextTagView.center.x, bScrollView.markView.center.y);
            } completion:^(BOOL finished) {
                __weak SPTagBarScrollView *bScrollView =wScrollView;
                [bScrollView reloadHighlight];
            }];
        } else {

            SPPageTagView *nextTagView = self.tagViewsCache[index];
            self.markView.center = CGPointMake(nextTagView.center.x, self.markView.center.y);
            [self reloadHighlight];

        }

    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

}

- (void)reloadHighlightToIndex:(NSInteger)index
{
    self.index = index;
    [self reloadHighlight];
}

- (void)reloadHighlight
{
    for (int i=0;i<self.tagViewsCache.count;i++) {
        SPPageTagView *view = (SPPageTagView *)self.tagViewsCache[i];
        if (i == self.index) {
            [view highlightTagView];
        } else {
            [view unhighlightTagView];
        }
    }

}

- (BOOL)needMarkView
{
    return [self.tabDataSource respondsToSelector:@selector(needMarkView)] && [self.tabDataSource needMarkView];
}

- (void)scrollTagToIndex:(NSUInteger)toIndex
{
    if (self.tagViewsCache.count <= toIndex || self.contentSize.width < self.frame.size.width) {
        return;
    }

    SPPageTagView *nextTagView = self.tagViewsCache[toIndex];

    CGFloat tagExceptInScreen = [UIScreen mainScreen].bounds.size.width - nextTagView.frame.size.width;
    CGFloat tagPaddingInScreen = tagExceptInScreen / 2.0;
    CGFloat offsetX = MAX(0, MIN(nextTagView.frame.origin.x - tagPaddingInScreen, self.tagViewsCache.lastObject.frame.origin.x - tagExceptInScreen));

    CGPoint nextPoint = CGPointMake(offsetX, 0);

    //the last one
    if (toIndex == self.tagViewsCache.count - 1 && toIndex != 0) {
        nextPoint.x = self.contentSize.width - self.frame.size.width + self.contentInset.right;
    }

    [self setContentOffset:nextPoint animated:YES];
}

-(void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    [super setContentOffset:contentOffset animated:animated];
}

//pageview滑动的接口
- (void)markViewScrollToContentRatio:(CGFloat)contentRatio
{
    if (!self.markViewScroll) {
        return;
    }

    int fromIndex = ceil(contentRatio)-1;

    if ( fromIndex <0 || self.tagViewsCache.count <= fromIndex+1) {
        return;
    }
    
    CGFloat fromWidth =  [self.tabDataSource markViewWidthForIndex:fromIndex];
    CGFloat toWidth =  [self.tabDataSource markViewWidthForIndex:fromIndex+1];
    if (fromWidth != toWidth) {
        [self setMarkViewWidth:fromWidth + (toWidth-fromWidth)*(contentRatio-fromIndex)];
    }

    SPPageTagView *curTagView = self.tagViewsCache[fromIndex];
    SPPageTagView *nextTagView = self.tagViewsCache[fromIndex+1];


    SPPageTagView *firstTagView = self.tagViewsCache.firstObject;
    SPPageTagView *lastTagView = self.tagViewsCache.lastObject;
    CGFloat moveCenterX = curTagView.center.x+(contentRatio-fromIndex)*(nextTagView.center.x-curTagView.center.x);
    if (moveCenterX <= firstTagView.center.x) {
        moveCenterX = firstTagView.center.x;
    } else if (moveCenterX >= lastTagView.center.x) {
        moveCenterX = lastTagView.center.x;
    }

    self.markView.center = CGPointMake(moveCenterX, self.markView.center.y);
}

- (void)setMarkViewWidth:(CGFloat)width
{
    CGRect frame = self.markView.frame;
    self.markView.frame = CGRectMake(frame.origin.x, frame.origin.y, width, frame.size.height);
}

- (void)markViewScrollToIndex:(NSInteger)index
{
    if (!self.markViewScroll) {
        return;
    }

    if  (index >= self.tagViewsCache.count || index < 0) {
        return;
    }

    SPPageTagView *curTagView = self.tagViewsCache[index];
    [self setMarkViewWidth:[self.tabDataSource markViewWidthForIndex:index]];
    self.markView.center = CGPointMake(curTagView.center.x, self.markView.center.y);
}

-(void)reloadTabBarTitleColor
{
    for (int i=0;i<[self.tabDataSource numberOfTab];i++) {
        SPPageTagTitleView *titleView = (SPPageTagTitleView *)self.tagViewsCache[i];
        if ([self.tabDataSource respondsToSelector:@selector(titleColorForIndex:)]) {
            titleView.normalTitleColor = [self.tabDataSource titleColorForIndex:i];
        }
        if ([self.tabDataSource respondsToSelector:@selector(titleHighlightColorForIndex:)]) {
            titleView.highlightedTitleColor = [self.tabDataSource titleHighlightColorForIndex:i];
        }
    }

}

@end
