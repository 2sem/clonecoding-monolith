//
//  MNReservableTimePickerViewModel.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/10.
//

import Foundation
import RxSwift

class MNReservableTimePickerViewModel: MNStepViewModel{
    var days: BehaviorSubject<[MNReservableDayInfo]> = .init(value: []);
    var times: BehaviorSubject<[MNReservableTimeInfo]> = .init(value: []);
    var selectedDay: BehaviorSubject<MNReservableDayInfo?> = .init(value: nil);
    var selectedTime: BehaviorSubject<MNReservableTimeInfo?> = .init(value: nil);
    var product: BehaviorSubject<String?> = .init(value: nil);
    var isLoadingDays: BehaviorSubject<Bool> = .init(value: true);
    var isLoadingTimes: BehaviorSubject<Bool> = .init(value: true);
    
    var disposeBag : DisposeBag = .init();
    
    override init() {
        super.init();
        //load times if the selected day is changed automatically
        self.title.onNext("날짜 시간 선택");
        
        self.selectedDay
            .compactMap{ $0 }
            .subscribe(onNext: { [weak self](day) in
                self?.selectedTime.onNext(nil);
                self?.loadTimes(day);
            }).disposed(by: self.disposeBag);
        
        self.selectedTime
            .map{ $0 != nil }
//            .do{ debugPrint("selectedTime", $0) }
            .bind(to: self.canConfirm)
            .disposed(by: self.disposeBag);
    }
    
    func loadDays(ticketId id: Int){
        self.isLoadingDays.onNext(true);
        MNClient.shared.reservableDays(id) { [weak self](result) in
            switch result{
                case .success(let values):
                    let now = Date.now;
                    let newDays = values.filter{ $0.date != nil }
                        .map{
                            MNReservableDayInfo.init(id: $0.id,
                                                     date: $0.date!,
                                                     isEnabled: $0.isEnabled,
                                                     isHoliday: $0.isHoliday)
                        }
                        .filter{ $0.date.zeroDate >= now.zeroDate }
                    self?.days.onNext( newDays);
                    self?.selectedTime.onNext(nil);
                    if let firstDay = newDays.first{
                        self?.selectedDay.onNext(firstDay);
                    }
                    self?.isLoadingDays.onNext(false);
                    break;
                case .failure(let error):
                    self?.isLoadingDays.onError(error);
                    break;
            }
        }
    }
    
    func loadTimes(_ day: MNReservableDayInfo){
        self.isLoadingTimes.onNext(true);
        MNClient.shared.reservableTimes(day) { [weak self](result) in
            switch result{
                case .success(let value):
                    let now = Date.now;
                    let newTimes = value.data?.times.filter{ $0.time != nil }
                        .map{
//                            debugPrint( "day[\(day.date)] start[\($0.details?.first?.start)] end[\($0.details?.first?.end)]" );
                            return MNReservableTimeInfo.init(id: $0.id ?? "",
                                                      time: day.date.merge(time: $0.time!),
//                                                      time: $0.time!,
                                                      isEnabled: $0.isEnabled,
                                                      hasStock: $0.hasStock,
                                                      status: MNReservableTimeInfo.Status.init(rawValue: $0.status.rawValue ) ?? .unknown,
                                                      start: $0.details?.first?.start?.merge(date: day.date),
                                                      end: $0.details?.first?.end?.merge(date: day.date),
                                                      statusMessage: $0.statusMessage ?? "이용불가")
                        }
                        .filter{ $0.time >= now } ?? []
                        
//                    newTimes.forEach{ debugPrint( "day[\(day.date)] start[\($0.start)] end[\($0.end)]" ) }
                    
//                    debugPrint(now);
//                    newTimes.forEach{debugPrint($0.time)}
                    self?.product.onNext(value.data?.title);
                    self?.times.onNext( newTimes);
                    self?.isLoadingTimes.onNext(false);
                    break;
                case .failure(let error):
                    self?.isLoadingTimes.onError(error);
                    break;
            }
        }
    }
    
    // MARK: MNStepViewModel
    override func confirm() {
        guard let time = try? self.selectedTime.value(), let product = try? self.product.value() else{
            return
        }
        
        debugPrint(product, time);
        self.requestConfirm("""
            티켓: \(product)
            입장: \(time.start.toString("yyyy-MM-dd HH:mm"))
            종료: \(time.end.toString("yyyy-MM-dd HH:mm"))
        """)
    }
}
