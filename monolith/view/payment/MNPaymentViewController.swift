//
//  MNPaymentViewController.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/11.
//

import UIKit
import RxSwift
import RxCocoa

class MNPaymentViewController: UIViewController {

    class Cells{
        static let day = "day";
        static let time = "time";
    }
    
    var product : BehaviorSubject<String?>{
        return self.viewModel.product;
    }
    
    var time : BehaviorSubject<MNReservableTimeInfo?>{
        return self.viewModel.time;
    }
    
    @IBOutlet weak var paymentLabel: UILabel!
    @IBOutlet weak var payButton: UIButton!
        
    var viewModel: MNPaymentViewModel = .init();
    private var disposeBag: DisposeBag = .init();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupBindings();
        //self.loadDays();
    }
    
    func setupBindings(){
        Observable.combineLatest(self.product.compactMap{ $0 }, self.time.compactMap{ $0 })
            .map{ """
            티켓: \($0)
            입장: \($1.start.toString("yyyy-MM-dd HH:mm"))
            종료: \($1.end.toString("yyyy-MM-dd HH:mm"))

            결제금액: 29,000원
        """ }.asDriver(onErrorJustReturn: "잘못된 티켓입니다 😢")
            .drive(self.paymentLabel.rx.text)
            .disposed(by: self.disposeBag);
        
        self.viewModel.nextOnConfirm
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext:{ [weak self](msg, completion) in
                self?.showAlert(title: "결제정보 확인", msg: msg, actions: [.default("결제", handler: { (act) in
                    completion(true);
                }), .cancel("취소", handler: { (act) in
                    completion(false);
                })], style: .alert);
            }).disposed(by: self.disposeBag);
    }
    
    @IBAction func onPay(_ sender: UIButton) {
        self.viewModel.confirm();
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MNPaymentViewController: MNStepPage{
    var stepConfirmed : Observable<Bool>{
        return self.viewModel.confirmed;
    }
    
    func confirmStep(){
        self.viewModel.confirm();
    }
    
    func isOwner(ForViewModel viewModel: NSObject) -> Bool {
        return self.viewModel === viewModel;
    }
}
