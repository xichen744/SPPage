//
//  SPTabController.h
//  Radio
//
//  Created by sparrow on 16/01/2017.
//  Copyright © 2017 qzone. All rights reserved.
//

#import "SPPageProtocol.h"
#import "SPTabProtocol.h"

@interface SPTabController : UIViewController <SPPageControllerDataSource, SPPageControllerDelegate, SPTabDataSource, SPTabDelegate>
//优先展示在哪个页面，reloadData后 会调用这个方法。
- (NSInteger)preferPageFirstAtIndex;

//适用于TAB纵向滑动的情况
@property (nonatomic, assign) CGFloat maxYPullDown;//往下拉 tab的最大值
@property (nonatomic, assign) CGFloat minYPullUp;//拉上拉 tab的最小值

//单一tab 是否需要展示
- (BOOL)preferSingleTabNotShow;

//自定义TABView,最好遵循SPTabDelegate，SPTabDataSource,要不有些情况要重写
- (UIView *)customTabView;
//适用于Tab高度 变化的情况
- (void)reloadTabH:(BOOL)isTabScroll;
//需要完全刷新页面时调用这个接口
- (void)reloadData;

@end
