//
//  MNReservableDayInfo.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/09.
//

import Foundation

struct MNReservableDayInfo{
    var id: Int?;
    var date: Date;
    var isEnabled: Bool;
    var isHoliday: Bool;
    var isToday : Bool {
        return self.date.isToday
    }
    
    var isSunday : Bool{
        return self.date.isSunday;
    }
}
