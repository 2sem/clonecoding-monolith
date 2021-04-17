//
//  MNReserableTimeHeaderView.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/11.
//

import UIKit

class MNReserableTimeHeaderView: UICollectionReusableView {
    var product: String!{
        didSet{
            
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!;
    
    func updateInfo(){
        guard let info = self.product else{
            return;
        }
        
        self.titleLabel.text = info;
    }
}
