//
//  SoundService.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/19.
//

import SwiftUI
import Foundation
import AVKit
import MediaPlayer

final class SoundService: ObservableObject {
            
//    static let instance = SoundService() // Singleton
    
    var player: AVAudioPlayer?
    @Published var isFinished: Bool = false
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var isLooping: Bool = false
    @Published var isEditing: Bool = false

    private var del = AVDelegate()

    
    
    
    
    
    
    init(){
        setupRemoteTransportControls()
        audioSessionConfig()
        observerSoundFinish()
        observerPlayInterrupt()
    }
    
    
    deinit{
        NotificationCenter.default.removeObserver(NSNotification.Name("Finish"))
        NotificationCenter.default.removeObserver(AVAudioSession.interruptionNotification)
    }
    
    
    //MARK:  ================== PLAY SOUND ==================
    func playSound(fileName: String, title: String = "")-> Bool {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: ".mp3") else { return  false  }
        return playSound(url: url)
    }
    
    func playSound(url: String, title: String = "")-> Bool {
        guard let url = URL(string: url) else { return  false  }
        return playSound(url: url)
    }
    
    
    func playSound(url: URL?, title: String = "")-> Bool {
        guard let url = url else { return  false }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return  false }
            player.delegate = self.del
            player.play()
            setupNowPlaying(title: title)
            isPlaying = true
            return  true
        } catch let error {
            print("Error playing sound. \(error.localizedDescription)")
            isPlaying = false
            return  false
        }
    }
    
    //MARK:  ---------------------- Sound State Control ------------------------
    
    func play(){
        guard let player = player else { return }
        player.play()
        isPlaying = true
    }
    
    func pause(){
        guard let player = player else { return }
        player.pause()
        isPlaying = false
    }
    

    func resume(){
        guard let player = player else { return }
        player.play()
        isPlaying = true
    }
    
    
    func stop(){
        guard let player = player else { return }
        player.stop()
        isPlaying = false
    }
    
    func seek(to time: TimeInterval){
        guard let player = player else { return }

        var _time = time
        if time < 0 {
            _time = 0
        }else if time > player.duration {
            _time = player.duration
        }
        player.currentTime = _time
    }
    
    //MARK:  ---------------------- Media Center Control ------------------------

    private func setupNowPlaying(title: String) {
        guard let player = player else { return }
        
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        
        if let image = UIImage(named: "nhk_logo") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in
                return image
            }
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        // Set the metadata
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    
    
    
    //MARK: background audio play state control
    private func audioSessionConfig() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    //MARK: remote control
    private func setupRemoteTransportControls() {
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [self] event in
            if !isPlaying {
                play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [self] event in
            if isPlaying {
                pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    //MARK: observer finish state
    private func observerSoundFinish(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Finish"), object: nil, queue: .main) { (_) in
            self.isFinished = true
            self.isPlaying = false
        }
    }
    
    //MARK: observer play interrupt state
    private func observerPlayInterrupt() {
            
            NotificationCenter.default.addObserver(
                forName: AVAudioSession.interruptionNotification,
                object: nil,
                queue: .main
            ) { notification in
                guard let userInfo = notification.userInfo,
                      let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
                      let interruptionType = AVAudioSession.InterruptionType(rawValue: typeValue) else {
                    return
                }

                if interruptionType == .began {
                    self.pause()
                } else if interruptionType == .ended {
                    self.resume()
                }
            }
        }
    

}


extension SoundService {
    static let mock = SoundService()
}
