//
//  RadioModel.swift
//  Swift_NHKNewsRadio
//
//  Created by lisong on 2024/5/16.
//

import Foundation

/*
 
 <item>
 <title>05月15日 正午のNHKニュース</title>
 <enclosure url="https://www.nhk.or.jp/s-media/news/podcast/audio/32f39d7fa1923a9e3a8ec21af99754f9_64k.mp3" length="7089350" type="audio/mp3"/>
 <pubDate>Wed, 15 May 2024 12:15:00 +0900</pubDate>
 <guid isPermaLink="false">32f39d7fa1923a9e3a8ec21af99754f9</guid>
 <description>【主なニュース】▼診療報酬事業うたい約80億円を違法集金か 会社社長ら逮捕　▼早大入試 スマートグラスでSNS流出か 18歳受験生を書類送検へ　▼水原元通訳 形式的に無罪主張 今月中にも起訴内容認める見通し　など</description>
 <itunes:duration>00:14:46</itunes:duration>
 </item>
 
 */

// radio raw data
public struct RawRadioModel: Hashable, Codable {
    var title: String = ""
    var url: String = ""
    var length: Double = 0
    var type: String = ""
    var pubDate: String = ""
    var guid: String = ""
    var isPermaLink: Bool = false
    var description: String = ""
    var duration: String = ""
}


public struct RadioModel : Identifiable, Equatable, Hashable, Codable {
    
    // raw data
    var rawData : RawRadioModel
    
    // state
    var isPlay: Bool = false
    var isPlayOver: Bool = false
    var isDownloaded: Bool = false
    var isDownloading: Bool = false
    var isNoDownloadFormServer: Bool = false
    var isMark: Bool = false
    
    
    
    public var id: String {
        return rawData.guid
    }
    
    public static func == (lhs: RadioModel, rhs: RadioModel) -> Bool {
        lhs.id == rhs.id
    }
    
    var PubDate: Date {
        return Date(pubDateString: rawData.pubDate)//.addingTimeInterval(TimeInterval(32400))
    }
    
    
    var fileName: String {
        if let url = URL(string: rawData.url) {
            let pathComponents = url.pathComponents
            if let lastComponent = pathComponents.last {
                return lastComponent
            }
        }
        
        return ""
    }
    
    var FileSize: String {
        let val = rawData.length.formattedWithAbbreviations2()
        return "\(val.0) \(val.1)"
    }
    
}



extension RadioModel {
    
    static let mock  = RadioModel(
        rawData: RawRadioModel(
            title: "05月15日 正午のNHKニュース",
            url: "https://www.nhk.or.jp/s-media/news/podcast/audio/32f39d7fa1923a9e3a8ec21af99754f9_64k.mp3",
            length: 7089350,
            type: "audio/mp3",
            pubDate: "Wed, 15 May 2024 12:15:00 +0900",
            isPermaLink: false,
            description:  "【主なニュース】▼診療報酬事業うたい約80億円を違法集金か 会社社長ら逮捕　▼早大入試 スマートグラスでSNS流出か 18歳受験生を書類送検へ　▼水原元通訳 形式的に無罪主張 今月中にも起訴内容認める見通し　など",
            duration: "00:14:46"
        )
    )
    
    static let mocks = [
        mock,mock
    ]
    
}
