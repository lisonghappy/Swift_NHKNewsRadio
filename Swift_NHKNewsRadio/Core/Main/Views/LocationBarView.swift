//
//  LocationBarView.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/19.
//

import SwiftUI


struct LocationBarViewLoadingView: View {
    
    @Binding var radio: RadioModel?

    var body: some View {
        ZStack {
            if let radio = radio {
                LocationBarView(radio: radio)
            }
        }
    }
    
}



struct LocationBarView: View {
    private var radio: RadioModel
    
    init(radio: RadioModel) {
        self.radio = radio
    }
    
    var body: some View {
        VStack(alignment: .leading){
            Text(radio.rawData.title)
                .lineLimit(1)
                .frame(alignment: .leading)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(.thickMaterial)
        }
        .foregroundStyle(Color.accent)
        .onTapGesture {
            
        }
    }
}

#Preview {
    LocationBarView(radio: RadioModel.mock)
}
