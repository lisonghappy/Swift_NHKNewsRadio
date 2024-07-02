//
//  Utils.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/6/1.
//

import Foundation
import UIKit


class Utils {
    
    static func pasteTextToClipBoard(txt: String?){
        
        guard let txt = txt else{ return}
        
        UIPasteboard.general.string = txt
        
    }
}
