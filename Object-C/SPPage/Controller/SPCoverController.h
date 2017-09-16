//
//  SPCoverViewControllerViewController.h
//  Radio
//
//  Created by sparrow on 19/01/2017.
//  Copyright © 2017 qzone. All rights reserved.
//

#import "SPTabController.h"
#import "SPCoverProtocol.h"


typedef NS_ENUM(NSInteger, CoverScrollStyle) {
    CoverScrollStyleHeight = 0,//需要做Cover的背景图片拉伸的选择这个 否则选择下面的Style
    CoverScrollStyleTop = 1,

};

@interface SPCoverController : SPTabController <SPCoverDataSource>

- (CoverScrollStyle)preferCoverStyle;

@end
