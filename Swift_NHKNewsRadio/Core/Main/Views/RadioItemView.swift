//
//  RadioItemView.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/13.
//

import SwiftUI

struct RadioItemView: View {
    @EnvironmentObject private var mvm: MainViewModel
    @EnvironmentObject private var soundService: SoundService
    
    @Binding var radio: RadioModel
    @Binding var selectedRadio: RadioModel?

    @State private var isDeleteRadio: Bool = false

    
    
    var body: some View {
        HStack {
            content
            actionBtn
        }
//        .readingLocation(onChange: { location in
//            checkVisible(location: location)
//        })
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            leftSwipeActions()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            rightSwipeActions()
        }
        
    }
}

#Preview {
    List{
        RadioItemView(radio: .constant(RadioModel.mock), selectedRadio: .constant(RadioModel.mock))
            .environmentObject(MainViewModel.mock)
            .environmentObject(SoundService.mock)
    }
    .background(Color.theme.background)
}


extension RadioItemView {
    
    private func checkVisible(location: CGPoint) {
        if !isSelected { return }
        mvm.isRadioInVisible = location.y < 75 || location.y > mvm.InVisibleMaxY - 10
    }
    
    
    private var isSelected: Bool {
        selectedRadio != nil && selectedRadio!.id == radio.id
    }
    
    private func leftSwipeActions() -> some View {
        Button {
            mvm.changeRadioMarkState(radio: radio, state: !radio.isMark)
        } label: {
            Image(systemName: radio.isMark ? "bookmark.fill" : "bookmark")
        }
        .tint(.accent)
    }
    
    private func rightSwipeActions() -> some View {
        if radio.isDownloaded {
            Button {deleteRadio()} label: { Image(systemName: "trash")}
                .tint(.red)
        }else {
            Button { downloadRadio() } label: { Image(systemName: "arrow.down.circle") }
                .tint(.accent)
        }
    }
    
    private func playRadio() {
        if let selectedRadio = selectedRadio, selectedRadio.id == radio.id {
            mvm.isRadioInVisible = false
            soundService.pauseOrResumeRadio()
        }else {
            if radio.isDownloaded {
                if soundService.playRadio(radio: radio) {
                    selectedRadio = radio
                    mvm.isRadioInVisible = false
                }
                print("asdasd     2")
            }else {
                mvm.isNeedDownload.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    mvm.isNeedDownload.toggle()
                }
                print("asdasd     3")
            }
        }
    }
    
    private func downloadRadio() {
        mvm.downloadRadio(radio: radio)
    }
    
    private func deleteRadio() {
        mvm.deleteRadio(radio: radio)
    }
    
    private var  mark: some View {
        ZStack{
            if radio.isMark {
                Image(systemName: "bookmark.fill")
                    .foregroundStyle(Color.accent)
            }
        }
    }
    
    private var playingAnime: some View {
        RoundedRectangle(cornerRadius: 25.0)
            .frame(width: 20,height: 20)
            .foregroundStyle(Color.accent)
    }
    
    private var  radioInfo: some View {
        VStack(alignment: .leading) {
            Text(radio.rawData.title)
                .font(.headline)
                .lineLimit(1)
                .foregroundColor(isSelected ? Color.accent : Color.primary)
            
            if !radio.rawData.description.isEmpty {
                Text(radio.rawData.description)
                    .font(.subheadline)
                    .opacity(0.35)
                    .lineLimit(2)
                    .foregroundColor(isSelected ? Color.accent : Color.primary)

            }
            
            Text("\(radio.rawData.duration) | \(radio.FileSize) ")
                .font(.caption2)
                .opacity(0.25)
                .padding(.vertical, 0)
        }
    }
    

    
    private var content: some View {
        HStack {
            mark
            radioInfo
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.0001))
        .onTapGesture {
            playRadio()
        }
    }
        
    private var actionBtn: some View {
        Group{
            if radio.isNoDownloadFormServer {
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.red.opacity(0.5))
            }else if radio.isDownloading {
                ProgressView()
            }else {
                Image(systemName: radio.isDownloaded ? "checkmark.circle" : "arrow.down.circle")
                    .foregroundStyle(radio.isDownloaded ? Color.accent : Color.primary.opacity(0.5))
            }
        }
        .frame(width: 30, height: 30)
        .background(Color.primary.opacity(0.00001))
        .onTapGesture {
            if radio.isDownloading {
                return
            }else if radio.isDownloaded {
                isDeleteRadio = true
            }else {
                downloadRadio()
            }
        }
        .alert(isPresented: $isDeleteRadio, content: {
            Alert(
                title: Text("Delete Radio"),
                message: Text("Do you delete radio data?\n\(radio.rawData.title)"),
                primaryButton: .destructive((Text("Delete")) , action: {
                    isDeleteRadio = false
                    deleteRadio()
                }),
                secondaryButton: .cancel(Text("Cancel"),action: {
                    isDeleteRadio = false
                })
            )
            
        })
    }
}
