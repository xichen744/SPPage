//
//  SPPageController.h
//  Radio
//
//  Created by sparrow on 25/11/2016.
//  Copyright © 2016 qzone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPPageProtocol.h"

/**
 *
 *   替换系统的pageController
 *
 */
@interface SPPageController : UIViewController

@property (nonatomic, weak) id <SPPageControllerDelegate> delegate;
@property (nonatomic, weak) id <SPPageControllerDataSource> dataSource;

@property (nonatomic, assign, readonly) NSInteger currentPageIndex;

//必须在reloadpage之前 把datasource 回调的pagecount变了
- (void)reloadPage;

//用于非交互切换接口
- (void)showPageAtIndex:(NSInteger)index animated:(BOOL)animated;
//在tab高度可变的情况，需要去动态修改 tableview的contentinset
- (void)resizePageAtIndex:(NSInteger)index offset:(CGFloat)offset isNeedChangeOffset:(BOOL)isNeedChangeOffset;

- (NSInteger)indexOfController:(UIViewController *)vc;

- (void)updateCurrentIndex:(NSInteger)index;

@end
