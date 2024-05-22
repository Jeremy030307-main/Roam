//
//  EventDetailView.swift
//  Roam
//
//  Created by Jeremy Teng  on 02/05/2024.
//

import SwiftUI

struct EventDetailView: View {
    
    @ObservedObject var eventManager: EventManager

    let columns = [
            GridItem(.fixed(30)),
            GridItem(.flexible())
        ]
    
    var body: some View {
        VStack(alignment: .leading){
            switch EventType(rawValue: eventManager.event.type){
            case .activity, .restaurant :
                LocationDetailView(eventManager: eventManager)               
                EventDetailButton()
                EventLocationOverview(eventManager: eventManager)

            case .flight, .tour, .transportation:
                TransportationEventDetailView(eventManager: eventManager)
                    .frame(maxWidth: .infinity)
                EventDetailButton()

            case .accomodation:
                PeriodicDetailView(eventManager: eventManager, startText: "Check In", endText: "Check Out")
                EventDetailButton()
                EventLocationOverview(eventManager: eventManager)
                
            case .carRental:
                PeriodicDetailView(eventManager: eventManager, startText: "Pick Up", endText: "Drop Off")
                EventDetailButton()
                EventLocationOverview(eventManager: eventManager)
                
            case .none:
                Text("")
            }
            Spacer()
        }
    }
}

struct TransportationEventDetailView: View{
    
    @ObservedObject var eventManager: EventManager
    let paddingValue = 40
    @State var wholeTextHeight: CGFloat?
    @State var arrivalTextHeight: CGFloat?

    var body: some View{
        VStack{
            ZStack(alignment: .top){
                
                HStack{
                    VerticalLine()
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .frame(height: (wholeTextHeight ?? 0)-(arrivalTextHeight ?? 0))
                        .padding(.leading, CGFloat(paddingValue))
                        .foregroundStyle(.accent).opacity(0.5)
                    Spacer()
                }
                
                VStack(spacing: 50){
                    HStack(alignment: .top){
                        Circle().foregroundStyle(.accent)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 5){
                            Text("Depart").font(.title2).bold().opacity(0.5)
                            Text(eventManager.getEventDate(period: .start)).font(.title2).bold().opacity(0.5)
                            Text(eventManager.getStartTimeText()).font(.title).bold()
                            HStack{
                                Image(systemName: "mappin").foregroundStyle(.accent)
                                Text(eventManager.event.location.address)
                            }
                        }
                        Spacer()
                    }
                    
                    HStack(alignment: .top){
                        Circle().foregroundStyle(.accent)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 5){
                            Text("Arrival").font(.title2).bold().opacity(0.5)
                            Text(eventManager.getEventDate(period: .end)).font(.title2).bold().opacity(0.5)
                            Text(eventManager.getEndTimeText()).font(.title).bold()
                            HStack{
                                Image(systemName: "mappin").foregroundStyle(.accent)
                                Text(eventManager.event.destination?.address ?? "")
                            }
                        }
                        Spacer()
                    }
                    .background(
                        GeometryReader { geometry in
                            Path { path in
                                let height = geometry.size.height
                                DispatchQueue.main.async {
                                    if self.arrivalTextHeight != height {
                                        self.arrivalTextHeight = height
                                    }
                                }
                            }
                        })
                    
                    
                }
                .padding(.leading, CGFloat(paddingValue-10))
                .background(
                    GeometryReader { geometry in
                        Path { path in
                            let height = geometry.size.height
                            DispatchQueue.main.async {
                                if self.wholeTextHeight != height {
                                    self.wholeTextHeight = height
                                }
                            }
                        }
                    })
            }
        }
        .padding()
    }
}

struct LocationDetailView: View {
    
    @ObservedObject var eventManager: EventManager

    let columns = [
            GridItem(.fixed(30)),
            GridItem(.flexible())
        ]
    
