//
//  Reactive+UIButton.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/12.
//

import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIButton{
    var isSelected : Observable<Bool?>{
        return self.observe(Bool.self, keyPath: \Base.isSelected);
    }
    
    var isEnabled : Observable<Bool?>{
        return self.observe(Bool.self, keyPath: \Base.isEnabled);
    }
}
