//
//  AVDelegate.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/6/2.
//

import Foundation
import MediaPlayer

public class AVDelegate: NSObject, AVAudioPlayerDelegate{
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        NotificationCenter.default.post(name: NSNotification.Name("Finish"), object: nil)
    }
}


