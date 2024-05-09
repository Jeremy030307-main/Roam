//
//  ItineraryTopNavBar.swift
//  Roam
//
//  Created by Jeremy Teng  on 29/04/2024.
//

import SwiftUI

struct ItineraryTopNavBar: View {
    
    var totalDays: Int
    var startDate: Date?
    var endDate: Date?
    
    @Binding var daySelected: Int
    @Namespace var tabAnimation
    @State private var textHeight : CGFloat?
    
    var body: some View {
        ScrollViewReader{ scrollDay in
            ScrollView(.horizontal) {
                HStack{
                    ForEach(1..<totalDays+1, id: \.self){ day in
                        Button{
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.daySelected = day
                                scrollDay.scrollTo(day, anchor: .center)
                            }
                        } label: {
                            ZStack{
                                VStack{
                                    Text("Day \(day)").font(.headline)
                                    if let start: Date = startDate{
                                        let calender = Calendar.current
                                        let date = calender.date(byAdding: .day, value: day-1, to: start) ?? start
                                        Text(formatDate(date:date)).font(.subheadline)
                                    }
                                }
                                .foregroundStyle(daySelected == day ? .accent:.black)
                                .padding(10)
                                .background(
                                    GeometryReader { geometry in
                                        Path { path in
                                            let height = geometry.size.height
                                            DispatchQueue.main.async {
                                                if self.textHeight != height {
                                                    self.textHeight = height
                                                }
                                            }
                                        }
                                    })
                                
                                if daySelected == day {
                                    Capsule()
                                        .frame(height: 5)
                                        .foregroundStyle(.accent)
                                        .offset(y: (textHeight ?? 1)/2)
                                        .matchedGeometryEffect(id: "selectedID", in: tabAnimation)
                                }
                            }
                        }
                        .id(day)
                    }
                }
                .padding(.horizontal)
                
            }
            .scrollIndicators(.hidden)
        }
    }
    
    func formatDate(date: Date)-> String{
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "EEE MM/dd"
           let weekDay = dateFormatter.string(from: date)
           return weekDay
     }
}

#Preview {
    ItineraryTopNavBar(totalDays: 10,startDate: formatter.date(from: "2022/12/16") ?? .now ,daySelected: .constant(1))
}
