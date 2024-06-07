//
//  ItineraryView.swift
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

struct ItineraryDayView: View {
    
    @ObservedObject var tripManager: TripManager
    @State var screenWidth: CGFloat?
    
    let day: Int
    let editable: Bool
    
    var body: some View {
        ScrollViewReader{ scrollProxy in
            ScrollView(.vertical) {
                ZStack{
                    HStack{
                        VerticalLine()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [8]))
                            .padding(.leading, 78)
                            .foregroundStyle(.accent).opacity(0.5)
                        Spacer()
                    }
                    
                    VStack(spacing: 0){
                        ForEach(1..<25){x in
                            VStack(alignment: .leading){
                                HStack(alignment: .bottom){
                                    Text("")
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .frame(height: 90)
                            .border(Color.black, width: 0.2)
                            .opacity(0.5)
                        }
                        Spacer()
                    }
                    
                    VStack(alignment: .leading, spacing: 0){
                        ForEach(Array(tripManager.trip.events[day-1].events.enumerated()), id: \.1.id) {index, event in
                            let eventDistance = tripManager.getDistanceTwoEvent(day: day, eventIndex: index)
                            VStack{
                            }
                            .frame(maxWidth: .infinity)
                            .border(Color.black)
                            .frame(height: CGFloat(eventDistance))
                            .padding(0)
                            EventCardView(event: event, day: self.day, eventIndex: index, editable: editable)
                                .padding(.horizontal)
                                .id(index)
                                .environmentObject(tripManager)
                        }
                        Spacer()
                    }
                }
                .frame(minHeight: 2160)
            
            }
            .onAppear{
                scrollProxy.scrollTo(0, anchor: .top)
            }
            .background(Color(.secondarySystemBackground))
            .background(
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width
                        DispatchQueue.main.async {
                            if self.screenWidth != width {
                                self.screenWidth = width
                            }
                        }
                    }
                })
        }
    }
}

struct ItineraryView: View {
    
    @ObservedObject var tripManager: TripManager
    @State var addEvent = false
    let editable: Bool
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .bottom){
                VStack{
                    ItineraryTopNavBar(totalDays: tripManager.trip.totalDays ?? 0,
                                       startDate: tripManager.trip.startDate, endDate: tripManager.trip.endDate, daySelected: $tripManager.selectedDay)
                    .padding(.top, 10)

                    Divider()
                    TabView(selection: $tripManager.selectedDay){
                        ForEach(1..<(tripManager.trip.totalDays ?? 0)+1){day in
                            ItineraryDayView(tripManager: tripManager, day: tripManager.selectedDay, editable: editable)
                                .tag(day)
                                .tabItem { Text("\(day)") }
                                .toolbar(.hidden, for: .tabBar)
                                .simultaneousGesture(DragGesture())

                        }
                    }
                    .animation(.easeOut(duration: 0.2), value: tripManager.selectedDay)
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                if editable{
                    HStack{
                        Spacer()
                        Button{
                            addEvent.toggle()
                        }label: {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 50)
                        }
                        .padding(35)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Itinerary").font(.headline)
                        Text(tripManager.trip.title ?? "").font(.subheadline)
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
        }
        .sheet(isPresented: $addEvent) {
            AddEventView(tripManager: tripManager, addingEvent: $addEvent, previousView: .constant(false))
        }
    }
}

#Preview("Main View") {
    ItineraryView(tripManager: TripManager(trip: itinerary2), editable: false)
}

#Preview("Day view") {
    ItineraryDayView(tripManager: TripManager(trip: itinerary2), day: 1, editable: false )
}
