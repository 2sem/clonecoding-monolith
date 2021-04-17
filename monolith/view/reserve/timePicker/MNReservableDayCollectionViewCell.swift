//
//  MNReservableDayCollectionViewCell.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/09.
//

import UIKit
import RxSwift
import RxCocoa
import LSExtensions

class MNReservableDayCollectionViewCell: UICollectionViewCell {
    
    var info: MNReservableDayInfo?{
        didSet{
            self.updateInfo();
        }
    }
    
    var isMonthVisible : Bool = false{
        didSet{
            self.updateMonthVisible();
        }
    }
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weekDayLabel: UILabel!
    
    var disposeBag : DisposeBag = .init();
    
    override var isSelected: Bool{
        didSet{
            self.dayLabel.backgroundColor = self.isSelected ? #colorLiteral(red: 0.1886929572, green: 0.4163666964, blue: 0.951190412, alpha: 1) : .clear;
            if let font = self.dayLabel.font{
                self.dayLabel.font = self.isSelected ? font.withSymbolic(traits: .traitBold) : font.withSymbolic(traits: []);
                //UIFont.systemFont(ofSize: <#T##CGFloat#>, weight: .regular)
            }
        }
    }
    
    func setupBindings(){
//        return self.observe(Bool.self, keyPath: \Base.isHighlighted);
    }
    
    func updateInfo(){
        guard let info = self.info else{
            return;
        }
        
        let date = info.date;
        self.monthLabel.text = "\(date.month)월";
        //self.updateMonthVisible();
        self.dayLabel.text = date.day.description;
        self.weekDayLabel.text = info.isToday ? "오늘" : date.toString("EE", locale: .init(identifier: "ko_KR"));
        
        self.dayLabel.textColor = (info.isHoliday || info.isSunday) ? .red : (info.isToday ? #colorLiteral(red: 0.1886929572, green: 0.4163666964, blue: 0.951190412, alpha: 1) : .black);
        self.weekDayLabel.textColor = self.dayLabel.textColor;
    }
    
    func updateMonthVisible(){
        self.monthLabel.isHidden = !self.isMonthVisible;
    }
}
