//
//  UITableViewCell+.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/11.
//

import UIKit
import LSExtensions

extension UITableViewCell{
    /// Returns frame which is replaced heigt of tableview
    var realFrame : CGRect{
        var value : CGRect = self.frame;
        if let tableView = self.parent(type: UITableView.self){
            value = CGRect.init(origin: value.origin, size: CGSize.init(width: tableView.frame.width, height: value.height));
        }
        
        return value;
    }
    
    func realWidthOffset(_ tableView: UITableView) -> CGFloat{
        return tableView.frame.width - self.frame.width;
    }
}
