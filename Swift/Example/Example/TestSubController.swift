//
//  TestSubController.swift
//  SPPage
//
//  Created by GodDan on 2018/3/12.
//  Copyright © 2018年 GodDan. All rights reserved.
//

import UIKit
class TestSubController: UIViewController,UITableViewDelegate,UITableViewDataSource,SPPageSubControllerDataSource {
    private var tableView:UITableView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame:self.view.bounds)
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.autoresizingMask = [.flexibleTopMargin,.flexibleWidth,.flexibleHeight,.flexibleLeftMargin,.flexibleRightMargin,.flexibleBottomMargin]
        self.view.addSubview(self.tableView!)
        self.tableView?.separatorStyle = .none
        self.tableView?.backgroundColor = UIColor.clear
        self.tableView?.estimatedRowHeight = 0
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(frame: CGRect.init(x: 0, y: 0, width: kScreenWidth, height: 60))
        cell.textLabel?.text = "Row"+String(indexPath.row)
        cell.backgroundColor = UIColor.clear
        cell.contentView.backgroundColor = UIColor.clear
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView?.deselectRow(at: indexPath, animated: false)
        
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SUID_ViewController")
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func preferScrollView() -> UIScrollView? {
        return self.tableView
    }
    
    
}
