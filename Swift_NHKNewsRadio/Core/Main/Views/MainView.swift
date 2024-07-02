//
//  MainView.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/13.
//

import SwiftUI



struct MainView: View {
    @EnvironmentObject private var mvm: MainViewModel
    @EnvironmentObject private var soundService: SoundService
    
    
    @State private var currentTime: Double = 0.0
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    
    
    var body: some View {
        NavigationView{
            List {
                if mvm.radioSections.count < 0 {
                    noRadioTip
                } else {
                    radioList
                    noMoreRadioTip
                    
                }
            }
            .refreshable {
                await mvm.getData()
            }
            .navigationTitle("NHK Radios")
            .toolbar(content: {
//                ToolbarItem(placement: .topBarLeading) {
//                    DatePickBarView()
//                }
                ToolbarItem(placement: .topBarTrailing) {
                    SettingBarView()
                }
            })
        }
        .overlay(alignment: .bottom) {
            PlayBarView(radio: $mvm.selectedRadio, currentTime: $currentTime)
        }
//        .overlay(alignment: .top, content: {
//            LocationBarViewLoadingView(radio: $mvm.radio)
//                .offset(y: 39)
//                .opacity(mvm.isRadioInVisible ? 1 : 0)
//        })
        .overlay(alignment: .center, content: {
            ZStack {
                downloadFileedTips
                needDownloadTips
            }
        })
        .onAppear{
            mvm.soundService = soundService
            mvm.getDataFromCache()
        }
        .onReceive(timer) { _ in
            guard let player = soundService.player else { return }
            if !soundService.isEditing {
                currentTime = player.currentTime
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(MainViewModel.mock)
        .environmentObject(SoundService.mock)
}


extension MainView {
    
    private var noRadioTip: some View {
        VStack{
            Spacer(minLength: 120)
            Text("Pull down to refresh the data.")
                .fontWeight(.bold)
                .font(.subheadline)
                .opacity(0.5)
                .frame(maxWidth: .infinity)
            Spacer(minLength: 120)
        }
    }
    
    private var radioList: some View {
        ForEach($mvm.radioSections) { $section in
            RadioSectionView(radioSection: $section, selectedRadio: $mvm.selectedRadio)
        }
    }
    
    private var noMoreRadioTip: some View {
        VStack{
            Spacer(minLength: 10)
            Text("There is no more data.")
                .font(.subheadline)
                .opacity(0.25)
                .frame(maxWidth: .infinity)
            Spacer(minLength: 10)
        }
    }
    
    
    private var downloadFileedTips: some View {
        VStack{
            Image(systemName: "exclamationmark.icloud")
                .resizable()
                .scaledToFit()
                .frame(width: 70,height: 50)
                .padding()
                .opacity(0.5)
            
            Text("download radio failed !")
                .font(.callout)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15.0)
        .animation(.spring)
        .offset(y: mvm.isDownloadFailed ? 0 :50)
        .opacity(mvm.isDownloadFailed ? 1 : 0)
    }
    
    private var needDownloadTips: some View {
        VStack{
            Image(systemName: "exclamationmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 50,height: 50)
                .padding()
                .opacity(0.5)
            
            Text("Please download it before playing！")
                .font(.callout)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15.0)
        .animation(.spring)
        .offset(y: mvm.isNeedDownload ? 0 :50)
        .opacity(mvm.isNeedDownload ? 1 : 0)
    }
    
}
