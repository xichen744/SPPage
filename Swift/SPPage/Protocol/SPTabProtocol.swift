//
//  SPTabProtocol.swift
//  SPPage
//
//  Created by GodDan on 2018/3/10.
//  Copyright © 2018年 GodDan. All rights reserved.
//

import UIKit

@objc protocol SPTabDataSource :class{
    
    func title(index:NSInteger) -> String
    func numberOfTab() -> NSInteger
    func preferTabFrame(index:NSInteger) -> CGRect
    
    @objc optional func tabWidth(index:NSInteger) -> CGFloat
    @objc optional func prferTabLeftOffset() -> CGFloat
    @objc optional func tabBackgroundColor() -> UIColor
    @objc optional func tabTopForIndex(index:NSInteger) -> CGFloat
    @objc optional func preferTabIndex() -> NSInteger
    @objc optional func titleFont(index:NSInteger) -> UIFont
    @objc optional func titleHighlightColor(index:NSInteger) -> UIColor
    @objc optional func titleColor(index:NSInteger) -> UIColor
    
    @objc optional func tabCanPress(index:NSInteger) -> Bool

    @objc optional func needMarkView() -> Bool
    @objc optional func markViewWidth(index:NSInteger) -> CGFloat
    @objc optional func markViewColor(index:NSInteger) -> UIColor
    @objc optional func markViewBottom(index:NSInteger) -> CGFloat

}

@objc protocol SPTabDelegate :class{
    
    @objc optional func didPressTab(index:NSInteger)
    
}
