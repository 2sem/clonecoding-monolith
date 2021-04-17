//
//  MNClient.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/09.
//

import Foundation

class MNClient {
    static let shared: MNClient = .init();
    var queue : DispatchQueue = .init(label: "queue.monolith.network", qos: .background)
    
    enum NetworkError: Error{
        case internet
        case nodata
        case invalidJson
        case unknown
    }
}

extension MNClient {
    /// load reservable days for the ticket from server
    /// - Parameters:
    ///   - ticketId: ticket
    ///   - completion: completion handler to return times
    func reservableDays(_ ticketId: Int, completion: @escaping (Result<[MNReservableDaysResponse.DayInfo], NetworkError>) -> Void){
        self.queue.async {
            guard let json = Bundle.main.url(forResource: "date", withExtension: "json") else{
                completion(.failure(.internet));
                return;
            }
            
            do{
                let response = try MNReservableDaysResponse.decode(json: Data.init(contentsOf: json));
                
                guard let days = response.data, days.any else{
                    completion(.failure(.nodata));
                    return;
                }
                
                completion(.success(days));
            }catch let jsonError{
                debugPrint("[\(#function)] json parse error[\(jsonError)]")
                completion(.failure(.invalidJson));
                return;
            }
            
            
        }
    }
    
    /// load reservable times for the day from server
    /// - Parameters:
    ///   - day: day
    ///   - completion: completion handler to return times
    func reservableTimes(_ day: MNReservableDayInfo, completion: @escaping (Result<MNReservableTimesResponse, NetworkError>) -> Void){
        self.queue.async {
            guard let json = Bundle.main.url(forResource: day.isSunday ? "sunday" : "basic", withExtension: "json") else{
                completion(.failure(.internet));
                return;
            }
            
            do{
                let response = try MNReservableTimesResponse.decode(json: Data.init(contentsOf: json));
                
                completion(.success(response));
            }catch let jsonError{
                debugPrint("[\(#function)] json parse error[\(jsonError)]")
                completion(.failure(.invalidJson));
                return;
            }
        }
    }
}
