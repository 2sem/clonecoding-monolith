//
//  MNPaymentViewModel.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/11.
//

import Foundation
import RxSwift

class MNPaymentViewModel: MNStepViewModel{
    var time: BehaviorSubject<MNReservableTimeInfo?> = .init(value: nil);
    var product: BehaviorSubject<String?> = .init(value: nil);
    var isProcessing: BehaviorSubject<Bool> = .init(value: true);
    
    var disposeBag : DisposeBag = .init();
    
    override init() {
        super.init();
        //load times if the selected day is changed automatically
        self.title.onNext("결제 방법 선택");
        
        self.canConfirm.onNext(true);
        
        self.isProcessing
            .map{ !$0 }
            .bind(to: self.canConfirm)
            .disposed(by: self.disposeBag);
    }
    
    func pay(){
        self.isProcessing.onNext(true);
        DispatchQueue.global(qos: .background).async {
            self.confirmed.onNext(true);
            self.isProcessing.onNext(false);
        }
    }
    
    // MARK: MNStepViewModel
    override func confirm() {
        guard let time = try? self.time.value(), let product = try? self.product.value() else{
            return
        }
        
        self.requestConfirm("""
            티켓: \(product)
            입장: \(time.start.toString("yyyy-MM-dd HH:mm"))
            종료: \(time.end.toString("yyyy-MM-dd HH:mm"))

            결제금액: 29,000원
        """){ (result) in
            guard result else{
                return;
            }
            
            self.pay();
        }
    }
}
