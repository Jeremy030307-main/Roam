//
//  AddNewListView.swift
//  Roam
//
//  Created by Jeremy Teng  on 29/04/2024.
//

import SwiftUI

struct AddNewListView: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var tripManager: TripManager
    
    let rows = [
        GridItem(.adaptive(minimum: 40))]
    
    var body: some View {
        VStack(spacing: 15){
            HStack{
                Button("Cancel"){
                    dismiss()
                }
                .foregroundStyle(.accent)
                Spacer()
                
                Button("Done"){
                    tripManager.addNewList()
                    dismiss()
                }
                .disabled(tripManager.newListTitle.isEmpty)
                .foregroundStyle(tripManager.newListTitle.isEmpty ? .gray.opacity(0.8):.accent)

            }
                
            BlankCard(cardColor: .white) {
                HStack{
                    Spacer()
                    TripCirceleIcon(image: Image(systemName: tripManager.newListIcon.rawValue),
                                    color: tripManager.newListColor.copy, dimension: 100)
                    .frame(width: 100)
                    .padding()
                    Spacer()
                }
                TextField("List Name", text: $tripManager.newListTitle)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Color(.secondarySystemFill))
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .fontDesign(.rounded)
                    .cornerRadius(10)
                
                
            }
            
            BlankCard(cardColor: .white) {
                HStack{
                    LazyVGrid(columns: self.rows){
                        ForEach(SavedPlaceColor.allCases) { color in
            
                            Button{
                                tripManager.newListColor = color
                            } label: {
                                ZStack{
                                    Circle().stroke(
                                        tripManager.newListColor == color ? Color(.gray).opacity(0.5): Color.clear,
                                        lineWidth: 3)
                                    .frame(width: 45)
                                    Circle().fill(color.copy)
                                        .frame(width: 35)
                                }
                            }
                        }
                    }
                }
            }
            
            BlankCard(cardColor: .white) {
                HStack{
                    LazyVGrid(columns: self.rows){
                        ForEach(SavePlaceIcon.allCases) { icon in
            
                            Button{
                                tripManager.newListIcon = icon
                            } label: {
                                ZStack{
                                    Circle().stroke(
                                        tripManager.newListIcon == icon ? Color(.gray).opacity(0.5): Color.clear,
                                        lineWidth: 3)
                                    .frame(width: 45)

                                    TripCirceleIcon(image: Image(systemName: icon.rawValue), color: Color(.gray), dimension: 35)
                                        .frame(width: 35)
                                }
                            }
                        }
                    }
                }
            }

            
            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemFill))

            
        
    }
}

#Preview {
    AddNewListView(tripManager: TripManager(trip: itinerary1))
}