    var body: some View{
        VStack(alignment: .leading){
            
            // Place title section
            HStack(alignment: .top){
                Image(eventManager.event.location.image ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 110, height: 110)
                    .clipped()
                    .cornerRadius(10)
                
                VStack(alignment: .leading){
                    Text(eventManager.event.location.name).font(.title3).bold()
                    Text(eventManager.event.location.address).font(.subheadline).opacity(0.5)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 10)
                .padding(.leading, 5)
            }
        
            // Event date time
            VStack(alignment: .leading){
                if eventManager.event.startDay == eventManager.event.endDay{
                    Text(eventManager.getEventDate(period: .start)).font(.title3).bold()
                }
                else {
                    HStack{
                        Text(eventManager.getEventDate(period: .start).replacingOccurrences(of: ", ", with: "\n")).font(.title3).bold()
                        Spacer()
                        Text(eventManager.getEventDate(period: .end).replacingOccurrences(of: ", ", with: "\n")).font(.title3).bold().multilineTextAlignment(.trailing)
                    }

                }
                HStack(alignment: .center){
                    Text(eventManager.getStartTimeText())                    .foregroundStyle(.accent)

                    VStack{
                        Text(eventManager.getEventDurationText()).font(.footnote)                    .foregroundStyle(.accent)

                        HorizontalLine()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                            .frame(height: 1)
                            .padding(.horizontal)
                        Text("")
                    }
                    Text(eventManager.getEndTimeText())                    .foregroundStyle(.accent)
                }
                .font(.title2)
                .padding()
            }
        }
        .padding()
    }
}

struct PeriodicDetailView: View{
    
    @ObservedObject var eventManager: EventManager
    var startText: String
    var endText: String

    let columns = [
            GridItem(.fixed(30)),
            GridItem(.flexible())
        ]
    
    var body: some View{
        VStack(alignment: .leading){
            
            // Place title section
            HStack(alignment: .top){
                Image(eventManager.event.location.image ?? "")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90, height: 90)
                    .clipped()
                    .cornerRadius(10)
                
                VStack(alignment: .leading){
                    Text(eventManager.event.location.name).font(.headline).bold()
                    Text(eventManager.event.location.address).font(.subheadline).opacity(0.5)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 10)
                .padding(.leading, 5)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            
            VStack(alignment: .leading){
                Text(startText).font(.title3).bold().padding(.top)
                VStack(alignment: .trailing){
                    Text(eventManager.getEventDate(period: .start) + ", " + eventManager.getStartTimeText()).font(.title2).bold().foregroundStyle(.accent)
                }
            }
            .padding(.vertical, 10)
            .padding(.leading, 5)
            
            Divider()

            // Event date time
            HStack(alignment: .center){
                Text(endText).font(.callout)
                Spacer()
                VStack(alignment: .trailing){
                    Text(eventManager.getEventDate(period: .end) + ", " + eventManager.getEndTimeText()).font(.callout)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .padding(.horizontal)
    }
}

struct EventLocationOverview: View {
    
    @ObservedObject var eventManager: EventManager
    
    let columns = [
            GridItem(.fixed(30)),
            GridItem(.flexible())
        ]
    
    var body: some View {
        
        // Event Location Descripion
        VStack(alignment: .leading){
            Text("Overview").font(.title2).bold().padding(.top, 30).padding(.horizontal, 8)
            
            RatingStarView(rating: eventManager.event.location.rating)
                .frame(width: 120)
                .padding(.horizontal, 8)
                .foregroundStyle(.accent)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 25) {
                Image(systemName: "map.fill").foregroundStyle(.accent)
                Text(eventManager.event.location.address)
                Image(systemName: "phone.fill").foregroundStyle(.accent)
                Text(eventManager.event.location.phone)
                Image(systemName: "clock.fill").foregroundStyle(.accent)
                Text(eventManager.event.location.operatingHour)
            }
            .padding()
            .padding(.top, 15)
            .font(.subheadline)
        }
        .padding()
    }
}

struct EventDetailButton: View {
    
    var body: some View{
        
        VStack{
            // Edit and delee button section
            HStack{
                Button("Delete Event"){
                    
                }
                .foregroundStyle(.red)
                
                Spacer()
                Button("Edit"){
                    
                }
            }.padding(.top, 10)
            
            
            Divider()
            
            // Event expense record
            HStack{
                Text("Expense").font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            Divider()
        }
        .padding(.horizontal)
    }
}

#Preview("Place Event Detail View") {
    EventDetailView(eventManager: EventManager(event: event3))
}

#Preview("Periodic Event Detail View"){
    EventDetailView(eventManager: EventManager(event: event2))
}

#Preview("Transportation Event Detail View"){
    EventDetailView(eventManager: EventManager(event: event1))
}
