//
//  SPCoverProtocol.swift
//  SPPage
//
//  Created by GodDan on 2018/3/11.
//  Copyright © 2018年 GodDan. All rights reserved.
//

import UIKit

 protocol SPCoverDataSource :class{
    func preferCoverView() -> UIView?
    func preferCoverFrame() -> CGRect
    
}
