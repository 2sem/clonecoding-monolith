//
//  MNReservableDaysResponse.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/08.
//

import Foundation
import LSExtensions

class MNReservableDaysResponse : MNBaseResponse<[MNReservableDaysResponse.DayInfo]>{
    class DayInfo : Decodable{
        var id: Int?;
        var date: Date?;
        var isEnabled: Bool = false;
        var isHoliday: Bool = false;
        
        enum CodingKeys: String, CodingKey{
            case id = "dplId"
            case date
            case isEnabled = "enabled"
            case isHoliday = "holidayYn"
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self);
            
            self.id = try? container.decode(Int.self, forKey: .id);
            if let date = try? container.decode(String.self, forKey: .date){
                self.date = date.toDate("yyyy-MM-dd");
            }
//            self.isEnabled = try container.decode(Bool.self, forKey: .isEnabled);
//            self.isHoliday = try container.decode(Bool.self, forKey: .isHoliday);
        }
    }
}
