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
                
                HStack{
                    Button{
                        dismiss()
                    }label: {
                        HStack{
                            Image(systemName: "chevron.backward")
                        }
                    }.foregroundStyle(.accent)
                        .padding(.bottom, 10)
                    Spacer()
                }
                
                Text(tripManager.trip.title).font(.title).padding(.horizontal).bold()
                
                VStack(alignment: .leading) {
                    NavigationLink{
                        ItineraryView(tripManager: tripManager)
                    } label: {
                        BlankCard(cardColor: Color(.white)) {
                            
                            HStack(alignment: .top){
                                
                                VStack(alignment: .leading) {
                                    TripCirceleIcon(image: Image(systemName: "calendar"), color: Color.orange)
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
                                        TripCirceleIcon(image: Image(systemName: "dollarsign"), color: Color.green)
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
                        
                        BlankCard(cardColor: Color(.white)) {
                            
                            HStack(alignment: .top){
                                
                                VStack(alignment: .leading) {
                                    TripCirceleIcon(image: Image(systemName: "checklist"), color: Color.blue)
                                        .frame(width: 30)
                                    
                                    Text("Checklist").font(.title2).bold()
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(5)
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
                                    TripCirceleIcon(image: Image(systemName: savedPlace.icon), color: SavedPlaceColor(rawValue: savedPlace.color)?.copy ?? .red)
                                        .frame(width: 30)
                                    
                                    Text(savedPlace.title).font(.subheadline).padding(.horizontal)
                                }
                            }
                        }
                        .onDelete(perform: tripManager.deleteList)
                        .onMove(perform: tripManager.moveList)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)

                }
 
                Spacer()
                    
            }
            .padding()
            .background(Color(.secondarySystemFill))
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
