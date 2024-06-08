//
//  AddNewTripView.swift
//  Roam
//
//  Created by Jeremy Teng  on 10/05/2024.
//

import SwiftUI

enum TripLengthType {
    case day
    case date
}

struct AddNewTripView: View {
    
    @EnvironmentObject var userManager: UserManager
    @Environment(\.dismiss) var dismiss
    @ObservedObject var locationService: CitySearchViewModal = CitySearchViewModal()
    
    @State var title = ""
    
    @State var enterDestination = false
    @State var destination = ""
    @Namespace var destinationSearchAnimation
    
    @State var lengthTypeSelection: TripLengthType = .date
    @State var startDate = Date()
    @State var endDate = Date()
    @State var tripLength = 1
    
    @State var addPax = false
    @State var pax: Int = 1
    @FocusState var isFocused: Bool
    
    var inValidTrip : Bool {
        if title.trimmingCharacters(in: .whitespaces).isEmpty{
            return true
        }
        if destination.trimmingCharacters(in: .whitespaces).isEmpty{
            return true
        }
        if invalidPeriod {
            return true
        }
        return false
    }
    
    var invalidPeriod : Bool {
        if Calendar.current.isDate(endDate, inSameDayAs: startDate){
            return false
        } else {
            return endDate < startDate
        }
    }
    
    var body: some View {
        
        NavigationStack{
            Form{
                if enterDestination == false{
                    Section{
                        TextField("Trip Name", text: $title)
                    }header: {
                        Text("Trip Name").foregroundStyle(.accent)
                    }
                    
                    Section{
                        TextField("e.g., Paris, Melbourne", text: $destination)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    enterDestination.toggle()
                                }
                            }
                            .matchedGeometryEffect(id: "destinationSearch", in: destinationSearchAnimation)
                    } header: {
                        Text("Destination").foregroundStyle(.accent)
                    }
                    
                    Section{
                        switch lengthTypeSelection {
                        case .day:
                            Stepper(
                                value: $tripLength,
                                in: 1...1000,
                                step: 1
                            ) {
                                Text("\(tripLength) ") + Text(tripLength > 1 ? "days": "day")
                            }
                        case .date:
                            DatePicker(
                                "Start Date",
                                selection: $startDate,
                                displayedComponents: [.date]
                            )
                            DatePicker(
                                "End Date",
                                selection: $endDate,
                                displayedComponents: [.date]
                            )
                        }
                    } header: {
                    } footer: {
                        if lengthTypeSelection == .date{
                            if !invalidPeriod{
                                HStack{
                                    Spacer()
                                    Text("\(tripLength) ").bold() + Text(tripLength>1 ? "days":"day").bold()
                                }
                                .padding(.trailing)
                            } else {
                                Text("End date should be after start date. ")
                            }
                        }
                    }
                    .onChange(of: lengthTypeSelection) { oldValue, newValue in
                        tripLength = 1
                        endDate = Date()
                        startDate = Date()
                    }
                    .onChange(of: startDate) { oldValue, newValue in
                        tripLength = calculateDateDifferent()
                    }
                    .onChange(of: endDate) { oldValue, newValue in
                        tripLength = calculateDateDifferent()
                    }
                    
                    Section{
                        switch addPax {
                        case true:
                            Toggle(isOn: $addPax, label: {
                                Text("Add Number of Pax")
                            })
                            
                            Stepper(
                                value: $pax,
                                in: 1...1000,
                                step: 1
                            ) {
                                Text("\(pax) ") + Text(pax > 1 ? "peoples": "people")
                            }
                        case false:
                            Toggle(isOn: $addPax, label: {
                                Text("Add Number of Pax")
                            })
                        }
                        
                    } header: {
                        VStack(alignment: .leading){
                            Text("Pax").foregroundStyle(.accent)
                        }
                    }
                } else {
                    Section(header: Text("Location Search")) {
                        ZStack(alignment: .trailing) {
                            TextField("Search", text: $locationService.queryFragment)
                                .focused($isFocused)
                            // This is optional and simply displays an icon during an active search
                            if locationService.status == .isSearching {
                                Image(systemName: "clock")
                                    .foregroundColor(Color.gray)
                            }
                        }
                        .matchedGeometryEffect(id: "destinationSearch", in: destinationSearchAnimation)
                        .onAppear {
                            isFocused = true
                        }
                    }
                    Section(header: Text("Results")) {
                        List {
                            ForEach(locationService.returnText(), id:\.self) { completionResult in
                                Button(completionResult){
                                    destination = completionResult
                                    enterDestination.toggle()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Trip").navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    if enterDestination == false {
                        Button("Save"){
                            Task{
                                await userManager.addNewTrip(
                                    title: self.title,
                                    destination: self.destination,
                                    totalDays: self.tripLength,
                                    startDate: lengthTypeSelection == .date ? self.startDate: nil, endDate: lengthTypeSelection == .date ? self.endDate: nil,
                                    pax: addPax == true ? self.pax: nil)
                            }
                            dismiss()
                        }.disabled(inValidTrip)
                    } else {
                        Button("Cancel"){
                            withAnimation(.easeInOut) {
                                enterDestination.toggle()

                            }
                        }
                    }
                }
            }
        }
        
        
    }

    func calculateDateDifferent() -> Int{
        let diffs = Calendar.current.dateComponents([.day], from: startDate, to: endDate)
        if diffs.day ?? 0 == 0{
            if startDate < endDate{
                return 2
            }
            return 1
        }else{
            return (diffs.day ?? 0) + 2
        }
    }
}

#Preview {
    AddNewTripView()
        .environmentObject(UserManager(user: FirebaseController.shared.user))

}
