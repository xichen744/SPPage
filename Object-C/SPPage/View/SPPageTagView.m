//
//  SPMainTagView.m
//  Radio
//
//  Created by WealongCai on 15/12/10.
//  Copyright (c) 2015年 qzone. All rights reserved.
//

#import "SPPageTagView.h"


@interface SPPageTagView()
@property (nonatomic, assign, readwrite) BOOL isHighlighted;
@end


@implementation SPPageTagView

- (void)highlightTagView
{
    NSException *exception = [NSException exceptionWithName:@"Method no override Exception" reason:@"Method highlightTagView must be override!" userInfo:nil];
    @throw exception;
}

- (void)unhighlightTagView
{
    NSException *exception = [NSException exceptionWithName:@"Method no override Exception" reason:@"Method unhighlightTagView must be override!" userInfo:nil];
    @throw exception;
}


@end



@implementation SPPageTagTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.frame = frame;
        
        self.title = [UILabel new];
        self.title.backgroundColor = [UIColor clearColor];
        
        self.title.textAlignment = NSTextAlignmentCenter;
        self.title.frame = self.bounds;
        
        
        [self addSubview:self.title];
    }
    return self;
}



- (void)setHighlightedTitleColor:(UIColor *)highlightedTitleColor
{
    [super setHighlightedTitleColor:highlightedTitleColor];
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor
{
    [super setNormalTitleColor:normalTitleColor];
}


- (void)highlightTagView
{
    self.title.textColor = self.highlightedTitleColor;
    self.isHighlighted = YES;
}

- (void)unhighlightTagView
{
    self.title.textColor = self.normalTitleColor ;
    self.isHighlighted = NO;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_title sizeToFit];
    _title.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

@end


