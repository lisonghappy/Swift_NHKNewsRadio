//
//  SettingView.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/13.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject private var mvm: MainViewModel
    
    @State private var isAutoDownload: Bool = true
    @State private var isDeleteDownloadData: Bool = false
    
    
    
    var body: some View {
        NavigationView{
            List{
                play
                sort
                download
                feedback
                about
            }.navigationTitle("Setting")
        }
    }
}

#Preview {
    SettingView()
        .environmentObject(MainViewModel.mock)
}


extension SettingView {
    
    private var sort: some View {
        Section(header:Text("radio sort")) {
            Group{
                Text("newest to oldest")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "checkmark").opacity(mvm.isNewToOld ? 1: 0)
                            .foregroundStyle(Color.green)
                    }
                
                Text("oldest to newest")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .overlay(alignment: .trailing) {
                        Image(systemName: "checkmark").opacity(mvm.isNewToOld ? 0: 1)
                            .foregroundStyle(Color.green)
                    }
            }
            .frame(height: 35)
            .background(Color.primary.opacity(0.0001))
            .onTapGesture {
                mvm.changeSort()
            }
            
        }
    }
    
    private var play: some View {
        Section(header: Text("Radio Play Setting")) {
            if #available(*, iOS 16.0){
                appearancePicker
                
            }else{
                HStack{
                    Text("play jump seconds")
                    Spacer()
                    HStack(spacing: 0){
                        appearancePicker
                        Image(systemName: "chevron.up.chevron.down")
                            .resizable()
                            .frame(width: 10, height: 12.5)
                            .foregroundColor(.accent)
                    }
                }
                
            }
        }
    }
    
    private var appearancePicker: some View {
        Picker(
            selection: $mvm.jumpPlaySecond,
            label: Text("play jump seconds"),
            content: {
                ForEach(RadioPlayJumpSecond.allValues,id:\.self) { value in
                    HStack{
                        Text("\(value.rawValue)")
                            .tag(value)
                    }
                }
            })
        .pickerStyle(.menu)
    }
    
    private var download: some View {
        Section(header:Text("Download")) {
//            Toggle(
//                isOn: $isAutoDownload,
//                label: {
//                    Text("Auto Download")
//                        .fontWeight(.medium)
//                }
//            )
            
            Text("Delete Download Datas")
                .frame(height: 35)
                .frame(maxWidth: .infinity,alignment: .leading)
                .background(Color.accentColor.opacity(0.0001))
                .onTapGesture {
                    isDeleteDownloadData.toggle()
                }
                .foregroundStyle(Color.red)
                .alert(isPresented: $isDeleteDownloadData, content: {
                    Alert(
                        title: Text("Delete Download Datas"),
                        message: Text("Do you delete all downloaded radio datas?"),
                        primaryButton: .destructive((Text("Delete")) , action: {
                            isDeleteDownloadData.toggle()
                            mvm.deleteAllRadios()
                            mvm.soundService?.stopRadio()
                        }),
                        secondaryButton: .cancel(Text("Cancel"),action: {
                            isDeleteDownloadData.toggle()
                        })
                    )
                    
                })
        }
    }
    
    
    private var feedback: some View {
        Section(header:Text("feedback")) {
            Text("Report a problem")
            Text("Rate App 🌟")
            
        }
    }
    
    private var about: some View {
        Section(header:Text("About")) {
            VStack(alignment: .center) {
                Image("app_logo")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .cornerRadius(30)
                    .shadow(color: .black.opacity(0.15), radius: 10)
                Spacer(minLength: 10)
                Text(displayedName)
                    .fontWeight(.bold)
                Text("ver: \(appVersion)")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(alignment: .center)
        }
    }
    
    private var displayedName: String {
         let bundleDisplayName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
         return bundleDisplayName ?? "Radio of NHK News"
     }
    
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }
    
}
