//
//  ItineraryDayView.swift
//  Roam
//
//  Created by Jeremy Teng  on 30/04/2024.
//

import SwiftUI

struct ItineraryDayView: View {
    
    @ObservedObject var tripManager: TripManager
    @State var screenWidth: CGFloat?
    let day: Int
    
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
                    
                    VStack(alignment: .leading){
                        ForEach(tripManager.trip.days[day] ?? []){ event in
                            let x = tripManager.getDistanceTwoEvent(itineraryDay: tripManager.trip.days[day] ?? [], event: event)
                            VStack{
                                
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: CGFloat(x))
                            EventCardView(event: event)
                                .padding(.horizontal)
                                .padding(.vertical, 5)
                                .id(event)
                        }
                        Spacer()
                    }
                }
                .frame(minHeight: 2400)
            
            }
            .onAppear{
                scrollProxy.scrollTo(tripManager.trip.days[day]?.first ?? [].first, anchor: .top)
            
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

struct VerticalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}

struct ItineraryDayView_Preview: PreviewProvider {
    
    static var tripManager  = TripManager(trip: itinerary2)
    
    static var previews: some View {
        ItineraryDayView(tripManager: tripManager, day: 1)
    }
}
