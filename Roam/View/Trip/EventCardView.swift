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
    
    init(event: Event) {
        self.eventManager = EventManager(event: event)
    }
    var body: some View {
        HStack(alignment: .top){
            HStack(spacing: 10){
                Text(eventManager.getStartTimeText()).font(.custom("itinerarySmalltime", fixedSize: 15))
                    .opacity(0.5)
                TripCirceleIcon(image: eventManager.getIcon(), color: .accentColor)
                    .frame(width: 30)
            }
            
            Button{
                showDetail.toggle()
            } label: {
                switch EventType(rawValue: eventManager.event.type){
                case .accomodation, .activity, .restaurant :
                    PlaceEventCard(eventManager: eventManager)
                        .frame(maxWidth: .infinity)
                case .flight, .tour, .transportation:
                    TransportationEventCard(eventManager: eventManager)
                        .frame(maxWidth: .infinity)
                case .none:
                    Text("")
                }
            }.foregroundStyle(.primary)
            
        }
        .sheet(isPresented: $showDetail){
            EventDetailView(eventManager: eventManager)
        }
        
    }
}

struct HorizontalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

struct TransportationEventCard: View {
    
    @ObservedObject var eventManager: EventManager

    let columns = [
        GridItem(.flexible()),
            GridItem(.fixed(100)),
            GridItem(.flexible())
        ]
    
    init(eventManager: EventManager) {
        self.eventManager = eventManager
    }
    
    var body: some View{
        BlankCard(cardColor: .white) {
            LazyVGrid(columns: columns, content: {
                VStack(alignment: .center){
                    Text(eventManager.getStartTimeText()).font(.system(size: 15)).bold()
                    Text(eventManager.event.location.name).font(.system(size: 10)).opacity(0.5).padding(.top, 0.2)
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
                        Text(eventManager.getEventDurationText()).font(.custom("duration", fixedSize: 10))
                    }
                
                }
                .foregroundStyle(.gray).opacity(0.5)
                
                VStack(alignment: .center){
                    Text(eventManager.getEndTimeText()).font(.system(size: 15)).bold()
                    Text(eventManager.event.destination?.name ?? "").font(.system(size: 10)).opacity(0.5).padding(.top, 0.2)
                }
            })
            .frame(height: eventManager.getEventHeight())
        }
    }
}
    
struct PlaceEventCard: View {
    
    @ObservedObject var eventManager: EventManager
    
    var body: some View{
        if eventManager.getEventHeight() <= 50 {
            BlankCard(cardColor: Color.primary) {
                Text("gsdffdg")
            }
        }
        else if eventManager.getEventHeight() > 180{
            TopImagaeCard(image: Image(eventManager.event.location.image ?? ""), backgroundColor: Color(.secondarySystemFill)) {
                VStack(alignment: .leading){
                    Text(eventManager.event.location.name).font(.headline)
                        .multilineTextAlignment(.leading)
                    
                    Text(eventManager.event.location.address).lineLimit(1).font(.subheadline).opacity(0.5)
                    
                    Spacer()
                    
                    Text(eventManager.getEventDurationText()).font(.subheadline).opacity(0.5)
                }
                .frame(height: eventManager.getEventHeight()/2)
                .frame(maxWidth: .infinity)
                .padding(.trailing, 10)
                .padding(.vertical, 5)
            }
        }else {
            SideImageCard(image: Image(eventManager.event.location.image ?? ""), backgroundColor: Color(.secondarySystemFill)) {
                VStack(alignment: .leading){
                    Text(eventManager.event.location.name).font(.headline)
                        .multilineTextAlignment(.leading)
                    
                    Text(eventManager.event.location.address).lineLimit(1).font(.subheadline).opacity(0.5)
                    
                    Spacer()
                    
                    Text(eventManager.getEventDurationText()).font(.subheadline).opacity(0.5)
                }
                .frame(height: eventManager.getEventHeight())
                .frame(maxWidth: .infinity)
                .padding(.trailing, 10)
                .padding(.vertical, 5)
            }
        }
    }
}

#Preview {
    EventCardView(event: event2)
        .previewLayout(.sizeThatFits)
}
