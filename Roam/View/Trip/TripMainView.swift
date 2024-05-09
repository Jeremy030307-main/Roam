//
//  TripMainView.swift
//  Roam
//
//  Created by Jeremy Teng  on 28/04/2024.
//

import SwiftUI

struct TripMainView: View {
    
    @ObservedObject var tripManager: TripManager
    @State var listHeight: CGFloat?
    
    init(trip: Trip) {
        self.tripManager = TripManager(trip: trip)
    }
    
    var body: some View {
        
        NavigationStack{
            VStack(alignment: .leading){
                
                VStack(alignment: .leading) {
                    BlankCard(cardColor: Color(.white)) {
                        
                        HStack(alignment: .top){
                            
                            VStack(alignment: .leading) {
                                TripCirceleIcon(image: Image(systemName: "calendar"), color: Color.orange)
                                    .frame(width: 30)
                                
                                Text("Itinerary").font(.title2).bold()
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 10)
                            }
                            Spacer()
                            
                            if tripManager.trip.startDate == nil {
                                Text("\(tripManager.trip.totalDays)d").font(.callout)
                                    .padding()
                            }
                            else{
                                Text(tripManager.trip.startDate!.formatted(.dateTime.day().month()) + " - " + tripManager.trip.endDate!.formatted(.dateTime.day().month())).font(.title2).bold()
                                    .padding()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    HStack{
                        BlankCard(cardColor: Color(.white)) {
                            
                            HStack(alignment: .top){
                                
                                VStack(alignment: .leading) {
                                    TripCirceleIcon(image: Image(systemName: "dollarsign"), color: Color.green)
                                        .frame(width: 30)
                                    
                                    Text("Expnese").font(.title2).bold()
                                        .foregroundStyle(.secondary)
                                        .padding(.top, 10)
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(5)
                        
                        BlankCard(cardColor: Color(.white)) {
                            
                            HStack(alignment: .top){
                                
                                VStack(alignment: .leading) {
                                    TripCirceleIcon(image: Image(systemName: "checklist"), color: Color.blue)
                                        .frame(width: 30)
                                    
                                    Text("Checklist").font(.title2).bold()
                                        .foregroundStyle(.secondary)
                                        .padding(.top, 10)
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(5)
                    }
                    .padding(.vertical, 5)
                }
                .padding(.horizontal)
                
                List{
                    Section{
                        ForEach(tripManager.trip.savedPlaces, id: \.self){ savedPlace in
                            NavigationLink {
                                Text(savedPlace.title)
                            } label: {
                                HStack{
                                    TripCirceleIcon(image: Image(systemName: savedPlace.icon), color: SavedPlaceColor(rawValue: savedPlace.color)?.copy ?? .red)
                                        .frame(width: 30)
                                    
                                    Text(savedPlace.title).font(.subheadline).padding(.horizontal)
                                }
                            }
                        }
                        .onDelete(perform: tripManager.deleteList)
                    } header: {
                        HStack {
                            Text("Saved Places")
                                .font(.headline).bold().foregroundStyle(.black)
                            Spacer()
                            Button(action: tripManager.addNewList) {
                                Text("Add New List").font(.footnote).bold()
                                    .foregroundStyle(.roam)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .cornerRadius(20)
                .scrollContentBackground(.hidden)
                
                Spacer()
            }
            .background(Color(.secondarySystemFill))
            .navigationTitle(tripManager.trip.title)
        }
    }
}

#Preview {
    TripMainView(trip: itinerary1)
}
