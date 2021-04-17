//
//  MNEmptyView.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/11.
//

import UIKit
import LSExtensions

class MNEmptyView: UIView {

    private var messageLabel : UILabel!;
    
    var message : String{
        get{
            return self.messageLabel.text ?? "";
        }
        set(value){
            try? self.setMessage(value);
        }
    }
    
    //sizeRatio : CGFloat = 233.0/343.0,
    init(message: String = "", fontSize: CGFloat = 14, height: CGFloat? = nil, textColor: UIColor = UIColor.init(r: 113, g: 113, b: 113), background: UIColor = UIColor.white, border: UIColor = .clear, insets: UIEdgeInsets = UIEdgeInsets.init(top: 100, left: 16, bottom: 100, right: 16)) {
        super.init(frame: CGRect.zero);
        
        let value = UILabel();
        self.messageLabel = value;
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false;
        
        //configuration for the background
        self.messageLabel.backgroundColor = background;
        self.messageLabel.borderUIColor = border;
        self.messageLabel.borderWidth = 1;
        self.messageLabel.numberOfLines = 0;
        
        //configuration for the text
        if let font = self.messageLabel.font{
            self.messageLabel.font = font.withSize(fontSize);
        }
        
        self.messageLabel.textColor = textColor;
        self.messageLabel.textAlignment = .center;
        
        self.addSubview(self.messageLabel);
        self.message = message; // sometimes crashes?
        
        self.messageLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left).isActive = true;
        self.messageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -insets.right).isActive = true;
        self.messageLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top).isActive = true;
        self.messageLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -insets.bottom).isActive = true;
        //self.messageLabel.heightAnchor.constraint(equalTo: self.messageLabel.widthAnchor, multiplier: sizeRatio, constant: 0).isActive = true;
        //self.messageLabel.sizeToFit();
        //value.heightAnchor.constraint(equalToConstant: height);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setMessage(_ value : String) throws{
        let label = self.messageLabel;
        label?.text = value;
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An self.messageLabel implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
