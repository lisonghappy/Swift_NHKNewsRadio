//
//  String.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/6/2.
//

import Foundation


extension TimeInterval {
    
    var TimeString: String {
        if  self == 0 {
            return "00:00:00"
        }
        let time = Int(self)

        let seconds:Int = time % 60
        let minutes:Int = (time / 60) % 60
        let hours:Int = (time / 3600) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    
}
