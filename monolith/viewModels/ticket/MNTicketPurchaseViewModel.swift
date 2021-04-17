//
//  MNTicketPurchaseViewModel.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/11.
//

import Foundation
import RxSwift

class MNTicketPurchaseViewModel{
    var product: BehaviorSubject<String?> = .init(value: nil);
    var time: BehaviorSubject<MNReservableTimeInfo?> = .init(value: nil);
    private var steps: [MNStepViewModel] = [];
    var currentStep: BehaviorSubject<MNStepViewModel?> = .init(value: nil);
    var canNext: BehaviorSubject<Bool> = .init(value: false);
    var canPrev: BehaviorSubject<Bool> = .init(value: true);
    
    var stepNavigationDisposeBag : DisposeBag = .init();
    var disposeBag : DisposeBag = .init();
    
    init() {
        //load times if the selected day is changed automatically
//        self.selectedDay
//            .compactMap{ $0 }
//            .subscribe{ [weak self](day) in
//                self?.loadTimes(day);
//            }.disposed(by: self.disposeBag);
        self.currentStep
            .distinctUntilChanged()
            .scan(nil) { (oldStep, newStep) -> MNStepViewModel? in
                oldStep?.isCurrentStep.onNext(false);
//                debugPrint( "currentStep", "old[\(oldStep)] newStep[\(newStep)]" )
                return newStep;
            }.compactMap{ $0 }
            .subscribe(onNext:{ [weak self](value) in
                self?.bindNavigation(ForStep: value);
                value.isCurrentStep.onNext(true);
            }).disposed(by: self.disposeBag);
    }
    
    var currentStepIndex: Int{
        guard let currentStep = try? self.currentStep.value() else{
            return 0;
        }
        
        return self.steps.firstIndex(of: currentStep) ?? 0;
    }
    
    var stepCount: Int{
        return self.steps.count;
    }
    
    func next(){
        guard let currentStep = try? self.currentStep.value(),
              let currentStepIndex = self.steps.firstIndex(of: currentStep) else{
            return;
        }
        
//        currentStepIndex < self.steps.count.advanced(by: -1)

        let nextStep = self.steps[safe: currentStepIndex + 1]
//        self.bindNavigation(ForStep: nextStep);
        
        self.currentStep.onNext(nextStep);
        self.canPrev.onNext(true);
    }

    func previous(){
        guard let currentStep = try? self.currentStep.value(),
              let currentStepIndex = self.steps.firstIndex(of: currentStep) else{
            return;
        }

        let prevStep = self.steps[safe: currentStepIndex - 1];
//        self.bindNavigation(ForStep: prevStep);
        
        self.currentStep.onNext(prevStep);
    }
    
    private func bindNavigation(ForStep step: MNStepViewModel){
        self.stepNavigationDisposeBag = .init();
        step.canConfirm
            .do{ debugPrint("canConfirm => canNext", $0) }
            .bind(to: self.canNext)
            .disposed(by: self.stepNavigationDisposeBag);
    }
    
    func append(step: MNStepViewModel){
        self.steps.append(step);
        
        guard self.steps.count == 1 else {
            return;
        }
        
        self.currentStep.onNext(step);
        step.isCurrentStep.onNext(true);
    }
}
