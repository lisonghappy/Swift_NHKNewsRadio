//
//  DatePickView.swift
//  Swift_NHKNewsRadio
//
//  Created by LiSong on 2024/5/14.
//

import SwiftUI

struct DatePickView: View {
    @EnvironmentObject private var mvm: MainViewModel

    @State var selectedDate: Date = Date()
    
    let startingDate: Date
    let endingDate: Date = Date()
    
    init(startingDate: Date){
        self.startingDate = startingDate
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
    
    var body: some View {
        NavigationView{
            ScrollView {
                VStack {
                    Spacer()
                    
                    DatePicker("Select a date", selection: $selectedDate, in: startingDate...endingDate, displayedComponents: [.date])
                        .tint(Color.accent)
                        .datePickerStyle(.graphical)
                    
                    Spacer()
                    
                    HStack{
                        Text("Date: ")
                        Text(dateFormatter.string(from: selectedDate))
                            .font(.title)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(alignment: .leading)
                }
            }
            .navigationTitle("Radio Date")
        }
    }
}

#Preview {
    DatePickView(startingDate: Date())
        .environmentObject(MainViewModel.mock)
}
