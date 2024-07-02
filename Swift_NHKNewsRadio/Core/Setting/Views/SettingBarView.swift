//
//  SettingBarView.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/13.
//

import SwiftUI

struct SettingBarView: View {
    @EnvironmentObject private var mvm: MainViewModel
    @State private var isShowSettingView: Bool = false
    
    var body: some View {
        Image(systemName: "gearshape")
            .frame(width: 50,height: 40)
            .onTapGesture {
                isShowSettingView.toggle()
            }
            .sheet(isPresented: $isShowSettingView, content: {
                SettingView()
            })
    }
}

#Preview {
    SettingBarView()
        .environmentObject(MainViewModel.mock)
}
