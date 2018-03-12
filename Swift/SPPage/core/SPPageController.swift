//
//  SPPageController.swift
//  SPPage
//
//  Created by GodDan on 2018/3/1.
//  Copyright © 2018年 GodDan. All rights reserved.
//

import UIKit

let iPhoneX:Bool! = CGSize.init(width: 1125, height: 2436).equalTo((UIScreen.main.currentMode?.size)!)
let kScreenWidth:CGFloat = UIScreen.main.bounds.size.width
let kScreenHeight:CGFloat = UIScreen.main.bounds.size.height
let kStatusBarHeight:CGFloat = iPhoneX ? 44.0:22.0
let kNavigationAndStatusBarHeight:CGFloat = kStatusBarHeight + 44.0


class SPPageController: UIViewController,UIScrollViewDelegate {
    
    weak var delegate:SPPageControllerDelegate?
    weak var dataSource:SPPageControllerDataSource?
    
    private(set) var currentPageIndex:NSInteger!
    private var memCacheDic =  Dictionary<Int,UIViewController>()
    private var lastContentOffset = Dictionary<Int,CGFloat>()
    private var lastContentSize = Dictionary<Int, CGFloat>()
    private var scrollView:SPPageContentView!
    private var lastSelectedIndex:NSInteger!
    private var guessToIndex:NSInteger!
    private var originOffset:CGFloat!
    private var firstWillAppear:Bool! = true
    private var firstWillLayoutSubViews:Bool! = true
    private var firstDidAppear:Bool! = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currentPageIndex = self.dataSource?.preferPageFirstAtIndex()
        self.lastSelectedIndex = self.currentPageIndex
        self.view.backgroundColor = UIColor.clear
        self.configScrollView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.firstWillAppear {
            self.delegate?.pageviewControllerWillLeave?(pageVC: self, fromVC: self.controller(index: self.lastSelectedIndex), toVC: self.controller(index: self.currentPageIndex))
            
            if self.dataSource?.screenEdgePanGestureRecognizer?() != nil {
                self.scrollView.panGestureRecognizer.require(toFail: (self.dataSource?.screenEdgePanGestureRecognizer?())!)

            } else {
                if self.screenEdgePanGestureRecognizer() != nil {
                    self.scrollView.panGestureRecognizer.require(toFail: self.screenEdgePanGestureRecognizer()!)
                }

            }
            
            self.firstWillAppear = false
            self.updateScrollViewLayoutIfNeed()
        }
        
        self.controller(index: self.currentPageIndex).beginAppearanceTransition(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.firstDidAppear {
            self.delegate?.willChangeInit?()
            
            self.delegate?.pageviewControllerDidLeave?(pageVC: self, fromVC: self.controller(index: self.lastSelectedIndex), toVC: self.controller(index: self.currentPageIndex))
            
            self.firstDidAppear = false
        }
        
        self.controller(index: self.currentPageIndex).endAppearanceTransition()
    }
    
