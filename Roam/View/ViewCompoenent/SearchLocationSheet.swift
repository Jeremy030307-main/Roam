//
//  SearchLocationSheet.swift
//  Roam
//
//  Created by Jeremy Teng  on 27/05/2024.
//

import SwiftUI

struct SearchLocationSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var yelpFetcher = YelpFetcher()
    @ObservedObject var tripManager: TripManager
    @FocusState var isFocus: Bool
    @Binding var location: LocationData?
    @State var requestIndex = 1

    var prompt: String
    
    var body: some View{
        
        Form{
            Section("Location"){
                TextField(prompt, text: $yelpFetcher.searchText)
                    .focused($isFocus)
                    .onSubmit {
                        Task{
                            await yelpFetcher.fetchBeuisinessByName(location: tripManager.trip.destination ?? "")
                        }
                    }
            }

            Section{
                ForEach(yelpFetcher.locations, id: \.self) { location in
                    Button {
                        self.location = location
                        yelpFetcher.searchText = ""
                        dismiss()
                    } label: {
                        VStack(alignment: .leading){
                            Text(location.name ?? "").font(.headline)
                            Text(location.address ?? "").font(.subheadline)
                        }
                    }
                }
            }header: {
               Text("Result")
            } footer: {
                if yelpFetcher.isLoading{
                    HStack{
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding()
                }
            }
        }
        .onAppear{
            isFocus = true
        }
        .onChange(of: yelpFetcher.locations.count, { oldValue, newValue in
            print("dfddfdfdsf")
            Task{
                if yelpFetcher.locations.count == requestIndex * yelpFetcher.QUERY_LIMIT &&
                    requestIndex * yelpFetcher.QUERY_LIMIT <= 1000{
                    await yelpFetcher.fetchBeuisinessByName(location: tripManager.trip.destination ?? "", requestIndex: requestIndex)
                    requestIndex += 1
                }
            }
        })
    }
}
