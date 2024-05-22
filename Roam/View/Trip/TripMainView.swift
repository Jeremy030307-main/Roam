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
    
    let columns = [
        GridItem(.adaptive(minimum: 150)),
        GridItem(.adaptive(minimum: 150))]
    
    init(trip: Trip) {
        self.tripManager = TripManager(trip: trip)
    }
    
    var body: some View {
        
        NavigationStack{

            VStack(alignment: .leading){
                
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
                        Text(tripManager.trip.title).font(.title).padding(.horizontal).bold()
                        Text(tripManager.trip.destination).font(.title3).padding(.horizontal).bold().foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                
                
                VStack(alignment: .leading) {
                    NavigationLink{
                        ItineraryView(tripManager: tripManager)
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
                                    Text("\(tripManager.trip.totalDays)d")
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
                        NavigationLink{
                            ExpenseView(tripManager: tripManager)
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
                        
                        NavigationLink{
                            ChecklistView(tripManager: tripManager)
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
                
                HStack{
                    Text("Saved Places").font(.title3).bold()
                    
                    Spacer()
                    Button{
                        addList.toggle()
                    } label: {
                        Text("Add New List").font(.subheadline).bold()
                            .foregroundStyle(.accent)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                BlankCard(cardColor: .white) {
                    List{
                        ForEach(tripManager.trip.savedPlaces, id: \.self){ savedPlace in
                            NavigationLink {
                                Text(savedPlace.title)
                            } label: {
                                HStack{
                                    TripCirceleIcon(image: Image(systemName: savedPlace.icon), color: SavedPlaceColor(rawValue: savedPlace.color)?.copy ?? .red, dimension: 30)
                                        .frame(width: 30)
                                    
                                    Text(savedPlace.title).font(.subheadline).padding(.horizontal)
                                }
                            }
                        }
                        .onDelete(perform: tripManager.deleteList)
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
    TripMainView(trip: itinerary6)
}
