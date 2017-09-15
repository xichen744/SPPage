//
//  SPCoverProtocol.h
//  Example
//
//  Created by sparrow on 30/07/2017.
//  Copyright © 2017 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SPCoverDataSource <NSObject>
@required
- (UIView *)preferCoverView;//不用管什么时机去生成coverview
- (CGRect)preferCoverFrame;

@end
