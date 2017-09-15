//
//  SPPageContentView.h
//  Radio
//
//  Created by sparrow on 09/02/2017.
//  Copyright © 2017 qzone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPPageContentView : UIScrollView<UIScrollViewDelegate>

- (CGRect)calcVisibleViewControllerFrameWithIndex:(NSInteger)index;
- (CGPoint)calOffsetWithIndex:(NSInteger)index width:(CGFloat)width maxWidth:(CGFloat)maxWidth;
- (NSInteger)calcIndexWithOffset:(CGFloat)offset width:(CGFloat)width;
- (void)updateScrollViewLayoutWithSize:(CGSize)size;

@end
