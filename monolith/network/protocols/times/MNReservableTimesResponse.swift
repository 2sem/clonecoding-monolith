//
//  MNReservableTimesResponse.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/08.
//

import Foundation
import LSExtensions

class MNReservableTimesResponse : MNBaseResponse<MNReservableTimesResponse.Result>{
    struct Result: Decodable{
        var title: String?;
        var times : [TimeInfo] = [];
        
        enum CodingKeys: String, CodingKey{
            case title = "productName"
            case times = "timeList"
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self);
            self.title = try container.decodeIfPresent(String.self, forKey: .title);
            self.times = try container.decodeIfPresent([TimeInfo].self, forKey: .times) ?? [];
        }
    }
    
    class TimeInfo : Decodable{
        var id: String?;
        var time: Date?;
        var isEnabled: Bool = false;
        var hasStock: Bool = false;
        var statusMessage: String? = "보통";
        var status: TimeStatus = .soldout;
        var details: [TimeDetailInfo]?;
        
        enum TimeStatus: Int, Decodable{
            case soldout = -1
            case free = 0
            case normal = 1
            case busy = 2
            case unknown = -99
        }
        
        enum CodingKeys: String, CodingKey{
            case id = "stcDetailId"
            case time = "timeSlot"
            case isEnabled = "enabled"
            case statusMessage = "stockStatusStr"
            case status = "stockStatus"
            case hasStock = "stockUseYn"
            case details = "productDetailList"
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self);
            
            self.id = try container.decode(String.self, forKey: .id);
            if let time = try? container.decode(String.self, forKey: .time){
                self.time = time.toDate("HH:mm");
            }
            self.isEnabled = try container.decode(Bool.self, forKey: .isEnabled);
            self.hasStock = try container.decode(Bool.self, forKey: .hasStock);
            self.statusMessage = try container.decode(String.self, forKey: .statusMessage);
            self.status = try container.decode(TimeStatus.self, forKey: .status);
            self.details = try container.decode([TimeDetailInfo].self, forKey: .details);
        }
    }
    
    class TimeDetailInfo : Decodable{
        var id: Int?;
        var start: Date?;
        var end: Date?;
        
        enum CodingKeys: String, CodingKey{
            case id = "prdDetailId"
            case start = "entranceStartTime"
            case end = "entranceEndTime"
        }
        
        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self);
            
            self.id = try container.decode(Int.self, forKey: .id);
            if let time = try? container.decode(String.self, forKey: .start){
                self.start = time.toDate("HH:mm");
            }
            
            if let time = try? container.decode(String.self, forKey: .end){
                self.end = time.toDate("HH:mm");
            }
        }
    }
}
