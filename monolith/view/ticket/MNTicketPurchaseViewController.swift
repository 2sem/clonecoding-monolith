//
//  MNTicketPurchaseViewController.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/10.
//

import UIKit
import RxSwift
import RxCocoa

class MNTicketPurchaseViewController: UIViewController {

    class Segues{
        static let close = "close";
    }
    var ticket: Int?;
    
    override var prefersHomeIndicatorAutoHidden: Bool{
        return true;
    }
    
    @IBOutlet var stepButtonsView: [UIButton]!;
    @IBOutlet var pagesView: [UIView]!;
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var prevButton: UIButton!;
    @IBOutlet weak var nextButton: UIButton!;
    
    private var viewModel: MNTicketPurchaseViewModel = .init();
    private var disposeBag: DisposeBag = .init();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.pagesView.forEach{ $0.isHidden = false }
        self.setupBindings();
        //self.loadDays();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        self.setNeedsUpdateOfHomeIndicatorAutoHidden();
    }
    
    func setupBindings(){
        self.viewModel.currentStep
            .filter{ $0 == nil }
            .observe(on: MainScheduler.asyncInstance)
            .subscribe { [weak self](step) in
                self?.performSegue(withIdentifier: Segues.close, sender: nil);
            }.disposed(by: self.disposeBag)

        self.viewModel.currentStep
            .compactMap{ $0?.title }
            .flatMap{ $0 }
            .asDriver(onErrorJustReturn: "")
            .drive(self.titleLabel.rx.text)
            .disposed(by: self.disposeBag);
        
        self.viewModel.canPrev
            .asDriver(onErrorJustReturn: false)
            .drive(self.prevButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.viewModel.canNext
            .asDriver(onErrorJustReturn: false)
            .drive(self.nextButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.nextButton.rx.tap
            .withLatestFrom(self.viewModel.currentStep)
//            .flatMap{ self.viewModel.currentStep.share() }
            .compactMap{ $0 }
            .subscribe(onNext: { (value) in
                value.confirm();
//                try? self?.viewModel.currentStep.value()?.confirm();
            }).disposed(by: self.disposeBag)

        
    }

    func onNext() {
        self.viewModel.next();
    }
    
    @IBAction func onPrev(_ sender: UIButton) {
        self.viewModel.previous();
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let timePickerView = segue.destination as? MNReservableDateTimePickerViewController{
            timePickerView.ticket = self.ticket;
            timePickerView.time
                .bind(to: self.viewModel.time)
                .disposed(by: self.disposeBag);
            timePickerView.product
                .bind(to: self.viewModel.product)
                .disposed(by: self.disposeBag);
            
            timePickerView.stepConfirmed
                .filter{ $0 }
                .subscribe(onNext: { [weak self](value) in
                    self?.onNext();
                }).disposed(by: self.disposeBag);
            
            let index = self.viewModel.stepCount;
            
            self.setupStepBindings(index, viewModel: timePickerView.viewModel)
        }else if let payView = segue.destination as? MNPaymentViewController{
            self.viewModel.product
                .bind(to: payView.product)
                .disposed(by: self.disposeBag);
            
            self.viewModel.time
                .bind(to: payView.time)
                .disposed(by: self.disposeBag);
            
            payView.stepConfirmed
                .filter{ $0 }
                .subscribe(onNext: { [weak self](value) in
                    self?.viewModel.next();
                }).disposed(by: self.disposeBag);
            
            let index = self.viewModel.stepCount;

            self.setupStepBindings(index, viewModel: payView.viewModel)
        }
    }
    
    func setupStepBindings(_ index: Int, viewModel: MNStepViewModel){
        let isCurrentStep = viewModel.isCurrentStep

        isCurrentStep
//                .do{ debugPrint("time picker. isCurrentStep[\($0)]") }
            .map{ !$0 }
            .bind(to: self.pagesView[index].rx.isHidden)
            .disposed(by: self.disposeBag);
        
        self.viewModel.append(step: viewModel);
        
        if let stepButton = self.stepButtonsView[safe: index]{
            Observable.combineLatest(isCurrentStep, viewModel.confirmed)
                .do{ debugPrint("step button. viewModel[\(viewModel)] isCurrentStep[\($0)] confirmed[\($1)]") }
                .map{ $0 || $1 }
//                .do{ debugPrint("step button. viewModel[\(viewModel)] isCurrentStep[\($0)] confirmed[\($1)]") }
                .bind(to: stepButton.rx.isEnabled)
                .disposed(by: self.disposeBag);
            
            isCurrentStep
//                .do{ debugPrint("time picker. isCurrentStep[\($0)]") }
                .bind(to: stepButton.rx.isSelected)
                .disposed(by: self.disposeBag);
        }
    }
}
