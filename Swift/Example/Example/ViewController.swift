//
//  ViewController.swift
//  SPPage
//
//  Created by GodDan on 2018/2/27.
//  Copyright © 2018年 GodDan. All rights reserved.
//

import UIKit


class ViewController: SPCoverController {

    var navTitle:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       self.minYPullUp = kNavigationAndStatusBarHeight
        self.automaticallyAdjustsScrollViewInsets = false
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = self.navTitle ?? "SPPage"
        if (self.navTitle == nil) {
            self.navigationController?.navigationBar.barTintColor = UIColor.red
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func title(index: NSInteger) -> String {
        return "TAB" + String(index)
    }
    
    override func needMarkView() -> Bool {
        return true
    }
    
    override func preferCoverView() -> UIView? {
        let view = UIView.init(frame: self.preferCoverFrame())
        view.backgroundColor = UIColor.black
        
        return view
    }
    
    override func preferTabFrame(index: NSInteger) -> CGRect {
        return CGRect.init(x: 0, y: 245, width: kScreenWidth, height: 40)
    }
    
    override func preferCoverFrame() -> CGRect {
        return CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: kScreenWidth, height: 245))
    }
    
    override func controller(index: NSInteger) -> UIViewController {
        let subVC = TestSubController()
        if index == 0 {
            subVC.view.backgroundColor = UIColor.green
        } else if index == 1 {
            subVC.view.backgroundColor = UIColor.orange

        } else {
            subVC.view.backgroundColor = UIColor.red

        }
        
        return subVC
    }
    
    override func preferPageFirstAtIndex() -> NSInteger {
        return 0
    }
    
    override func isSubPageCanScrollForIndex(index: NSInteger) -> Bool {
        return true
    }
    
    override func numberOfControllers() -> NSInteger {
        return 8
    }
    
    override func isPreLoad() -> Bool {
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

