//
//  SPCoverController.swift
//  SPPage
//
//  Created by GodDan on 2018/3/11.
//  Copyright © 2018年 GodDan. All rights reserved.
//

import UIKit

enum CoverScrollStyle {
    case height
    case top
}

class SPCoverController: SPTabController,SPCoverDataSource {
    private var coverView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadCoverView()
    }
    
    func preferCoverStyle() -> CoverScrollStyle {
        return .height
    }
    
    private func reloadCoverView() {
        self.coverView?.removeFromSuperview()
        self.loadCoverView()
    }
    
    override func reloadData() {
        super.reloadData()
        self.reloadCoverView()
    }
    
    private func loadCoverView() {
        if let coverView = self.preferCoverView() {
            coverView.frame = self.preferCoverFrame()
            self.view.addSubview(coverView)
            self.coverView = coverView
        }
       
    }
    
    //SPCoverProtocol
    func preferCoverView() -> UIView? {
        return nil
    }
    
    func preferCoverFrame() -> CGRect {
        return CGRect()
    }
    
   // SPPageControllerDelegate
    override func scrollWithPageOffset(pageOffset: CGFloat, index: NSInteger) {
        super.scrollWithPageOffset(pageOffset: pageOffset, index: index)
        
        let top = self.tabScrollTopWithContentOffset(offset: pageOffset + self.pageTopAtIndex(index: index))
        
        let realOffset = self.preferTabFrame(index: index).origin.y - top
        
        if self.preferCoverStyle() == .height {
            let coverHeight = self.preferCoverFrame().size.height - realOffset
            if coverHeight >= 0 {
                coverView?.frame.size.height = coverHeight
            } else {
                coverView?.frame.size.height = 0
            }
        } else {
            let coverTop = self.preferCoverFrame().origin.y - realOffset
            if coverTop >= self.preferCoverFrame().origin.y - self.preferCoverFrame().size.height {
                coverView?.frame.origin.y = coverTop
            } else {
                coverView?.frame.origin.y = self.preferCoverFrame().origin.y - self.preferCoverFrame().size.height
            }
        }
    }
    
    // SPPageControllerDataSource
    
    override func pageTopAtIndex(index: NSInteger) -> CGFloat {
        let pageTop = super.pageTopAtIndex(index: index)
        let coverPageTop = self.preferCoverFrame().origin.y + self.preferCoverFrame().size.height
        return pageTop > coverPageTop ? pageTop :coverPageTop
    }

}
