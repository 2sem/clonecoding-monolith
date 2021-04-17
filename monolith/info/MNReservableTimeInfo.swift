//
//  MNReservableTimeInfo.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/10.
//

import Foundation

struct MNReservableTimeInfo{
    var id: String;
    var time: Date;
    var isEnabled: Bool;
    var hasStock: Bool;
    var status : Status;
    var start: Date!;
    var end: Date!;
    
    enum Status: Int, Decodable{
        case soldout = -1
        case free = 0
        case normal = 1
        case busy = 2
        case unknown = -99
    }
    
    var statusMessage: String;
}
