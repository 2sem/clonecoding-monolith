//
//  MNReservableTimeCollectionViewCell.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/10.
//

import UIKit
import RxSwift
import RxCocoa
import LSExtensions

class MNReservableTimeCollectionViewCell: UICollectionViewCell {
    
    static let statusColors : [MNReservableTimeInfo.Status : UIColor]
        = [.free: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), .normal: #colorLiteral(red: 0.1589206755, green: 0.4059433341, blue: 0.6914330721, alpha: 1), .busy: #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), .unknown: .black];
    
    var info: MNReservableTimeInfo?{
        didSet{
            self.updateInfo();
        }
    }
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    var disposeBag : DisposeBag = .init();
    
    override var isSelected: Bool{
        didSet{
            self.borderUIColor = self.isSelected ? .blue : #colorLiteral(red: 0.4734576344, green: 0.9281002879, blue: 0.9455288053, alpha: 1);
        }
    }
    
    func setupBindings(){
//        return self.observe(Bool.self, keyPath: \Base.isHighlighted);
    }
    
    func updateInfo(){
        guard let info = self.info else{
            return;
        }
        
        self.timeLabel.text = info.time.toString("HH:mm");
        self.statusLabel.text = info.statusMessage;
        
        self.statusLabel.textColor = type(of: self).statusColors[info.status];
        self.containerView.alpha = info.isEnabled ? 1 : 0.1;
        self.backgroundColor = info.isEnabled ? .clear : #colorLiteral(red: 0.4734576344, green: 0.9281002879, blue: 0.9455288053, alpha: 1);
    }
}
