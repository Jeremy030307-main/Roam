//
//  ItineraryPage.swift
//  Roam
//
//  Created by Jeremy Teng  on 27/04/2024.
//

import SwiftUI

struct TripPage: View {
    
    var user = user10
    
    var body: some View {
        
        HStack{
            Text("Itinerary").font(.title).bold()
            Spacer()
        }
        .padding(.horizontal)
                    
        ScrollView{
            VStack(alignment: .leading){
                Text("Upcoming Trip").font(.title3).bold()
                    .padding(.horizontal)
                
                Text("Past Trip").font(.title3).bold()
                    .padding(.horizontal)
                
                ForEach(user10.itinerary){ itinerary in
                    ImageCard(image: Image(itinerary.image), backgroundColor: Color(.secondarySystemFill)) {
                        VStack(alignment: .leading) {
                            Text(itinerary.title).font(.headline)
                            Text(itinerary.destination).font(.subheadline)
                            
                            HStack {
                                Spacer()
                                if itinerary.startDate == nil {
                                    Text("\(itinerary.totalDays)d").font(.footnote)
                                }
                                else{
                                    Text(itinerary.startDate!.formatted(.dateTime.day().month()) + " - " + itinerary.endDate!.formatted(.dateTime.day().month())).font(.footnote)
                                }
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .cornerRadius(20)
                    .padding(3)
                }
            }
        }
        .padding()
        
    }
}

#Preview {
    TripPage()
}
