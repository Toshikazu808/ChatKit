//
//  File.swift
//  ChatKit
//
//  Created by Ryan Kanno on 11/10/25.
//

import Foundation

extension Date {
    static var epochStart: Date {
        Date(timeIntervalSince1970: 0)
    }
    static let oneHourFromNow: Date = .now.plus(.oneHour)
    static let twoHoursFromNow: Date = .now.plus(.twoHours)
    static let threeHoursFromNow: Date = .now.plus(.threeHours)
    
    enum Time: Double {
        case halfHour = 1800 // (60sec. * 30min.)
        case oneHour = 3600 // (60sec. * 60min.)
        case twoHours = 7200
        case threeHours = 10800
    }
    
    func minus(_ time: Time) -> Date {
        return self - time.rawValue
    }
        
    func plus(_ time: Time) -> Date {
        return self + time.rawValue
    }
    
    enum DateFormat: String {
        case us = "M/d/yy"
        case asia = "yyyy/MM/dd"
        case exact = "yyyy-MM-dd'T'HH:mm:ss"
        case msgUS = "MMM d H:mm"
        case hourMinute = "h:mm a"
        case hour = "ha"
    }
    
    func toString(_ format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        return formatter.string(from: self)
    }
    
    func isEqualTo(_ date: Date) -> Bool {
        let lhs = self.timeIntervalSince1970.rounded(.towardZero)
        let rhs = date.timeIntervalSince1970.rounded(.towardZero)
        return lhs == rhs
    }
    
    func isGreaterThan(_ date: Date) -> Bool {
        let lhs = self.timeIntervalSince1970.rounded(.towardZero)
        let rhs = date.timeIntervalSince1970.rounded(.towardZero)
        return lhs > rhs
    }
    
    func isLessThan(_ date: Date) -> Bool {
        let lhs = self.timeIntervalSince1970.rounded(.towardZero)
        let rhs = date.timeIntervalSince1970.rounded(.towardZero)
        return lhs < rhs
    }
    
    func isGreaterOrEqualTo(_ date: Date) -> Bool {
        let lhs = self.timeIntervalSince1970.rounded(.towardZero)
        let rhs = date.timeIntervalSince1970.rounded(.towardZero)
        return lhs >= rhs
    }
    
    func isLessOrEqualTo(_ date: Date) -> Bool {
        let lhs = self.timeIntervalSince1970.rounded(.towardZero)
        let rhs = date.timeIntervalSince1970.rounded(.towardZero)
        return lhs <= rhs
    }
}
