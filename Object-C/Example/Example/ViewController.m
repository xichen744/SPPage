//
//  ViewController.m
//  Example
//
//  Created by sparrow on 30/07/2017.
//  Copyright © 2017 tencent. All rights reserved.
//

#import "ViewController.h"
#import "TestCoverSubController.h"
#import "SPPageController.h"

#define CoverHeight 245

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.minYPullUp = KNAVIGATIONANDSTATUSBARHEIGHT;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBarHidden=NO;
    self.navigationItem.title = self.navTitle?:@"SPPage";
    if (!self.navTitle)
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
}

- (NSString *)titleForIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"TAB%zd", index];
}

- (BOOL)needMarkView
{
    return YES;
}

- (UIView *)preferCoverView
{
    UIView *view = [[UIView alloc] initWithFrame:[self preferCoverFrame]];
    view.backgroundColor = [UIColor blackColor];

    return view;
}

- (CGFloat)preferTabY
{
    return CoverHeight;
}

- (CGRect)preferCoverFrame
{
    return CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CoverHeight);
}

- (UIViewController *)controllerAtIndex:(NSInteger)index
{
    TestCoverSubController *coverController = [[TestCoverSubController alloc] init];
    coverController.view.frame = [self preferPageFrame];

    if (index == 0) {
        coverController.view.backgroundColor = [UIColor greenColor];
    } else if (index == 1) {
        coverController.view.backgroundColor = [UIColor orangeColor];
    } else {
        coverController.view.backgroundColor = [UIColor redColor];
    }

    return coverController;

}
-(NSInteger)preferPageFirstAtIndex {
    return 1;
}

-(BOOL)isSubPageCanScrollForIndex:(NSInteger)index
{
    return YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}

- (NSInteger)numberOfControllers
{
    return 8;
}

-(BOOL)isPreLoad {
    return NO;
}



@end
