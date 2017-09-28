//
//  SPPageContentView.m
//  Radio
//
//  Created by sparrow on 09/02/2017.
//  Copyright © 2017 qzone. All rights reserved.
//

#import "SPPageContentView.h"
#import "SPPageProtocol.h"

@interface SPPageContentView()


@property (nonatomic, weak) id <SPPageControllerDataSource> dataSource;

@end


@implementation SPPageContentView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self __configure];
    }

    return self;
}

- (void)__configure
{
    self.autoresizingMask = (0x1<<6) - 1;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.pagingEnabled = YES;
    self.backgroundColor = [UIColor clearColor];
    self.scrollsToTop = NO;
    
#ifdef __IPHONE_11_0
    if ([UIDevice currentDevice].systemVersion.floatValue >= 11.0) {// ios11 苹果加了一个安全区域 会自动修改scrollView的contentOffset
        self.contentInsetAdjustmentBehavior =  UIScrollViewContentInsetAdjustmentNever;
    }
#endif
}

- (void)addSubview:(UIView *)view
{
    if (![self.subviews containsObject:view]){
        [super addSubview:view];
    }
}

- (CGRect)calcVisibleViewControllerFrameWithIndex:(NSInteger)index
{
    CGFloat offsetX = 0.0;
    offsetX = index * self.frame.size.width;
    return CGRectMake(offsetX, 0, self.frame.size.width, self.frame.size.height);
}

- (void)updateScrollViewLayoutWithSize:(CGSize)size
{
    CGSize oldContentSize = self.contentSize;
    if (size.width!= oldContentSize.width || size.height!= oldContentSize.height) {
        self.contentSize = size;
    }
}

- (CGPoint)calOffsetWithIndex:(NSInteger)index width:(CGFloat)width maxWidth:(CGFloat)maxWidth
{
    CGFloat offsetX = ((index) * width);

    if (offsetX < 0 ){
        offsetX = 0;
    }

    if( maxWidth > 0.0 &&
       offsetX > maxWidth - width)
    {
        offsetX = maxWidth - width;
    }

    return CGPointMake(offsetX, 0);
}

- (NSInteger)calcIndexWithOffset:(CGFloat)offset width:(CGFloat)width
{
    NSInteger startIndex = (NSInteger)offset/width;
    if (startIndex < 0) {
        startIndex = 0;
    }

    return startIndex;
}

@end
