//
//  MNStepViewModel.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/11.
//

import Foundation
import RxSwift

class MNStepViewModel : NSObject {
    var title: BehaviorSubject<String> = .init(value: "단계 이름");
    var nextOnConfirm: PublishSubject<(String, (Bool) -> Void)> = .init();
    var confirmed: BehaviorSubject<Bool> = .init(value: false);
    var isCurrentStep: BehaviorSubject<Bool> = .init(value: false);
    var canConfirm: BehaviorSubject<Bool> = .init(value: false);
    
    func confirm(){
        self.requestConfirm("Next?");
    };
    
    public func requestConfirm(_ msg: String, completion: ((Bool) -> Void)? = nil){
        self.nextOnConfirm
            .onNext((msg, { (result) in
                guard result else{
                    return;
                }
                
                guard let completion = completion else{
                    self.confirmed.onNext(true);
                    return;
                }
                
                completion(result);
            }))
    };
}
