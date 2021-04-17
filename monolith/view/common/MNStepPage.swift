//
//  MNStepPage.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/11.
//

import Foundation
import RxSwift

protocol MNStepPage : NSObject {
    var stepConfirmed : Observable<Bool> { get };
    
    func confirmStep();
    
    func isOwner(ForViewModel viewModel: NSObject) -> Bool;
}
