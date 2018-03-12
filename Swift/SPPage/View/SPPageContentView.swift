//
//  SPPageContentView.swift
//  SPPage
//
//  Created by GodDan on 2018/3/1.
//  Copyright © 2018年 GodDan. All rights reserved.
//

import UIKit


class SPPageContentView: UIScrollView {
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.__setup()
    }

    required  init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.__setup()

    }
    
    func __setup() {
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.isPagingEnabled = true
        self.backgroundColor = UIColor.clear
        self.scrollsToTop = false
        
        if #available(OSX 11.0, *) {// ios11 苹果加了一个安全区域 会自动修改scrollView的contentOffset
            self.contentInsetAdjustmentBehavior =  UIScrollViewContentInsetAdjustmentBehavior.never;
        }
    }
    
    func addSubView(view:UIView)  {
        if !self.subviews.contains(view) {
            super.addSubview(view)
        }
    }
    
    func calcVisibleViewControllerFrameWithIndex(index:NSInteger) -> CGRect {
        let offsetX:CGFloat = CGFloat(index) * CGFloat(self.frame.size.width)
        
        return CGRect.init(x: offsetX, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
    }
    
    func calOffsetWithIndex(index:NSInteger) -> CGPoint {
        
        let width:CGFloat = self.frame.size.width
        let maxWidth:CGFloat = self.contentSize.width
        
        var offsetX:CGFloat = CGFloat(index)*width
        
        if offsetX < 0 {
            offsetX = 0
        }
        
        if maxWidth > 0 && offsetX > maxWidth-width {
            offsetX = maxWidth-width
        }
        
        return CGPoint.init(x: offsetX, y: 0)
        
    }
    
    func calcIndex() -> NSInteger {
        let offsetX = self.contentOffset.x
        let width = self.frame.size.width
       var startIndex:NSInteger = NSInteger(offsetX/width)
        
        if startIndex < 0 {
            startIndex = 0
        }
        
        return startIndex
    }
    
    func setItem(item:SPPageControllerDataSource)  {
        var startIndex:NSInteger = -1
        var endIndex:NSInteger = item.numberOfControllers()
        for i in 0...item.numberOfControllers()-1 {
            if (item.isSubPageCanScrollForIndex?(index: i))! && startIndex == -1 {
                startIndex = i
            }
            
            if startIndex >= 0 && !(item.isSubPageCanScrollForIndex?(index: i))! {
                endIndex = i
                break
            }
         }
        
        self.contentInset = UIEdgeInsets.init(top: 0, left:  -(CGFloat(startIndex) )*self.frame.size.width, bottom: 0, right: 0)
        self.contentSize =  CGSize.init(width: (CGFloat(endIndex))*self.frame.size.width, height: self.frame.size.height)

    }
}


