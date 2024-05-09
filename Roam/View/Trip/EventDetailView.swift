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
        switch EventType(rawValue: eventManager.event.type){
        case .accomodation, .activity, .restaurant :
            LocationDetailView(eventManager: eventManager)
        case .flight, .tour, .transportation:
            TransportationEventDetailView(eventManager: eventManager)
                .frame(maxWidth: .infinity)
        case .none:
            Text("")
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
                            Text(eventManager.getEventDate()).font(.title2).bold().opacity(0.5)
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
                            Text(eventManager.getEventDate()).font(.title2).bold().opacity(0.5)
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
            
            Divider()
            
            // Edit and delee button section
            HStack{
                Button("Delete Event"){
                    
                }
                .foregroundStyle(.red)
                
                Spacer()
                Button("Edit"){
                    
                }
            }.padding(10)
            
            Divider()
            
            // Event expense record
            HStack{
                Text("Expense").font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            Divider()
            Spacer()
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

            // Event date time
            HStack{
                Text(eventManager.getEventDate())
                Spacer()
                Text(eventManager.getStartTimeText() + " to " + eventManager.getEndTimeText())
            }
            .font(.callout).opacity(0.7)
            .padding()
            
            Divider()
            
            // Event expense record
            HStack{
                Text("Expense").font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            Divider()
            
            // Event Location Descripion
            Text("Overview").font(.title2).bold().padding(.top, 30).padding(.horizontal, 8)
            
            HStack{
                ForEach(eventManager.getLocationStar(), id: \.self){star in
                    Image(systemName: star).foregroundStyle(.accent)
                }
            }.padding(.horizontal, 8).padding(.vertical, 8)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 25) {
                Image(systemName: "exclamationmark.circle.fill").foregroundStyle(.accent)
                Text(eventManager.event.location.descrition)
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
            

            Spacer()
        }
        .padding()
    }
}

#Preview {
    EventDetailView(eventManager: EventManager(event: event2))
}
