//
//  TripMainView.swift
//  Roam
//
//  Created by Jeremy Teng  on 28/04/2024.
//

import SwiftUI

struct TripMainView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var tripManager: TripManager
    @State var addList = false
    let editable: Bool
    
    let columns = [
        GridItem(.adaptive(minimum: 150)),
        GridItem(.adaptive(minimum: 150))]
    
    init(trip: Trip, editable: Bool) {
        self.tripManager = TripManager(trip: trip)
        self.editable = editable
    }
    
    var body: some View {
        
        NavigationStack{
            Text("\(tripManager.trip.events.count)")
            VStack(alignment: .leading){
                
                // Header of trip main view
                HStack(alignment: .top){
                    Button{
                        dismiss()
                    }label: {
                        HStack{
                            Image(systemName: "chevron.backward")
                        }
                    }.foregroundStyle(.accent)
                        .padding(.bottom, 10)
                    
                    VStack(alignment: .leading){
                        Text(tripManager.trip.title ?? "").font(.title).padding(.horizontal).bold()
                        Text(tripManager.trip.destination ?? "").font(.title3).padding(.horizontal).bold().foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                
                
                VStack(alignment: .leading) {
                    
                    // block tat link to itinerary
                    NavigationLink{
                        ItineraryView(tripManager: tripManager, editable: editable)
                    } label: {
                        BlankCard(cardColor: Color(.white)) {
                            
                            HStack(alignment: .top){
                                
                                VStack(alignment: .leading) {
                                    TripCirceleIcon(image: Image(systemName: "calendar.circle.fill"), color: Color.orange, dimension: 30)
                                        .frame(width: 30)
                                    
                                    Text("Itinerary").font(.title2).bold()
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                
                                if tripManager.trip.startDate == nil {
                                    Text("\(tripManager.trip.totalDays ?? 0)d")
                                        .font(.title2).bold()
                                        .padding()
                                }
                                else{
                                    Text(tripManager.trip.startDate!.formatted(.dateTime.day().month()) + " - " + tripManager.trip.endDate!.formatted(.dateTime.day().month())).font(.title2).bold()
                                        .padding()
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                
                    LazyVGrid(columns: columns){
                        
                        // block that link to expense of a trip
                        NavigationLink{
                            ExpenseView(tripManager: tripManager, editable: editable)
                        } label: {
                            
                            BlankCard(cardColor: Color(.white)) {
                                
                                HStack(alignment: .top){
                                    
                                    VStack(alignment: .leading) {
                                        TripCirceleIcon(image: Image(systemName: "dollarsign.circle.fill"), color: Color.green, dimension: 30)
                                            .frame(width: 30)
                                        
                                        Text("Expnese").font(.title2).bold()
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(5)
                        }.foregroundStyle(.primary)
                        
                        // block that link to checklist of a trip
                        NavigationLink{
                            ChecklistView(tripManager: tripManager, editable: editable)
                        } label: {
                            BlankCard(cardColor: Color(.white)) {
                                
                                HStack(alignment: .top){
                                    
                                    VStack(alignment: .leading) {
                                        TripCirceleIcon(image: Image(systemName: "checkmark.circle.fill"), color: Color.blue, dimension: 30)
                                            .frame(width: 30)
                                        
                                        Text("Checklist").font(.title2).bold()
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(5)
                        }.foregroundStyle(.primary)
                        
                    }
                    .padding(.vertical, 5)
                }
                
                // block that show the list of saved places created by user
                HStack{
                    Text("Saved Places").font(.title3).bold()
                    Spacer()
                    if editable{
                        Button{
                            addList.toggle()
                        } label: {
                            Text("Add New List").font(.subheadline).bold()
                                .foregroundStyle(.accent)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                BlankCard(cardColor: .white) {
                    List{
                        ForEach(Array(tripManager.trip.savedPlaces.enumerated()), id: \.1.id) { index, savedPlace in
                            NavigationLink {
                                SavedPlacesView(tripManager: tripManager, savedplaceCaegoryIndex: index, editable: editable)
                            } label: {
                                HStack{
                                    TripCirceleIcon(image: Image(systemName: savedPlace.icon), color: SavedPlaceColor(rawValue: savedPlace.color)?.copy ?? .red, dimension: 30)
                                        .frame(width: 30)
                                    
                                    Text(savedPlace.title).font(.subheadline).padding(.horizontal)
                                }
                            }
                        }
                        .onDelete(perform: tripManager.deleteList)
                        .deleteDisabled(!editable)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)

                }
 
                Spacer()
                    
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .toolbar(.hidden)
            .sheet(isPresented: $addList) {
                AddNewListView(tripManager: tripManager)
            }
        }
    }
}

#Preview {
    TripMainView(trip: itinerary6, editable: false)
}
