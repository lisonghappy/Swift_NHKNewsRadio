//
//  PlayView.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/13.
//

import SwiftUI

struct PlayView: View {
    @EnvironmentObject private var mvm: MainViewModel
    @EnvironmentObject private var soundService: SoundService

    @State private var sliderValue: Double = 0
    @State private var isChangePlayMode: Bool = false
    
    @Binding var radio: RadioModel?
    @Binding var currentTime: Double

    


    
    
    var body: some View {
        ZStack{
            ScrollView{
                VStack{
                    Spacer()
                    logo
                    Spacer(minLength: 100)
                    playSlider
                    play
                    Spacer()
//                    playState
                    Spacer(minLength: 100)
                    content
                    Spacer(minLength: 50)
                    info
                }
                .padding()
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .onAppear{
            guard let player = soundService.player else { return }
            currentTime = player.currentTime
        }
    }
}

#Preview {
    PlayView(radio: .constant(RadioModel.mock), currentTime: .constant(0))
        .environmentObject(MainViewModel.mock)
        .environmentObject(SoundService.mock)
}



extension PlayView {
    private var logo: some View {
        Image( "app_logo")
            .resizable()
            .frame(width: 250, height: 250)
            .cornerRadius(20)
            .shadow(color: .primary.opacity(0.15), radius: 10, y: 10)
    }
    
    private var content: some View {
        VStack(alignment: .leading){
            HStack{
                Text(radio?.rawData.title ?? "")
                    .font(.headline)
                    .textSelection(.enabled)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            
            Text(radio?.rawData.description ?? "")
                .font(.footnote)
                .opacity(0.75)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity)
        .frame(alignment: .leading)
       
    }
    
    private var playSlider: some View {
        VStack{
            if let player = soundService.player {
                
                Slider(value: $currentTime, in: 0...player.duration) { editing in
                    soundService.isEditing = editing
                    if !editing {
                        player.currentTime = currentTime
                    }
                }
                
                HStack{
                    Text(currentTime.TimeString)
                    Spacer()
                    Text(radio?.rawData.duration ?? "")
                }
                .foregroundColor(.secondary)
            }
            
        }
    }
    
    private var play: some View {
        HStack{
            Button {
                guard let player = soundService.player else { return }
                //back play
                let jumpTime = mvm.jumpPlaySecond.rawValue
                let time = player.currentTime - TimeInterval(jumpTime)
                soundService.seek(to: time)
            } label: {
                ZStack{
                    Image(systemName: "gobackward")
                    Text("\(mvm.jumpPlaySecond.rawValue)")
                        .font(.system(size: 8))
                        .fontWeight(.bold)
                        .offset(y: 1)
                }
            }
            
            Spacer()
            
            Button(action: {
                soundService.pauseOrResumeRadio()
            }, label: {
                Image(systemName: soundService.isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .frame(width: 35, height: 40)
            })
            Spacer()
            Button {
                //forward play
                guard let player = soundService.player else { return }
                //back play
                let jumpTime = mvm.jumpPlaySecond.rawValue
                let time = player.currentTime + TimeInterval(jumpTime)
                soundService.seek(to: time)
            } label: {
                ZStack{
                    Image(systemName: "goforward")
                    Text("\(mvm.jumpPlaySecond.rawValue)")
                        .font(.system(size: 8))
                        .fontWeight(.bold)
                        .offset(y: 1)
                }
            }
        }
        .padding(50)
        
    }
    
    
    private var playState: some View {
        HStack{
            if let radio = radio {
                Button {
                    mvm.changeRadioMarkState(radio: radio)
                } label: {
                    Image(systemName: radio.isMark ? "bookmark.fill" :"bookmark")
                }
            }else {
                Image(systemName: "bookmark")
            }

            Spacer()
            
            Button {
                mvm.changeRadioPlayType()
            } label: {
                Image(systemName: mvm.repeatType == 0 ? "arrow.forward.to.line" : (mvm.repeatType == 1 ? "repeat.1" : "repeat") )
            }
            Spacer()
            
            
            Button {
                
            } label: {
                ZStack{
                    Text("1.5")
                        .font(.footnote)
                    Text("X")
                        .offset(x:15,y: -2.5)
                }
            }
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "airplayaudio")
            }
            
        }
        .padding(.horizontal,50)
    }
    
    
    private var info: some View {
        
        VStack(alignment: .leading){
            Text("Informations")
                .font(.title2)
                .opacity(0.25)
            Divider()
            VStack{
                if let radio = radio {
                    HStack{
                        Text("Published")
                        Spacer()
                        Text(radio.rawData.pubDate)
                    }
                    HStack{
                        Text("Duradion")
                        Spacer()
                        Text(radio.rawData.duration)
                    }
                    .padding(.vertical, -5)
                    
                    HStack{
                        Text("Size")
                        Spacer()
                        Text(radio.FileSize)
                    }
                    .padding(.vertical, 0.5)
                }
                
            }
            .font(.caption)
             
        }
        
    }
    
}
