//
//  ChecklistView.swift
//  Roam
//
//  Created by Jeremy Teng  on 16/05/2024.
//

import SwiftUI

struct ChecklistView: View {
    
    @ObservedObject var tripManager: TripManager
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(tripManager.trip.checklist){ item in
                    HStack{
                        Button{
                            if !item.completed{
                                tripManager.check(checkList: item)
                            }
                            else {
                                tripManager.uncheck(checkList: item)
                            }
                        } label: {
                            Image(systemName: item.completed ? "circle.fill":"circle")
                        }
                        Text(item.title).opacity(item.completed ? 0.5:1)
                        Spacer()
                    }
                }
                HStack{
                    Image(systemName: "circle.dashed").opacity(0.5)
                    TextField("", text: $tripManager.newCheckListContent)
                        .onSubmit {
                            tripManager.addNewChecklistItem()
                        }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Checklist").font(.headline)
                        Text(tripManager.trip.title).font(.subheadline)
                    }
                }
            }
        }
    }
}


#Preview {
    ChecklistView(tripManager: TripManager(trip: itinerary2))
}
