//
//  SPTabController.swift
//  SPPage
//
//  Created by GodDan on 2018/3/11.
//  Copyright © 2018年 GodDan. All rights reserved.
//

import UIKit

class SPTabController : UIViewController,SPPageControllerDelegate,SPPageControllerDataSource,SPTabDelegate,SPTabDataSource {
    
    var maxYPullDown:CGFloat = kScreenHeight
    var minYPullUp: CGFloat = 64
    
    private var tabView:UIView?
    private var pageVC:SPPageController!
    private var _cannotScrollWithPageOffset:Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPage()
        self.setupTabBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self._cannotScrollWithPageOffset = false
        self.pageVC.beginAppearanceTransition(true, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.pageVC.endAppearanceTransition()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self._cannotScrollWithPageOffset = true
        self.pageVC.beginAppearanceTransition(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.pageVC.endAppearanceTransition()
    }
    
    func preferSingleTabNotShow() -> Bool {
        return false
    }
    
    func customView() -> UIView? {
        return nil
    }
    
    func reloadData() {
        self.reloadPage()
        self.reloadTab()
    }
    
    private func reloadTab() {
        self.tabView?.removeFromSuperview()
        self.tabView = nil
        self.setupTabBar()
    }
    
    private func reloadPage() {
        self.pageVC.view.frame = self.preferPageFrame()
        self.pageVC.reloadPage()
    }
    
    private func setupPage() {
        self.pageVC = SPPageController()
        self.pageVC.dataSource = self
        self.pageVC.delegate = self
        
        self.pageVC.view.frame = self.preferPageFrame()
        self.addChildViewController(self.pageVC)
        self.view.addSubview(self.pageVC.view)
        self.pageVC.didMove(toParentViewController: self)
        
    }
    
    private func setupTabBar() {
        if self.preferSingleTabNotShow() && self.numberOfControllers() <= 1 {
            return
        }
        
        self.tabView = self.customView() ?? SPTagBarScrollView(frame: self.preferTabFrame(index: self.pageVC.currentPageIndex), tabDelagate: self, tabDataSource: self)
    
        self.view.addSubview(self.tabView!)
    }
    
    private func scrollViewOffset(index:NSInteger) -> CGFloat {
        return self.preferTabFrame(index: index).origin.y - (self.tabView?.frame.origin.y)! - self.pageTopAtIndex(index:index)
    }
    
    private func tabDragWithOffset(offset:CGFloat) {
        self.tabView?.frame.origin.y = self.tabScrollTopWithContentOffset(offset: offset)
    }
    
    
    func tabScrollTopWithContentOffset(offset:CGFloat) -> CGFloat {
        var top:CGFloat = self.preferTabFrame(index: self.pageVC.currentPageIndex).origin.y - offset
        if offset >=  0 {
            if top <= self.minYPullUp {
                top = self.minYPullUp
            }
        } else {
            if top >= self.maxYPullDown {
                top = self.maxYPullDown
            }
        }
        
        return top
    }
    
    private func changeToSubControllerOffset(toVc:UIViewController?, isDelay:Bool) {
        if toVc == nil || self.numberOfControllers() <= 1 {
            self._cannotScrollWithPageOffset = false
            return
        }
        
        if toVc is SPPageSubControllerDataSource {
            if let tempVC = toVc as? SPPageSubControllerDataSource {
                let newIndex =  self.pageVC.indexOf(vc:tempVC as! UIViewController)
                let pageTop = self.pageTopAtIndex(index: newIndex)
                let top = self.tabScrollTopWithContentOffset(offset: (tempVC.preferScrollView()?.contentOffset.y)!+pageTop)
                if fabs(top-(self.tabView?.frame.origin.y)!) > 0.1 {
                    let scrollOffset = self.scrollViewOffset(index: newIndex)
                    self._cannotScrollWithPageOffset = false
                    tempVC.preferScrollView()?.contentOffset.y = scrollOffset
                } else {
                    self._cannotScrollWithPageOffset = false
                }
                
            }
        } else {
            self._cannotScrollWithPageOffset = false

        }
    }
    
    // SPPageDataSource
    
    func pageTopAtIndex(index: NSInteger) -> CGFloat {
        return self.preferTabFrame(index: index).origin.y + self.preferTabFrame(index: index).size.height -  self.preferPageFrame().origin.y
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
    
    func preferPageFirstAtIndex() -> NSInteger {
        
        return 0
    }
    
    func controller(index: NSInteger) -> UIViewController {
        return UIViewController.init()
    }
    
    func numberOfControllers() -> NSInteger {
        return 0
    }
    
    func preferPageFrame() -> CGRect {
        return CGRect.init(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
    }
    
    func isPreLoad() -> Bool {
        return false
    }

    func isSubPageCanScrollForIndex(index: NSInteger) -> Bool {
        return true
    }
    
    // SPTabDataSource
    func title(index: NSInteger) -> String {
        return ""
    }
    
    func numberOfTab() -> NSInteger {
        return self.numberOfControllers()
    }
    
    func preferTabFrame(index: NSInteger) -> CGRect {
        return CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 40)
    }
    
    func tabTopForIndex(index: NSInteger) -> CGFloat {
        return 0
    }
    
    func tabWidth(index: NSInteger) -> CGFloat {
        if self.title(index: index).count <= 3 {
            return 73
        } else {
            return 105
        }
    }
    
    func titleColor(index: NSInteger) -> UIColor {
        return UIColor.black
    }
    
    func titleHighlightColor(index: NSInteger) -> UIColor {
        return UIColor.orange
    }
    
    func titleFont(index: NSInteger) -> UIFont {
        return UIFont.systemFont(ofSize: 13.0)
    }
    
    func tabBackgroundColor() -> UIColor {
        return UIColor.white
    }
    
    func preferTabIndex() -> NSInteger {
        return self.preferPageFirstAtIndex()
    }
    
    func needMarkView() -> Bool {
        return true
    }
    
    func markViewBottom(index: NSInteger) -> CGFloat {
        return self.preferTabFrame(index: self.pageVC.currentPageIndex).size.height - 7
    }
    
    func markViewColor(index: NSInteger) -> UIColor {
        return UIColor.orange
    }
    
    func markViewWidth(index: NSInteger) -> CGFloat {
        let text = NSString (string: self.title(index: index))
        let rect = text.boundingRect(with: CGSize.init(width: 20000, height: 40), options: [.usesFontLeading,.usesLineFragmentOrigin] , attributes: [NSAttributedStringKey.font:self.titleFont(index: index)], context: nil)
        return rect.size.width
    }
    
    func tabCanPress(index: NSInteger) -> Bool {
        return true
    }
    
    // SPTabDelegate
    func didPressTab(index: NSInteger) {
        if self.isSubPageCanScrollForIndex(index: index) {
            self.pageVC.showPage(index: index, animated: true)
        }
    }
    
    //SPPageControllerDelegate
    func willChangeInit() {
        self._cannotScrollWithPageOffset = true
    }
    
    func scrollViewContentOffsetWithRatio(ratio: CGFloat, draging: Bool) {
        if self.tabView is SPTagBarScrollView {
            if !draging {
                UIView.animate(withDuration: 0.3, animations: {[weak self] in
                    if let weakSelf = self {
                        if let tabView = weakSelf.tabView as?  SPTagBarScrollView {
                            tabView.markViewScroll(index: NSInteger(ratio))
                            tabView.markViewScroll = false
                        }
                        
                    }
                }, completion: { [weak self](finished:Bool) in
                    if let weakSelf = self {
                        if let tabView = weakSelf.tabView as?  SPTagBarScrollView {
                            tabView.markViewScroll = true
                            tabView.reloadHighlight(index: NSInteger(floor(ratio+0.5)))
                        }
                    }
                })
            } else {
                if let tabView = self.tabView as?  SPTagBarScrollView {
                    tabView.markViewScroll(contentRatio: Double(ratio))
                    tabView.reloadHighlight(index: NSInteger(floor(ratio+0.5)))
                }
            }
        }
    }
    
    func scrollWithPageOffset(pageOffset: CGFloat, index: NSInteger) {
        self.tabDragWithOffset(offset: pageOffset + self.pageTopAtIndex(index: index))
    }
    
    func pageviewControllerWillLeave(pageVC: SPPageController, fromVC: UIViewController, toVC: UIViewController) {
        self.changeToSubControllerOffset(toVc: toVC, isDelay: false)
    }
    
    func pageviewControllerDidLeave(pageVC: SPPageController, fromVC: UIViewController, toVC: UIViewController) {
        self.pageviewControllerDidChange(fromVC: fromVC, toVC: toVC)

    }
    
    func pageviewControllerWillTransition(pageVC: SPPageController, fromVC: UIViewController, toVC: UIViewController) {
        self.changeToSubControllerOffset(toVc: toVC, isDelay: false)
    }
    
    func pageviewControllerDidTransition(pageVC: SPPageController, fromVC: UIViewController, toVC: UIViewController) {
        self.pageviewControllerDidChange(fromVC: fromVC, toVC: toVC)
        if let tempView = self.tabView as? SPTagBarScrollView {
            tempView.scrollTab(index: self.pageVC.currentPageIndex)
        }
    }
    
    func pageviewControllerDidChange(fromVC: UIViewController, toVC: UIViewController) {
        if let tempVC = fromVC as? SPPageSubControllerDataSource {
            tempVC.preferScrollView()?.scrollsToTop = false
        }
        
        if let tempVC = toVC as? SPPageSubControllerDataSource {
            tempVC.preferScrollView()?.scrollsToTop = false
        }
        
        self.changeToSubControllerOffset(toVc: toVC, isDelay: true)
    }
    
    func cannotScrollWithPageOffset() -> Bool {
        return self._cannotScrollWithPageOffset
    }
}
