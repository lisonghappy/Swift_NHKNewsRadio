//
//  NHKNewsRadioModel.swift
//  Swift_NHKNewsRadio
//
//  Created by lisong on 2024/5/16.
//

import Foundation


public struct NHKNewsRadioModel : Equatable, Codable {
    
    // origin data
    var title: String = ""
    var link: String = ""
    var language: String = ""
    var copyright: String = ""
    var author: String = ""
    var description :String = ""
    var category :String = ""
    var image :String = ""
    var lastBuildDate :String = ""
    var keywords :String = ""
    var email :String = ""
    var explicit :Bool = false
    var newFeedUrl :String = ""
    
    // items
    var items: [RadioModel] = []
    
    //---------------------------------------------
}