    private func updateScrollViewLayoutIfNeed() {
        if self.scrollView.frame.size.width > 0 {
            self.scrollView.setItem(item: self.dataSource!)
            
            let newOffset:CGPoint = self.scrollView.calOffsetWithIndex(index: self.currentPageIndex)
            if !newOffset.equalTo(self.scrollView.contentOffset) {
                self.scrollView.contentOffset = newOffset
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if self.firstWillLayoutSubViews {
            self.updateScrollViewLayoutIfNeed()
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    private func removeFromParentViewController(controller:UIViewController) {
        controller.willMove(toParentViewController: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParentViewController()
    }
    
    private func pageCount() -> NSInteger {
        return  (self.dataSource?.numberOfControllers())!
    }
    
   private func controller(index:NSInteger) -> UIViewController {
        if (self.memCacheDic[index] == nil) {
            let uiviewController = self.dataSource?.controller(index: index)
            if (uiviewController != nil) {
                if (self.dataSource?.isSubPageCanScrollForIndex?(index: index))! {
                    uiviewController?.view.isHidden = false
                } else {
                    uiviewController?.view.isHidden = true
                }
                
                self.bindController(subVC: uiviewController!, index: index)
                
                self.memCacheDic[index] = uiviewController
                self.addVisibleViewContorller(vc: uiviewController!, index: index)
            }
            
            
      
        }
        
        return self.memCacheDic[index]!
    }
    
    func addVisibleViewContorller(vc:UIViewController,index:NSInteger)  {
        
        let childFrame = self.scrollView.calcVisibleViewControllerFrameWithIndex(index: index)
        self.addChildViewController(childController: vc, frame: childFrame)

    }
    
    func addChildViewController(childController:UIViewController,frame:CGRect) {
        if !self.childViewControllers.contains(childController) {
            self.addChildViewController(childController)
            self.didMove(toParentViewController: childController)
            childController.view.frame = frame
            self.scrollView.addSubview(childController.view)
        }
    }
    
    func reloadPage() {
        self.clearMemory()
        self.currentPageIndex = self.dataSource?.preferPageFirstAtIndex()
        self.updateScrollViewLayoutIfNeed()
        self.showPage(index: self.currentPageIndex, animated: true)
        
    }
    
    private func clearMemory () {
        for view in self.scrollView.subviews {
            view.removeFromSuperview()
        }
        
        self.lastContentSize.removeAll()
        self.lastContentOffset.removeAll()
        
        if self.memCacheDic.count > 0 {
            self.clearObserver()
            
            let tmpArray = [UIViewController](self.memCacheDic.values)
            self.memCacheDic.removeAll()
            for (vc) in tmpArray {
                self.removeFromParentViewController(controller: vc)
            }
        }
        
    }
    
    deinit {
        self.clearMemory()
        
    }
    
    private func clearObserver () {
        for (_, controller) in self.memCacheDic {
            if let tempVC = controller as? SPPageSubControllerDataSource {
                if let subScrollView = tempVC.preferScrollView() {
                    subScrollView.removeObserver(self, forKeyPath: "contentOffset")
                }
            }
        }
    }
    
    private func configScrollView () {
        self.scrollView = SPPageContentView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
    }
    
    func screenEdgePanGestureRecognizer() -> UIScreenEdgePanGestureRecognizer? {
        if let gestureRecognizers = self.navigationController?.view.gestureRecognizers {
            for recognizer:UIGestureRecognizer? in gestureRecognizers {
                if recognizer is UIScreenEdgePanGestureRecognizer {
                    return recognizer as? UIScreenEdgePanGestureRecognizer
                }
            }
        }
        
        return nil
    }
    
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    // scrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.scrollView.isDragging {
            let offset = scrollView.contentOffset.x
            let width = scrollView.frame.size.width
            let lastGuessIndex = self.guessToIndex >= 0 ? self.guessToIndex:self.currentPageIndex
            if self.originOffset < offset {
                self.guessToIndex = NSInteger(ceil(offset/width))
            } else {
                self.guessToIndex = NSInteger( floor(offset/width))
            }
            
            let maxCount = self.pageCount()
            
            if ((self.guessToIndex != self.currentPageIndex && !scrollView.isDecelerating) || scrollView.isDecelerating)  && lastGuessIndex != self.guessToIndex && self.guessToIndex >= 0 && self.guessToIndex < maxCount {
                
                self.delegate?.willChangeInit?()
                
                self.delegate?.pageviewControllerWillTransition?(pageVC: self, fromVC: self.controller(index: self.guessToIndex), toVC: self.controller(index: self.currentPageIndex))
                
                if (self.dataSource?.isPreLoad?())! {
                    self.controller(index: self.guessToIndex).beginAppearanceTransition(true, animated: true)
                    
                    if lastGuessIndex == self.currentPageIndex {
                        self.controller(index: self.currentPageIndex).beginAppearanceTransition(false, animated: true)
                    }
                    
                    if lastGuessIndex != self.currentPageIndex &&
                        lastGuessIndex! >= 0 &&
                        lastGuessIndex! < maxCount{
                        self.controller(index: lastGuessIndex!).beginAppearanceTransition(false, animated: true)
                        self.controller(index: lastGuessIndex!).endAppearanceTransition()
                    }
                }
            }
            self.delegate?.scrollViewContentOffsetWithRatio?(ratio: scrollView.contentOffset.x/scrollView.frame.size.width, draging: true)
            
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !scrollView.isDecelerating {
            self.originOffset = scrollView.contentOffset.y
            self.guessToIndex = self.currentPageIndex
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.delegate?.scrollViewContentOffsetWithRatio?(ratio: targetContentOffset.pointee.x/scrollView.frame.size.width, draging: false)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.updatePageAfterDraging()
    }
    
    private func updatePageAfterDraging () {
        let newIndex:NSInteger = self.scrollView.calcIndex()
        let oldIndex:NSInteger = self.currentPageIndex
        
        self.currentPageIndex = newIndex
        self.lastSelectedIndex = self.currentPageIndex
        
        let newVc = self.controller(index: newIndex)
        let oldVC = self.controller(index: oldIndex)
        if newIndex == oldIndex {
            if self.guessToIndex >= 0 && self.guessToIndex < self.pageCount()  && (self.dataSource?.isPreLoad?())!{
                oldVC.beginAppearanceTransition(true, animated: true)
                oldVC.endAppearanceTransition()
                newVc.beginAppearanceTransition(false, animated: true)
                newVc.endAppearanceTransition()
            }
        } else {
            if !(self.dataSource?.isPreLoad?())! {
                oldVC.beginAppearanceTransition(false, animated: true)
                newVc.beginAppearanceTransition(true, animated: true)
            }
            oldVC.endAppearanceTransition()
            newVc.endAppearanceTransition()
        }
        
        self.originOffset = self.scrollView.contentOffset.x
        self.guessToIndex = self.currentPageIndex
        
        self.delegate?.pageviewControllerDidTransition?(pageVC: self, fromVC: self.controller(index: self.lastSelectedIndex), toVC: newVc)
    }
    
    //非交互切换
    
    func showPage(index:NSInteger, animated:Bool) {
        if index < 0 || index >= self.pageCount() {
            return
        }
        
        if self.scrollView.frame.size.width > 0 && self.scrollView.contentSize.width > 0 {
            
            
            let scrollBeginAnimation = { [weak self]() -> Void in
                
                if let weakSelf = self {
                    weakSelf.controller(index: weakSelf.currentPageIndex).beginAppearanceTransition(true, animated: animated)
                    
                    if weakSelf.currentPageIndex != weakSelf.lastSelectedIndex {
                        weakSelf.controller(index: weakSelf.lastSelectedIndex).beginAppearanceTransition(false, animated: animated)
                    }
                }
                
            }
            
            let scrollAnimationing = { [weak self]() -> Void in
                
                if let weakSelf = self {
                    weakSelf.scrollView.setContentOffset(weakSelf.scrollView.calOffsetWithIndex(index: weakSelf.currentPageIndex), animated: false)
                    
                }
                
            }
            
            let scrollEndAnimation = { [weak self]() -> Void in
                
                if let weakSelf = self {
                    weakSelf.controller(index: weakSelf.currentPageIndex).endAppearanceTransition()
                    
                    if weakSelf.currentPageIndex != weakSelf.lastSelectedIndex {
                        weakSelf.controller(index: weakSelf.lastSelectedIndex).endAppearanceTransition()
                    }
                    
                    weakSelf.delegate?.pageviewControllerDidLeave?(pageVC: weakSelf, fromVC: weakSelf.controller(index: weakSelf.lastSelectedIndex), toVC: weakSelf.controller(index: weakSelf.currentPageIndex))
                }
                
            }
            
            self.delegate?.willChangeInit?()
           
            self.lastSelectedIndex = self.currentPageIndex
            self.currentPageIndex = index
            let currentVC:UIViewController = self.controller(index: self.currentPageIndex)
            let lastSelectedVC:UIViewController = self.controller(index: self.lastSelectedIndex)
            
            self.delegate?.pageviewControllerWillLeave?(pageVC: self, fromVC: lastSelectedVC, toVC: currentVC)
            scrollBeginAnimation()
            
            if (animated) {
                
                if self.lastSelectedIndex == self.currentPageIndex {
                    scrollAnimationing()
                    scrollEndAnimation()
                    return
                }
                
                let oldSelectedIndex:NSInteger! = self.lastSelectedIndex
                let oldSeletedVC:UIViewController = self.controller(index: oldSelectedIndex)
                
                let lastView:UIView = lastSelectedVC.view
                let currentView:UIView = currentVC.view
                let oldSelectedView:UIView = oldSeletedVC.view
                
                let backgroundIndex = self.scrollView.calcIndex()
                var backgroundView:UIView? = nil
                
                
                if let oldAnitmatonKey = oldSelectedView.layer.animationKeys(),  let lastAnimationKey = lastView.layer.animationKeys() {
                    
                    if  oldAnitmatonKey.count > 0 && lastAnimationKey.count > 0 && backgroundIndex != self.currentPageIndex && backgroundIndex != self.lastSelectedIndex {
                        backgroundView = self.controller(index: backgroundIndex).view
                        backgroundView?.isHidden = true
                    }
                }
                
                //初始还原
                self.scrollView.layer.removeAllAnimations()
                oldSelectedView.layer.removeAllAnimations()
                lastView.layer.removeAllAnimations()
                currentView.layer.removeAllAnimations()
            
                self.moveBackToOriginPosition(view: oldSelectedView, index: oldSelectedIndex)
                
                self.scrollView.bringSubview(toFront: lastView)
                self.scrollView.bringSubview(toFront: currentView)
                
                lastView.isHidden = false
                currentView.isHidden = false
                
                let lastViewStartOrigin = lastView.frame.origin
                var currentViewStartOrigin = lastViewStartOrigin
                
                let offset = self.lastSelectedIndex < self.currentPageIndex ? self.scrollView.frame.size.width:-self.scrollView.frame.size.width
                currentViewStartOrigin.x += offset
                
                var lastViewAnimationOrigin  = lastViewStartOrigin
                lastViewAnimationOrigin.x -= offset
                let currentViewAnimationOrigin = lastViewStartOrigin
                let lastViewEndOrigin = lastViewStartOrigin
                let currentViewEndOrigin = currentView.frame.origin
                let pageSize:CGSize = self.scrollView.frame.size
                
                lastView.frame = CGRect.init(origin: lastViewStartOrigin, size: pageSize)
                currentView.frame = CGRect.init(origin: currentViewStartOrigin, size: pageSize)
                
                
                UIView.animate(withDuration: 0.3, animations: {
                    lastView.frame = CGRect.init(origin: lastViewAnimationOrigin, size: pageSize)
                    currentView.frame = CGRect.init(origin: currentViewAnimationOrigin, size: pageSize)
                }, completion: {[weak self] (finished) in
                    
                    if finished {
                        lastView.frame = CGRect.init(origin: lastViewEndOrigin, size: pageSize)
                        currentView.frame = CGRect.init(origin: currentViewEndOrigin, size: pageSize)
                        
                        backgroundView?.isHidden = false
                        
                        if let weakSelf = self {
                            weakSelf.moveBackToOriginPosition(view: currentView, index: weakSelf.currentPageIndex)
                            weakSelf.moveBackToOriginPosition(view: lastView, index: weakSelf.lastSelectedIndex)
                        }
                
                        scrollAnimationing()
                        scrollEndAnimation()
                        
                    }
            
                })
                
            } else {
                scrollAnimationing()
                scrollEndAnimation()
            }
            
            
            
            
        }
    }
    
    private func moveBackToOriginPosition(view:UIView, index:NSInteger) {
        if index < 0 || index >= self.pageCount() {
            return
        }
        
        let originPosition = self.scrollView.calOffsetWithIndex(index: index)
        if view.frame.origin.x != originPosition.x {
            view.frame = CGRect.init(origin: originPosition, size: view.frame.size)
        }
    }
    
    //KVO
    private func bindController(subVC:UIViewController, index:NSInteger) {
        
        if let tempVC = subVC as? SPPageSubControllerDataSource {
            if let subScrollView = tempVC.preferScrollView() {
                subScrollView.scrollsToTop = false
                subScrollView.tag = index
                if let pageTop = self.dataSource?.pageTopAtIndex?(index: index) {
                    subScrollView.contentInset.top = pageTop
                }
                
                if #available(OSX 11.0, *) {// ios11 苹果加了一个安全区域 会自动修改scrollView的contentOffset
                    subScrollView.contentInsetAdjustmentBehavior =  UIScrollViewContentInsetAdjustmentBehavior.never;
                }
                
                subScrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new,.initial], context: nil)
                subScrollView.contentOffset.x = -scrollView.contentInset.top
            }
        }
       
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let scrollView = object as? UIScrollView {
            if keyPath == "contentOffset" {
                if scrollView.tag != self.currentPageIndex {
                    return
                }
                
                if self.memCacheDic.count == 0 {
                    return
                }
                
                let index = scrollView.tag
                
                
                let isNotNeedChangeContentOffset:Bool = scrollView.contentSize.height < kScreenHeight-kNavigationAndStatusBarHeight && fabs(self.lastContentSize[index] ?? 0 - scrollView.contentSize.height) > 1.0
                
                if self.delegate?.cannotScrollWithPageOffset?() != nil && (self.delegate?.cannotScrollWithPageOffset?())! || isNotNeedChangeContentOffset {
                    if let contentOffset = self.lastContentOffset[index] {
                        scrollView.contentOffset.y = contentOffset
                    }
                } else {
                    self.lastContentOffset[index] = scrollView.contentOffset.y
                    self.delegate?.scrollWithPageOffset?(pageOffset: scrollView.contentOffset.y, index: index)
                }
                
                self.lastContentSize[index] = scrollView.contentSize.height

            }
          
        }
    }
    
    //indexOfController
    
    func indexOf(vc:UIViewController) -> Int {
        for (key,tempVc) in self.memCacheDic {
            if vc == tempVc {
                return key
            }
        }
        
        return -1
    }
    
}
