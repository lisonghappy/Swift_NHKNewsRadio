//
//  Swift_NHKNewsRadioApp.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/7/3.
//

import SwiftUI

@main
struct Swift_NHKNewsRadioApp: App {
    @StateObject private var mvm = MainViewModel()
    @StateObject private var soundService = SoundService()


    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(mvm)
                .environmentObject(soundService)
        }
    }
}
