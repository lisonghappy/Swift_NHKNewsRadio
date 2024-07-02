//
//  RadioSectionView.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/13.
//

import SwiftUI

struct RadioSectionView: View {
    @EnvironmentObject private var mvm: MainViewModel
    
    @Binding var radioSection: RadioSectionModel
    @Binding var selectedRadio: RadioModel?

    @State private var showActionSheet: Bool = false
    
    
    
    var body: some View {
        Section(
            header:
                HStack{
                    Text("\(radioSection.date) (\(radioSection.downloadedCount)/ \(radioSection.count))")
                        .font(.headline)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button(action: {
                        showActionSheet.toggle()
                    }, label: {
                        Image(systemName: "ellipsis")
                            .frame(width: 30, height: 30)
                    })
                }
        ) {
            ForEach($radioSection.radios) { $item in
                RadioItemView(radio: $item, selectedRadio: $selectedRadio)
            }
            
        }
        .actionSheet(isPresented: $showActionSheet, content: getActionSheet)
        
    }
}

#Preview {
    List{
        RadioSectionView(radioSection: .constant(RadioSectionModel.mock), selectedRadio: .constant(RadioModel.mock))
            .environmentObject(MainViewModel.mock)
    }
}


extension RadioSectionView {
    
    func getActionSheet() -> ActionSheet {
        
        let downloadedCount = radioSection.downloadedCount
        let needDownloadCount = radioSection.count - downloadedCount
        
        let markCount = radioSection.radios.filter{$0.isMark}.count
        
        
        let markButton: ActionSheet.Button = .default(Text("Mark all radio.")) {
            let radios = radioSection.radios.filter{!$0.isMark}
            mvm.markRadios(radios: radios)
        }
        
        let unmarkButton: ActionSheet.Button = .default(Text("Unmark all radio.")) {
            let radios = radioSection.radios.filter{$0.isMark}
            mvm.unmarkRadios(radios: radios)
        }
        
        
        let downloadButton: ActionSheet.Button = .default(Text("Download all \(needDownloadCount) piece(s) of radio.")) {
            let radios = radioSection.radios.filter{!$0.isDownloaded}
            mvm.downloadRadios(radios: radios)
        }
        
        let deleteButton: ActionSheet.Button = .destructive(Text("Delete all \(downloadedCount) piece(s) of radio.")) {
            let radios = radioSection.radios.filter{$0.isDownloaded}
            mvm.deleteRadios(radios: radios)
        }
        
        let cancelButton: ActionSheet.Button = .cancel()
        
        let title = Text("\(radioSection.date)")
        let message = Text("NHK Radio News")
        
        
        var actionSheetBtns: [ActionSheet.Button] = []
        
        
        if markCount == radioSection.count {
            actionSheetBtns.append(unmarkButton)
        }else {
            actionSheetBtns.append(markButton)
        }
        
        if needDownloadCount == 0 {
            actionSheetBtns.append(deleteButton)
        }else if radioSection.count == needDownloadCount {
            actionSheetBtns.append(downloadButton)
        }else {
            actionSheetBtns.append(downloadButton)
            actionSheetBtns.append(deleteButton)
        }
        actionSheetBtns.append(cancelButton)
        
        return ActionSheet(
            title: title,
            message: message,
            buttons: actionSheetBtns)
    }
}
