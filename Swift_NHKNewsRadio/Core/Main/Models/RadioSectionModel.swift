//
//  RadioSectionModel.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/18.
//

import Foundation


struct RadioSectionModel: Identifiable {
    
    var date: String
    var radios: [RadioModel]
    var count: Int = 0
    var downloadedCount: Int = 0
    
    
    var id: String {
        return date
    }
}

extension RadioSectionModel {
    
    static let mock  = RadioSectionModel(date: Date.now.asShortDateString(), radios: RadioModel.mocks)
}
