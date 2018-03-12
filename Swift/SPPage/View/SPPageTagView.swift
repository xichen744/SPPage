//
//  SPPageTagView.swift
//  SPPage
//
//  Created by GodDan on 2018/3/10.
//  Copyright © 2018年 GodDan. All rights reserved.
//

import UIKit

class SPPageTagTitleView: UIControl {
    
    private var highlightedTitleColor:UIColor = UIColor.clear
    private var normalTitleColor:UIColor = UIColor.clear
    var titleLable:UILabel = UILabel.init()

    
    convenience init(frame: CGRect, highlightedTitleColor:UIColor, normalTitleColor:UIColor)  {
        self.init(frame: frame)
        self.highlightedTitleColor = highlightedTitleColor
        self.normalTitleColor = normalTitleColor
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
        self.frame = frame
        self.titleLable.frame = self.bounds
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup()  {
        self.backgroundColor = UIColor.clear
        self.titleLable.backgroundColor = UIColor.clear
        self.titleLable.textAlignment = NSTextAlignment.center
        self.addSubview(self.titleLable)
    }
    
    func highlightTagView() {
        self.titleLable.textColor = self.highlightedTitleColor
    }
    
    func unHighlightTagView () {
        self.titleLable.textColor = self.normalTitleColor
    }
    
}
