//
//  SPTabProtocol.h
//  Example
//
//  Created by sparrow on 30/07/2017.
//  Copyright © 2017 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SPTabDataSource <NSObject>

@required
- (NSString *)titleForIndex:(NSInteger)index;

@optional
- (UIColor *)titleColorForIndex:(NSInteger)index;
- (UIColor *)titleHighlightColorForIndex:(NSInteger)index;
- (UIFont *)titleFontForIndex:(NSInteger)index;
- (NSInteger)numberOfTab;
- (CGFloat)preferTabY;
- (CGFloat)preferTabX;
- (CGFloat)preferTabHAtIndex:(NSInteger)index;//假设每一个tab高度都可变的情况
- (CGFloat)preferTabW;
- (CGFloat)tabWidthForIndex:(NSInteger)index;
- (CGFloat)preferTabLeftOffset;
- (UIColor *)tabBackgroundColor;
- (CGFloat)tabTopForIndex:(NSInteger)index;//默认是0
- (NSInteger)preferTabIndex;

- (CGFloat)markViewWidthForIndex:(NSInteger)index;
- (UIColor *)markViewColorForIndex:(NSInteger)index;
- (CGFloat)markViewBottom;
- (BOOL)needMarkView;

- (BOOL)isTabCanPressForIndex:(NSInteger)index;

@end

@protocol SPTabDelegate <NSObject>
@optional
- (void)didPressTabForIndex:(NSInteger)index;//页面切换已在SPTabcontroller 实现

@end
