//
//  SPPageProtocol.swift
//  SPPage
//
//  Created by GodDan on 2018/3/4.
//  Copyright © 2018年 GodDan. All rights reserved.
//

import UIKit


@objc protocol SPPageControllerDelegate :class{
    
   @objc optional func pageviewControllerWillTransition(pageVC:SPPageController, fromVC:UIViewController, toVC:UIViewController)
   @objc optional func pageviewControllerDidTransition(pageVC:SPPageController, fromVC:UIViewController, toVC:UIViewController)
   @objc optional func pageviewControllerWillLeave(pageVC:SPPageController, fromVC:UIViewController, toVC:UIViewController)
   @objc optional func pageviewControllerDidLeave(pageVC:SPPageController, fromVC:UIViewController, toVC:UIViewController)
   @objc optional func scrollViewContentOffsetWithRatio(ratio:CGFloat, draging:Bool)
   @objc optional func scrollWithPageOffset(pageOffset:CGFloat, index:NSInteger)
   @objc optional func willChangeInit()
   @objc optional func cannotScrollWithPageOffset() -> Bool

}


@objc protocol SPPageControllerDataSource:class {
    
    func controller(index:NSInteger) ->UIViewController
    func numberOfControllers() -> NSInteger
    func preferPageFrame() -> CGRect
    func preferPageFirstAtIndex() -> NSInteger
    @objc optional func pageTopAtIndex(index:NSInteger) -> CGFloat
    @objc optional func screenEdgePanGestureRecognizer() -> UIScreenEdgePanGestureRecognizer?
    @objc optional func isPreLoad() -> Bool
    @objc optional func isSubPageCanScrollForIndex(index:NSInteger) -> Bool
    
}


protocol SPPageSubControllerDataSource :class{
    func preferScrollView() -> UIScrollView?
}
