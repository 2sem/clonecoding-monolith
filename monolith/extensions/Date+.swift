//
//  Date+.swift
//  monolith
//
//  Created by 영준 이 on 2021/04/10.
//

import Foundation

extension Date{
    /**
        Returns the formatted string with given date format
        - parameter format: Date format to make the formmated string with
     */
    public func toString(_ format : String = "yyyy-MM-dd HH:mm:ss", locale: Locale) -> String{
        var value = "";
        let formatter = DateFormatter();
        formatter.locale = locale;
        formatter.setLocalizedDateFormatFromTemplate(format);
//        formatter.dateFormat = format;
        
        value = formatter.string(from: self);
        
        return value;
    }
    
    /**
        Weekday of this date
    */
    public var weekday: Int{
        get{
            return Calendar.current.dateComponents([.weekday], from: self).weekday ?? 0;
        }
        
        mutating set(value){
            var components = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: self);
            components.weekday = value;
            self = Calendar.current.date(from: components)!;
        }
    }
    
    var isSunday : Bool{
        return self.weekday == 1; //1: sunday
    }
    
    var isSaturday : Bool{
        return self.weekday == 7; //7: saturday
    }
    
    var isToday : Bool {
        return self.isEqual(date: Date(), components: [.year, .month, .day]);
    }
    
    func merge(time: Date) -> Date{
        var components = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: self);
        let timeComponents = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: time);
        components.hour = timeComponents.hour;
        components.minute = timeComponents.minute;
        components.second = timeComponents.second;
        components.nanosecond = timeComponents.nanosecond;
        
        return Calendar.current.date(from: components)!;
    }
    
    func merge(date: Date) -> Date{
        let components = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: self);
        var dateComponents = Calendar.current.dateComponents(in: Calendar.current.timeZone, from: date);
        dateComponents.hour = components.hour;
        dateComponents.minute = components.minute;
        dateComponents.second = components.second;
        dateComponents.nanosecond = components.nanosecond;
        
        return Calendar.current.date(from: dateComponents)!;
    }
}
