//
//  MNBaseResponse.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/08.
//

import Foundation

class MNBaseResponse<R> : Decodable where R : Decodable{
    enum ResultCode : String, Decodable{
        case success = "EC200"
        case unknown = "EC999"
        
        init?(rawValue: String) {
            switch rawValue {
            case ResultCode.success.rawValue:
                    self = ResultCode.success;
                    break;
                default:
                    self = .unknown;
                    break;
            }
            
        }
    }
    
    var code: ResultCode = .unknown;
    var message: String?;
    var data: R?;
    
    enum CodingKeys: String, CodingKey{
        case code
        case message
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self);
        
        self.code = try container.decode(ResultCode.self, forKey: .code);
        self.message = try container.decode(String.self, forKey: .message);
        self.data = try container.decode(R.self, forKey: .data);
    }
}
