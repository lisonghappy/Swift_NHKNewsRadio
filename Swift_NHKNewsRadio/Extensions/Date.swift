//
//  Date.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/18.
//

import Foundation


extension Date {
    
    // "Wed, 15 May 2024 12:15:00 +0900"
    init(pubDateString: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        formatter.timeZone = TimeZone(secondsFromGMT: 32400)
        let date = formatter.date(from: pubDateString) ?? Date()
        self.init(timeInterval: 0, since: date)
    }
    
    
    func asShortDateString() -> String {
        return shortFormatter.string(from: self)
    }
    
    
    private var shortFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: 32400)
        return formatter
    }
}
