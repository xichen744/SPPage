//
//  SPCoverViewControllerViewController.m
//  Radio
//
//  Created by sparrow on 19/01/2017.
//  Copyright © 2017 qzone. All rights reserved.
//

#import "SPCoverController.h"

@interface SPCoverController () <SPPageControllerDelegate>

@property (nonatomic, strong) UIView *__coverView;

@end

@implementation SPCoverController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __loadCoverView];
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)__reloadCoverView
{
    [self.__coverView removeFromSuperview];
    [self __loadCoverView];
}

- (void)__loadCoverView
{
    self.__coverView = [self preferCoverView];
    self.__coverView.frame = [self preferCoverFrame];
    [self.view addSubview:self.__coverView];
}

- (void)reloadData
{
    [super reloadData];
    [self __reloadCoverView];
}

- (CoverScrollStyle)preferCoverStyle
{
    return CoverScrollStyleHeight;
}

#pragma SPPageControllerDelegate

- (void)scrollWithPageOffset:(CGFloat)offset index:(NSInteger)index
{

    [super scrollWithPageOffset:offset index:index];

    CGFloat realOffset = offset+[self pageTopAtIndex:index];
    CGFloat top = [self preferTabY]-realOffset;
    if (realOffset >= 0) {
        if (top <= self.minYPullUp) {
            top = self.minYPullUp;
        }
    } else {
        if (top >= self.maxYPullDown) {
            top = self.maxYPullDown;
        }
    }
    
    realOffset = [self preferTabY] - top;
    
    UIView *coverView = (UIView *)self.__coverView;

    CGRect frame = coverView.frame;
    
    if ([self preferCoverStyle]==CoverScrollStyleHeight) {
        CGFloat coverHeight = [self preferCoverFrame].size.height - realOffset;
        if (coverHeight >= 0) {
            coverView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, coverHeight);

        } else {
            coverView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 0);
        }
    } else {
        CGFloat coverTop = [self preferCoverFrame].origin.y - realOffset;
        
        if (coverTop >= [self preferCoverFrame].origin.y-[self preferCoverFrame].size.height) {
              coverView.frame = CGRectMake(frame.origin.x, coverTop, frame.size.width, frame.size.height);

        } else {
            coverView.frame = CGRectMake(frame.origin.x,  [self preferCoverFrame].origin.y-[self preferCoverFrame].size.height, frame.size.width, frame.size.height);
        }
    }

}


#pragma SPPageControllerDataSource
-(CGFloat)pageTopAtIndex:(NSInteger)index
{
    CGFloat pageTop = [super pageTopAtIndex:index];
    return pageTop > [self preferCoverFrame].origin.y+ [self preferCoverFrame].size.height?pageTop: [self preferCoverFrame].origin.y+ [self preferCoverFrame].size.height;
}

#pragma SPCoverProtocol

- (UIView *)preferCoverView
{
    return nil;
}

- (CGRect)preferCoverFrame
{
    return CGRectZero;
}

@end
