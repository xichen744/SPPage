//
//  SPTagBarScrollView.swift
//  SPPage
//
//  Created by GodDan on 2018/3/10.
//  Copyright © 2018年 GodDan. All rights reserved.
//

import UIKit

class SPTagBarScrollView: UIScrollView {
    
    private var tagViews:Array<SPPageTagTitleView> = Array<SPPageTagTitleView>()
    private var markView:UIView = UIView()
    private var index:NSInteger = 0
    private weak var tabDataSource:SPTabDataSource?
    private weak var tabDelegate:SPTabDelegate?
    var markViewScroll: Bool = false
    
    convenience init(frame: CGRect, tabDelagate: SPTabDelegate, tabDataSource: SPTabDataSource) {
        self.init(frame: frame)
        self.tabDelegate = tabDelagate
        self.tabDataSource = tabDataSource
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup()  {
        self.index = self.tabDataSource?.preferTabIndex?() ?? 0
        self.setupProperty()
        self.setupTabBarScrollView()
        self.setupMaskView()
        self.scrollTab(index: self.index)
        self.scrollMarkView(index: self.index, animated: false)
    }
    
    private func setupProperty() {
        self.isDirectionalLockEnabled = true
        self.scrollsToTop = false
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.backgroundColor = UIColor.clear
    }
    
    private func setupTabBarScrollView() {
    
        var offset:CGFloat = self.tabDataSource?.prferTabLeftOffset?() ?? 5
        let num:NSInteger! = self.tabDataSource?.numberOfTab()
        
        for i in 0...num {
            let tabWidth:CGFloat = self.tabDataSource?.tabWidth?(index: i) ?? 73
            let top:CGFloat = self.tabDataSource?.tabTopForIndex?(index: i) ?? 0
            let normalTitleColor:UIColor = self.tabDataSource?.titleColor?(index: i) ?? UIColor.black
            let hightlightedTitleColor = self.tabDataSource?.titleHighlightColor?(index: i) ?? UIColor.orange
            
            let titleView:SPPageTagTitleView = SPPageTagTitleView.init(frame: CGRect.init(x: offset, y: top, width: tabWidth, height: self.frame.size.height), highlightedTitleColor: hightlightedTitleColor, normalTitleColor: normalTitleColor)
            titleView.titleLable.text = self.tabDataSource?.title(index: i)
            titleView.titleLable.font = self.tabDataSource?.titleFont?(index: i) ?? UIFont.systemFont(ofSize: 15.0)
            titleView.tag = i
            titleView.isUserInteractionEnabled = true
            titleView.addTarget(self, action: #selector(SPTagBarScrollView.pressTab(sender:)), for: .touchUpInside)
        
            self.addSubview(titleView)
            
            self.tagViews.append(titleView)
            
            offset += tabWidth
            
        }
        
        self.reloadHighlight()

        
        self.contentSize.width = offset
        self.backgroundColor = self.tabDataSource?.tabBackgroundColor?() ?? UIColor.clear
        
    }
    
    private func setupMaskView() {
        if self.needMarkView() {
            self.markView = UIView.init(frame: CGRect.init(x: 0, y: self.tabDataSource?.markViewBottom?(index: self.index)  ?? -13, width: self.tabDataSource?.markViewWidth?(index: self.index) ?? 0, height: 2))
            self.markView.layer.cornerRadius = 1.0
            self.markView.layer.masksToBounds = true
            self.markView.backgroundColor = self.tabDataSource?.markViewColor?(index: self.index) ?? UIColor.orange
            self.addSubview(self.markView)
            self.markViewScroll = true
        }
    }
    
    @objc private func pressTab(sender:UIControl) {
        let index = sender.tag
        
        if self.index == index {
            return
        }
        
        if (self.tabDataSource?.tabCanPress?(index: index))! {
            self.index = index
            self.reloadHighlight()
            self.scrollTab(index: index)
            self.scrollMarkView(index: index, animated: true)
            self.tabDelegate?.didPressTab?(index: index)
        }
    }
    
    private func reloadHighlight() {
        for i in 0...self.tagViews.count-1 {
            let titleView:SPPageTagTitleView = self.tagViews[i]
            if (self.index == i) {
                titleView.highlightTagView()
            } else {
                titleView.unHighlightTagView()
            }
        }
    }
    
    private func needMarkView() -> Bool {
        return (self.tabDataSource?.needMarkView?())!
    }
    
    func reloadHighlight(index:NSInteger) {
        self.index = index
        self.reloadHighlight()
    }
    
    func scrollTab(index:NSInteger) {
        if self.tagViews.count <= index || self.contentSize.width < self.frame.size.width {
            return
        }
        
        if index == self.tagViews.count-1 && index != 0
        {
            self.setContentOffset(CGPoint.init(x: self.contentSize.width-self.frame.size.width+self.contentInset.right, y: 0), animated: true)
        } else {
            let nextTitleView = self.tagViews[index]
            
            let tabExceptInScreen = UIScreen.main.bounds.size.width - nextTitleView.frame.size.width
            let tabPaddingInScreen = tabExceptInScreen / 2.0
            let offsetX = max(0, min(nextTitleView.frame.origin.x - tabPaddingInScreen, (self.tagViews.last?.frame.origin.x)! - tabExceptInScreen))
            
            let nextPoint = CGPoint.init(x: offsetX, y: 0)
            self.setContentOffset(nextPoint, animated: true)

        }
    }
    
    func markViewScroll(index:NSInteger) {
        if !self.markViewScroll {
            return
        }
        
        if index < 0 || index >= self.tagViews.count  {
            return
        }
        
        let curTab = self.tagViews[index]
        
        
        self.markView.center.x = curTab.center.x
        self.markView.frame.size.width = self.tabDataSource?.markViewWidth?(index: index) ?? 0

    }
    
    func markViewScroll(contentRatio:Double) {
        if !self.markViewScroll {
            return
        }
        
        let fromIndex = Int( ceil(contentRatio ) - 1)
        
        if fromIndex < 0 || fromIndex >= self.tagViews.count - 1 {
            return
        }
        
        let fromWidth:CGFloat = (self.tabDataSource?.markViewWidth?(index: fromIndex))!
        let toWidth:CGFloat = (self.tabDataSource?.markViewWidth?(index: fromIndex+1))!
        
        if fromWidth != toWidth {
            self.markView.frame.size.width = fromWidth + (toWidth - fromWidth)*(CGFloat( contentRatio) - CGFloat(fromIndex) )
        }
        
        let curTabView = self.tagViews[fromIndex]
        let nextTabView = self.tagViews[fromIndex+1]
        let firstTabView = self.tagViews.first
        let lastTabView = self.tagViews.last
        
        var moveCenterX = curTabView.center.x + (CGFloat(contentRatio) - CGFloat(fromIndex)) * (nextTabView.center.x - curTabView.center.x)
        
        if moveCenterX <= (firstTabView?.center.x)! {
            moveCenterX = (firstTabView?.center.x)!
        } else if moveCenterX >= (lastTabView?.center.x)! {
            moveCenterX = (lastTabView?.center.x)!
        }
        
        self.markView.center.x = moveCenterX
    }
    
    func scrollMarkView(index:NSInteger, animated:Bool) {
        if !self.markViewScroll {
            return
        }
        
        if index >= self.tagViews.count || index < 0 {
            return
        }
        
        
        let curTabView = self.tagViews[index]
        if (animated) {
           
            UIView.animate(withDuration: 0.3, animations:{[weak self]  in
                
                if let weakSelf = self {
                    weakSelf.markView.center.x = curTabView.center.x
                    weakSelf.markView.frame.size.width = (weakSelf.tabDataSource?.markViewWidth?(index: index))!
                }
            })
        } else {
            self.markView.center.x = curTabView.center.x
            self.markView.frame.size.width = (self.tabDataSource?.markViewWidth?(index: index))!
        }
        
    }
    
}
