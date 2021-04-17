//
//  MNReservableTimeGroupInfo.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/11.
//

import Foundation
import RxDataSources

struct MNReservableTimeGroupInfo {
    var title: String
    var items: [MNReservableTimeInfo]
}

extension MNReservableTimeGroupInfo : SectionModelType{
    typealias Item = MNReservableTimeInfo
    
    init(original: MNReservableTimeGroupInfo, items: [MNReservableTimeInfo]) {
        self = original;
        self.items = items;
    }
}
