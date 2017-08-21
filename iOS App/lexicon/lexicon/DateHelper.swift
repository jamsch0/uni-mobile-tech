//
//  DateHelper.swift
//  lexicon
//
//  Created by James Chapman on 02/03/2017.
//  Copyright © 2017 James Chapman. All rights reserved.
//

import Foundation

extension Date {
    static func isoString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return formatter.string(from: date).appending("Z")
    }
    
    static func date(isoString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return formatter.date(from: isoString)
    }
    
    static func timeAgo(since date: Date) ->  String {
        let calendar = Calendar.current
        let now = Date()
        let unitFlags = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfYear, .month, .year])
        let components = calendar.dateComponents(unitFlags, from: date, to: now)
        
        if let year = components.year {
            if year >= 2 {
                return "\(year) years ago"
            } else if year >= 1 {
                return "Last year"
            }
        }
        
        if let month = components.month {
            if month >= 2 {
                return "\(month) months ago"
            } else if month >= 1 {
                return "Last month"
            }
        }
        
        if let weekOfYear = components.weekOfYear {
            if weekOfYear >= 2 {
                return "\(weekOfYear) weeks ago"
            } else if weekOfYear >= 1 {
                return "Last week"
            }
        }
        
        if let day = components.day {
            if day >= 2 {
                return "\(day) days ago"
            } else if day >= 1 {
                return "Yesterday"
            }
        }
        
        if let hour = components.hour {
            if hour >= 2 {
                return "\(hour) hours ago"
            } else if hour >= 1 {
                return "An hour ago"
            }
        }
        
        if let minute = components.minute {
            if minute >= 2 {
                return "\(minute) minutes ago"
            } else if minute >= 1 {
                return "A minute ago"
            }
        }
        
        if let second = components.second {
            if second >= 3 {
                return "\(second) seconds ago"
            }
        }
        
        return "Just now"
    }
}
