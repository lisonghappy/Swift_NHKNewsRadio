//
//  DatePickBarView.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/14.
//

import SwiftUI

struct DatePickBarView: View {
    @EnvironmentObject private var mvm: MainViewModel
    @State private  var isShowDatePickView: Bool  = false

    
    var body: some View {
        Image(systemName: "calendar")
            .frame(width: 50,height: 40)
            .onTapGesture {
                isShowDatePickView.toggle()
            }
            .sheet(isPresented: $isShowDatePickView, content: {
                DatePickView(startingDate: mvm.oldNestDate)
            })
    }
}

#Preview {
    DatePickBarView()
        .environmentObject(MainViewModel.mock)
}        

