//
//  PlayBarView.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/13.
//

import SwiftUI
import AVFAudio


struct PlayBarView: View {
    @EnvironmentObject private var mvm: MainViewModel
    @EnvironmentObject private var soundService: SoundService
    
    @Binding var radio: RadioModel?
    @Binding var currentTime: Double
    
    @State private var isShowPlayView: Bool = false
    
    
    
    
    
    var body: some View {
        ZStack {
            if  radio != nil {
                bodyView()
            }
        }
    }
}

#Preview {
    PlayBarView(radio: .constant(RadioModel.mock), currentTime: .constant(0))
        .environmentObject(MainViewModel.mock)
        .environmentObject(SoundService.mock)
}

extension PlayBarView {
    
    private func bodyView() -> some View {
        HStack {
            radioImage
            contentInfo
            playState
        }
        .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20.0)
        .padding(.horizontal)
        .onTapGesture {
            isShowPlayView.toggle()
        }
        .sheet(isPresented: $isShowPlayView, content: {
            PlayView(radio: $radio, currentTime: $currentTime)
        })
        .gesture(
            DragGesture()
                .onChanged { value in
                    checkSwipe(size: value.translation)
                }
        )
        .readingLocation { location in
            mvm.InVisibleMaxY = location.y
        }
    }
    
    private var radioImage: some View{
        Image( "app_logo")
            .resizable()
            .frame(width: 50, height: 50)
            .cornerRadius(5)
            .overlay(alignment: .bottom, content: {
                if let player = soundService.player {
                    radioPlayState(player: player)
                }
            })
    }
    
    
    private func radioPlayState(player: AVAudioPlayer) -> some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(Color.accent)
            .frame(maxWidth:  40 * currentTime / player.duration)
            .frame(height: 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.gray.cornerRadius(5).opacity(0.5))
            .padding(.horizontal,5)
            .padding(.vertical,2.5)
    }
    
    private var contentInfo: some View {
        VStack(alignment: .leading){
            if let radio = radio {
                Text(radio.rawData.title)
                    .font(.headline)
                    .lineLimit(1)
                
                if !radio.rawData.description.isEmpty {
                    Text(radio.rawData.description)
                        .font(.subheadline)
                        .opacity(0.5)
                        .lineLimit(2)
                }
            }else {
                Text("no radio")
                    .font(.headline)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var playState : some View {
        HStack(spacing: 10){
//            Button {
//                mvm.changeRadioPlayType()
//            } label: {
//                Image(systemName: mvm.repeatType == 0 ? "arrow.forward.to.line" : (mvm.repeatType == 1 ? "repeat.1" : "repeat") )
//                    .frame(width: 30, height: 30)
//                    .foregroundColor(.accent)
//                    .background(Color.gray.cornerRadius(20.0).opacity(0.025))
//            }
            Button(action: {
                soundService.pauseOrResumeRadio()
            }, label: {
                Image(systemName: soundService.isPlaying ? "pause.fill" : "play.fill")
                    .frame(width: 30, height: 30)
                    .foregroundColor(.accent)
                    .background(Color.gray.cornerRadius(20.0).opacity(0.1))
            })
            
        }
    }
    
    private func checkSwipe(size: CGSize) {
        if !isShowPlayView && size.height < -100 {
            isShowPlayView.toggle()
        }
    }
    
}
