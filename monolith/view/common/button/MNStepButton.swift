//
//  MNStepButton.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/12.
//

import UIKit
import RxSwift
import RxCocoa

class MNStepButton: UIButton {

//    fileprivate var _backgoundColor : UIColor?;
    override var backgroundColor: UIColor?{
        get{
            return super.backgroundColor;
        }
        
        set{
            super.backgroundColor = newValue;
//            self._backgoundColor = newValue;
        }
    }
    
    @IBInspectable var selectedBorderColor: UIColor? = .blue{
        didSet{
            
        }
    }
    
    @IBInspectable var borderColor: UIColor? = .clear{
        didSet{
            
        }
    }
    
    @IBInspectable var disabledBorderColor: UIColor? = .gray{
        didSet{
            
        }
    }
    
    @IBInspectable
    var normalBackgroundColor : UIColor?{
        didSet{
//            guard !self.isSelected else{
//                return;
//            }
//
//            self.frameView?.borderColor = self.frameColor;
        }
    }
    
    @IBInspectable
    var selectedBackgroundColor : UIColor?{
        didSet{
//            guard !self.isSelected else{
//                return;
//            }
//
//            self.frameView?.borderColor = self.frameColor;
        }
    }
    
    @IBInspectable
    var disabledBackgroundColor : UIColor?{
        didSet{
            
        }
    }
    
    @IBInspectable
    var circleBackgroundColor : UIColor?{
        didSet{
            
        }
    }
    
//    fileprivate var _tintColor : UIColor?;
    @IBInspectable
    var normalTintColor : UIColor?{
        didSet{
            
        }
    }
    
    @IBInspectable
    var selectedTintColor : UIColor?{
        didSet{
//            guard !self.isSelected else{
//                return;
//            }
//
//            self.frameView?.borderColor = self.frameColor;
        }
    }
    
    @IBInspectable
    var disabledTintColor : UIColor?{
        didSet{
//
        }
    }
    
    
    var iconCircle: UIView!;
    
    var disposeBag : DisposeBag = .init();
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setupCircle();
        //self.iconCircle.borderUIColor = self.borderUIColor;
        
        self.setupBindings();
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        self.sendSubviewToBack(self.iconCircle);
        self.iconCircle.cornerRadius = self.frame.height/2;
    }
    
    func setupBindings(){
//        self._backgoundColor = self.backgroundColor;
        let isEnabledSelected = Observable.combineLatest(self.rx.isEnabled.compactMap{ $0 }, self.rx.isSelected.compactMap{ $0 });
        
        isEnabledSelected
            .map{ $0 ? ( $1 ? (self.selectedBackgroundColor ?? self.normalBackgroundColor) : (self.normalBackgroundColor))
                    : (self.disabledBackgroundColor ?? self.normalBackgroundColor) }
            .bind(to: super.rx.backgroundColor)
            .disposed(by: self.disposeBag);
        
//        self.rx.isSelected
//            .map{ ($0 ?? false) ? (self.selectedBackgroundColor ?? self._backgoundColor) : self._backgoundColor }
//            .bind(to: super.rx.backgroundColor)
//            .disposed(by: self.disposeBag);

        let newBorderColor
            = isEnabledSelected
            .map{ $0 ? ( $1 ? (self.selectedBorderColor ?? self.borderColor) : (self.borderColor))
                    : (self.disabledBorderColor ?? self.borderColor) }

        newBorderColor
            .bind(to: super.rx.borderUIColor)
            .disposed(by: self.disposeBag);
        
//        self.rx.isSelected
//            .map{ ($0 ?? false) ? (self.selectedBorderColor ?? self.borderColor) : self.borderColor }
//            .bind(to: super.rx.borderUIColor)
//            .disposed(by: self.disposeBag);
        
//        self.rx.isEnabled
//            .map{ !($0 ?? false) ? (self.disabledBackgroundColor ?? self._backgoundColor) : self._backgoundColor }
//            .bind(to: super.rx.backgroundColor)
//            .disposed(by: self.disposeBag);
//
//        self.rx.isEnabled
//            .map{ !($0 ?? false) ? (self.disabledBorderColor ?? self.borderColor) : self.borderColor }
//            .bind(to: super.rx.borderUIColor)
//            .disposed(by: self.disposeBag);

        newBorderColor
            .bind(to: self.iconCircle.rx.borderUIColor)
            .disposed(by: self.disposeBag);
        
        isEnabledSelected
            .map{ $0 ? ( $1 ? (self.circleBackgroundColor ?? .clear) : .clear )
                : .clear }
            .bind(to: self.iconCircle.rx.backgroundColor)
            .disposed(by: self.disposeBag);

//        self._tintColor = self.tintColor;

        isEnabledSelected
            .map{ $0 ? ( $1 ? (self.selectedTintColor ?? self.normalTintColor) : (self.normalTintColor))
                    : (self.disabledTintColor ?? self.normalTintColor) }
            .bind(to: super.rx.tintColor)
            .disposed(by: self.disposeBag);
        
//        self.rx.isSelected
//            .map{ ($0 ?? false) ? (self.selectedTintColor ?? self._tintColor) : self._tintColor }
//            .bind(to: super.rx.tintColor)
//            .disposed(by: self.disposeBag);
        
//        self.rx.isEnabled
//            .map{ !($0 ?? false) ? (self.disabledTintColor ?? self._tintColor) : self._tintColor }
//            .bind(to: super.rx.tintColor)
//            .disposed(by: self.disposeBag);
    }
    
    func setupCircle(){
        self.iconCircle = UIView.init();
        self.iconCircle.frame.size = .init(width: self.frame.size.height, height: self.frame.size.height);
        self.iconCircle.borderWidth = 1;
        self.addSubview(self.iconCircle);
        self.sendSubviewToBack(self.iconCircle);
        self.iconCircle.backgroundColor = .blue;
        self.iconCircle.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true;
        self.iconCircle.widthAnchor.constraint(equalTo: self.heightAnchor).isActive = true;
//        self.rx.observe(CGFloat.self, keyPath: \.cornerRadius)
    }
    
    func updateCircle(){
        self.iconCircle.cornerRadius = self.cornerRadius;
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
