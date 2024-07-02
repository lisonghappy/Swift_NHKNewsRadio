//
//  NHKRadioNewsSoundService.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/6/15.
//

import Foundation


extension SoundService {
    
    
    func playRadio(radio : RadioModel)-> Bool {
        let path = LocalFileManager.instance.getSaveFilePath(forResource: MainViewModel.getRadioFilePath(rdioFileName: radio.fileName))
        return playSound(url: path,title: radio.rawData.title)
    }
    
    
    
    func pauseOrResumeRadio(){
        guard let player = player else { return }

        if player.isPlaying {
            pause()
        }else {
            resume()
        }
    }
    
    func stopRadio(){
        stop()
        isFinished = false
        isEditing = false
        player = nil
    }
}
