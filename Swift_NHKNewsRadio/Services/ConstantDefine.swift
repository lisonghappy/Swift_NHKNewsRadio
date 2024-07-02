//
//  ConstantDefine.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/6/19.
//

import Foundation



class Constant {
    static let  NHKNewsRadioURL : String = "https://www.nhk.or.jp/s-media/news/podcast/list/v1/all.xml"
    static let  NHKNewsRadioURL_Back : String = "http://www.nhk.or.jp/r-news/podcast/nhkradionews.xml"
}


//MARK: radio play jump second
enum RadioPlayJumpSecond : Int, CaseIterable {
    case _2 = 2
    case _5 = 5
    case _10 = 10
    case _15 = 15

    static let allValues = [_2, _5, _10, _15]
}
