//
//  EventCardView.swift
//  Roam
//
//  Created by Jeremy Teng  on 01/05/2024.
//

import SwiftUI

struct EventCardView: View {
    
    @ObservedObject var eventManager: EventManager
    @State var showDetail = false
    
    let day: Int
    let eventIndex: Int
    let editable: Bool
    
    init(event: Event, day: Int, eventIndex: Int, editable: Bool) {
        self.eventManager = EventManager(event: event)
        self.day = day
        self.eventIndex = eventIndex
        self.editable = editable
    }
    var body: some View {
        HStack(alignment: .top){
            HStack(spacing: 10){
                Text(eventManager.getStartTimeText()).font(.custom("itinerarySmalltime", fixedSize: 15))
                    .opacity(0.5)
                TripCirceleIcon(image: eventManager.getIcon(), color: .accentColor, dimension: 30)
                    .frame(width: 30)
            }
            Button{
                showDetail.toggle()
            } label: {
                switch EventType(rawValue: eventManager.event.type){
                case .activity, .restaurant :
                    PlaceEventCard(eventManager: eventManager, day: day)
                        .frame(maxWidth: .infinity)
                case .flight, .tour, .transportation:
                    TransportationEventCard(eventManager: eventManager, day: day)
                        .frame(maxWidth: .infinity)
                case .accomodation:
                    PeriodicEventCard(eventManager: eventManager, day: day, startText: "Check In", endText: "Check Out")
                case .carRental:
                    PeriodicEventCard(eventManager: eventManager, day: day, startText: "Pick Up", endText: "Drop Off")

                case .none:
                    Text("fff")
                }
            }.foregroundStyle(.primary)
                .shadow(radius: 2)
            
        }
        .sheet(isPresented: $showDetail){
            EventDetailView(eventManager: eventManager, eventDay: day, eventIndex: eventIndex, editable: editable)
        }
        
    }
}

struct TransportationEventCard: View {
    
    @ObservedObject var eventManager: EventManager
    var day: Int

    let columns = [
        GridItem(.flexible()),
            GridItem(.fixed(100)),
            GridItem(.flexible())
        ]
    
    var body: some View{
        BlankCard(cardColor: .white) {
            
            LazyVGrid(columns: columns, content: {
                VStack(alignment: .center){
                    if eventManager.getEventHeight(atDay: day) > 45{
                        Text(eventManager.getStartTimeText()).font(.system(size: 15)).bold()
                    }
                    Text(eventManager.event.location.name ?? "").font(.system(size: eventManager.getEventHeight(atDay: day) > 45 ? 10:12)).opacity(0.5).padding(.top, 0.2)
                }
                
                ZStack{
                    HStack{
                        Circle().frame(width: 10)
                        Spacer()
                        Circle().frame(width: 10)
                    }
                    
                    HorizontalLine()
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .frame(height: 1)
                    VStack(){
                        Spacer()
                        Text(eventManager.getEventDurationText()).font(.system(size: 10))
                    }
                
                }
                .foregroundStyle(.gray).opacity(0.5)
                
                VStack(alignment: .center){
                    if eventManager.getEventHeight(atDay: day) > 45{
                        Text(eventManager.getEndTimeText()).font(.system(size: 15)).bold()
                    }
                    Text(eventManager.event.destination?.name ?? "").font(.system(size: eventManager.getEventHeight(atDay: day) > 45 ? 10:12)).opacity(0.5).padding(.top, 0.2)
                }
            })
            .frame(height: eventManager.getEventHeight(atDay: day) > 45 ? eventManager.getEventHeight(atDay: day)-20:45-20)
        }
    }
}
    
struct PlaceEventCard: View {
    
    @ObservedObject var eventManager: EventManager
    var day: Int

    
    var body: some View{
        if eventManager.getEventHeight(atDay: day) <= 45 {
            BlankCard(cardColor: Color(.systemBackground)) {
                VStack(alignment: .leading){
                    Text(eventManager.event.location.name ?? "").font(.headline)
                    HStack{
                        Text(eventManager.getEventDurationText()).font(.subheadline).opacity(0.5)
                        Spacer()
                        Text("\(eventManager.getEndTimeText())").font(.subheadline).opacity(0.5)
                    }
                }.frame(height: 45-20)
            }
        }
        else if eventManager.getEventHeight(atDay: day) > 180{
            TopImagaeCard(image: eventManager.event.location.image ?? "", backgroundColor: Color(.systemBackground), height: eventManager.getEventHeight(atDay: day)) {
                VStack(alignment: .leading){
                    Text(eventManager.event.location.name ?? "").font(.headline)
                        .multilineTextAlignment(.leading)
                    
                    Text("\(eventManager.getEventHeight(atDay: day))" + (eventManager.event.location.address ?? "")).lineLimit(1).font(.subheadline).opacity(0.5)
                    
                    Spacer()
                    HStack{
                        Text(eventManager.getEventDurationText()).font(.subheadline).opacity(0.5)
                        Spacer()
                        Text("\(eventManager.getEndTimeText())").font(.subheadline).opacity(0.5)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.trailing, 10)
                .padding(.vertical, 5)
            }
        }else {
            SideImageCard(image: eventManager.event.location.image ?? "", backgroundColor: Color(.systemBackground), textHeight: eventManager.getEventHeight(atDay: day)) {
                VStack(alignment: .leading){
                    Text(eventManager.event.location.name ?? "").font(.headline)
                        .multilineTextAlignment(.leading)
                    Text(eventManager.event.location.address ?? "").lineLimit(1).font(.subheadline).opacity(0.5)
                    
                    Spacer()
                    
                    HStack{
                        Text(eventManager.getEventDurationText()).font(.subheadline).opacity(0.5)
                        Spacer()
                        Text("\(eventManager.getEndTimeText())").font(.subheadline).opacity(0.5)
                    }
                }
                .frame(height: eventManager.getEventHeight(atDay: day))
                .frame(maxWidth: .infinity)
                .padding(.trailing, 10)
            }
        }
    }
}

struct PeriodicEventCard: View {
    
    @ObservedObject var eventManager: EventManager
    var day: Int
    var startText: String
    var endText: String

    var body: some View{
        HStack{
            VStack(alignment: .leading){
                if eventManager.event.startDay == eventManager.event.endDay{
                    
                } else {
                    
                }
                Text((day == eventManager.event.startDay ? startText: endText) + " at " + (eventManager.event.location.name ?? "")).lineLimit(1).font(.headline)
            }

            Spacer()
            
            Image(systemName: "chevron.forward").padding(.trailing, 10)
        }
        .frame(height: 45).cornerRadius(5)
        .background(.quaternary)
    }
}

#Preview("Place Event") {
    EventCardView(event: event3, day: 1, eventIndex: 0, editable: false)
}

#Preview("Transportation Event") {
    EventCardView(event: event1, day: 1, eventIndex: 0, editable: false)
}

#Preview("Periodic Event"){
    EventCardView(event: event2, day: 1, eventIndex: 0, editable: false)
}
