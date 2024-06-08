//
//  EventDetailView.swift
//  Roam
//
//  Created by Jeremy Teng  on 02/05/2024.
//

import SwiftUI

struct EventDetailView: View {
    
    @ObservedObject var eventManager: EventManager
    @State var isEditting = false
    let eventDay: Int
    let eventIndex: Int

    @Namespace var editAnimation
    
    let columns = [
            GridItem(.fixed(30)),
            GridItem(.flexible())
        ]
    let editable: Bool
    
    var body: some View {
        VStack(alignment: .leading){
            if !isEditting{
                switch EventType(rawValue: eventManager.event.type){
                case .activity, .restaurant :
                    LocationDetailView(eventManager: eventManager)
                    EventDetailButton(eventManager: eventManager, isEditting: $isEditting, eventDay: eventDay, eventIndex: eventIndex, editable: editable)
                    EventLocationOverview(eventManager: eventManager)
                    
                case .flight, .tour, .transportation:
                    TransportationEventDetailView(eventManager: eventManager)
                        .frame(maxWidth: .infinity)
                    EventDetailButton(eventManager: eventManager, isEditting: $isEditting, eventDay: eventDay,  eventIndex: eventIndex, editable: editable)
                    
                case .accomodation:
                    PeriodicDetailView(eventManager: eventManager, startText: "Check In", endText: "Check Out")
                    EventDetailButton(eventManager: eventManager, isEditting: $isEditting, eventDay: eventDay,  eventIndex: eventIndex, editable: editable)
                    EventLocationOverview(eventManager: eventManager)
                    
                case .carRental:
                    PeriodicDetailView(eventManager: eventManager, startText: "Pick Up", endText: "Drop Off")
                    EventDetailButton(eventManager: eventManager, isEditting: $isEditting, eventDay: eventDay, eventIndex: eventIndex, editable: editable)
                    EventLocationOverview(eventManager: eventManager)
                    
                case .none:
                    Text("")
                }
            } else {
                EventEditView(eventManager: eventManager, editAnimation: editAnimation)
                EventDetailButton(eventManager: eventManager, isEditting: $isEditting, eventDay: eventDay, eventIndex: eventIndex, editable: editable)
            }
            Spacer()
        }
    }
}

struct TransportationEventDetailView: View{
    
    @ObservedObject var eventManager: EventManager
    let paddingValue = 40
    @State var wholeTextHeight: CGFloat?
    @State var arrivalTextHeight: CGFloat?

    var body: some View{
        VStack{
            ZStack(alignment: .top){
                
                HStack{
                    VerticalLine()
                        .stroke(style: StrokeStyle(lineWidth: 2))
                        .frame(height: (wholeTextHeight ?? 0)-(arrivalTextHeight ?? 0))
                        .padding(.leading, CGFloat(paddingValue))
                        .foregroundStyle(.accent).opacity(0.5)
                    Spacer()
                }
                
                VStack(spacing: 50){
                    HStack(alignment: .top){
                        Circle().foregroundStyle(.accent)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 5){
                            Text("Depart").font(.title2).bold().opacity(0.5)
                            Text(eventManager.getEventDate(period: .start)).font(.title2).bold().opacity(0.5)
                            Text(eventManager.getStartTimeText()).font(.title).bold()
                            HStack{
                                Image(systemName: "mappin").foregroundStyle(.accent)
                                Text(eventManager.event.location.address ?? "")
                            }
                        }
                        Spacer()
                    }
                    
                    HStack(alignment: .top){
                        Circle().foregroundStyle(.accent)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: 5){
                            Text("Arrival").font(.title2).bold().opacity(0.5)
                            Text(eventManager.getEventDate(period: .end)).font(.title2).bold().opacity(0.5)
                            Text(eventManager.getEndTimeText()).font(.title).bold()
                            HStack{
                                Image(systemName: "mappin").foregroundStyle(.accent)
                                Text(eventManager.event.destination?.address ?? "")
                            }
                        }
                        Spacer()
                    }
                    .background(
                        GeometryReader { geometry in
                            Path { path in
                                let height = geometry.size.height
                                DispatchQueue.main.async {
                                    if self.arrivalTextHeight != height {
                                        self.arrivalTextHeight = height
                                    }
                                }
                            }
                        })
                    
                    
                }
                .padding(.leading, CGFloat(paddingValue-10))
                .background(
                    GeometryReader { geometry in
                        Path { path in
                            let height = geometry.size.height
                            DispatchQueue.main.async {
                                if self.wholeTextHeight != height {
                                    self.wholeTextHeight = height
                                }
                            }
                        }
                    })
            }
        }
        .padding()
    }
}

struct LocationDetailView: View {
    
    @ObservedObject var eventManager: EventManager

    let columns = [
            GridItem(.fixed(30)),
            GridItem(.flexible())
        ]
    
    var body: some View{
        VStack(alignment: .leading){
            
            // Place title section
            HStack(alignment: .top){
                
                VStack{
                    AsyncImage(url: URL(string: convertHTTP(url: eventManager.event.location.image ?? "") ?? "")){ phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 110, height: 110)
                                .clipped()
                                .cornerRadius(10)
                            
                        } else if phase.error != nil {
                            Image(systemName: "photo.on.rectangle.angled")
                                .imageScale(.large)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.secondary)
                            
                        } else {
                            ProgressView()
                        }
                    }
                }
                .frame(width: 110, height: 110)
                
                VStack(alignment: .leading){
                    Text(eventManager.event.location.name ?? "").font(.title3).bold()
                    Text(eventManager.event.location.address ?? "").font(.subheadline).opacity(0.5)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 10)
                .padding(.leading, 5)
            }
            .padding()
        
            // Event date time
            VStack(alignment: .leading){
                if eventManager.event.startDay == eventManager.event.endDay{
                    Text(eventManager.getEventDate(period: .start)).font(.title3).bold()
                }
                else {
                    HStack{
                        Text(eventManager.getEventDate(period: .start).replacingOccurrences(of: ", ", with: "\n")).font(.title3).bold()
                        Spacer()
                        Text(eventManager.getEventDate(period: .end).replacingOccurrences(of: ", ", with: "\n")).font(.title3).bold().multilineTextAlignment(.trailing)
                    }

                }
                HStack(alignment: .center){
                    Text(eventManager.getStartTimeText())                    
                        .foregroundStyle(.accent)
                    VStack{
                        Text(eventManager.getEventDurationText()).font(.footnote)                    .foregroundStyle(.accent)

                        HorizontalLine()
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [3]))
                            .frame(height: 1)
                            .padding(.horizontal)
                        Text("")
                    }
                    Text(eventManager.getEndTimeText())                    .foregroundStyle(.accent)
                }
                .font(.title2)
                .padding()
            }
        }
        .padding()
    }
    
    func convertHTTP(url: String) -> String? {
        var comps = URLComponents(string: url)
        comps?.scheme = "https"
        let https = comps?.string
        return https
    }
}

struct PeriodicDetailView: View{
    
    @ObservedObject var eventManager: EventManager
    var startText: String
    var endText: String

    let columns = [
            GridItem(.fixed(30)),
            GridItem(.flexible())
        ]
    
    var body: some View{
        VStack(alignment: .leading){
            
            HStack(){
                
                VStack{
                    AsyncImage(url: URL(string: convertHTTP(url: eventManager.event.location.image ?? "") ?? "")){ phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 90, height: 90)
                                .clipped()
                                .cornerRadius(10)
                            
                        } else if phase.error != nil {
                            Image(systemName: "photo.on.rectangle.angled")
                                .imageScale(.large)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.secondary)
                            
                        } else {
                            ProgressView()
                        }
                    }
                }
                .frame(width: 90, height: 90)

                VStack(alignment: .leading){
                    Text(eventManager.event.location.name ?? "").font(.title3).bold()
                    Text(eventManager.event.location.address ?? "").font(.subheadline).opacity(0.5)
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 10)
                .padding(.leading, 5)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .padding(.top)
        
            VStack(alignment: .leading){
                Text(startText).font(.title3).bold().padding(.top)
                VStack(alignment: .trailing){
                    Text(eventManager.getEventDate(period: .start) + ", " + eventManager.getStartTimeText()).font(.title2).bold().foregroundStyle(.accent)
                }
            }
            .padding(.vertical, 10)
            .padding(.leading, 5)
            
            Divider()

            // Event date time
            HStack(alignment: .center){
                Text(endText).font(.callout)
                Spacer()
                VStack(alignment: .trailing){
                    Text(eventManager.getEventDate(period: .end) + ", " + eventManager.getEndTimeText()).font(.callout)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
        .padding(.horizontal)
    }
    
    func convertHTTP(url: String) -> String? {
        var comps = URLComponents(string: url)
        comps?.scheme = "https"
        let https = comps?.string
        return https
    }
}

struct EventLocationOverview: View {
    
    @ObservedObject var eventManager: EventManager
    
    let columns = [
            GridItem(.fixed(30)),
            GridItem(.flexible())
        ]
    
    var body: some View {
        
        // Event Location Descripion
        VStack(alignment: .leading){
            Text("Overview").font(.title2).bold().padding(.top, 30).padding(.horizontal, 8)
            
            RatingStarView(rating: eventManager.event.location.rating ?? 0)
                .frame(width: 120)
                .padding(.horizontal, 8)
                .foregroundStyle(.accent)
            
            LazyVGrid(columns: columns, alignment: .leading, spacing: 25) {
                Image(systemName: "map.fill").foregroundStyle(.accent)
                Text(eventManager.event.location.address ?? "")
                Image(systemName: "phone.fill").foregroundStyle(.accent)
                Text(eventManager.event.location.phone ?? "")
                Image(systemName: "clock.fill").foregroundStyle(.accent)
                Text(eventManager.event.location.operatingHour ?? "")
            }
            .padding()
            .padding(.top, 15)
            .font(.subheadline)
        }
        .padding()
    }
}

struct EventDetailButton: View {
    
    @EnvironmentObject var tripManager: TripManager
    @ObservedObject var eventManager: EventManager
    
    @State var deleteEvent = false
    @State var didError = false
    @State var addingAmount = false
    @State var expenseAmount = ""
    @FocusState var isFocused: Bool
    @Binding var isEditting: Bool
    @Namespace var buttonAnimation
    
    var validAmount: Bool {
        if let number = Double(expenseAmount){
            if number >= 0{
                return true
            }
        }
        return false
    }

    let eventDay: Int
    let eventIndex: Int
    let editable: Bool
    
    var body: some View{
        
        
        VStack{
            
            if !isEditting{
                // Edit and delete button section
                if editable{
                    HStack{
                        Button("Delete Event"){
                            deleteEvent.toggle()
                        }
                        .foregroundStyle(.red)
                        Spacer()
                            .alert("Delete this event?", isPresented: $deleteEvent) {
                                Button("Cancel", role: .cancel) {
                                    deleteEvent.toggle()
                                }
                                Button("Delete", role: .destructive) {
                                    tripManager.deleteEvent(eventDay: eventDay, eventIndex: eventIndex)
                                }
                            }
                        
                        Button("Edit"){
                            withAnimation {
                                eventManager.updateValue()
                                isEditting.toggle()
                            }
                        }
                        .matchedGeometryEffect(id: "edit", in: buttonAnimation)
                    }.padding(.top, 10)
                    
                    Divider()
                }
                
                // Event expense record
                HStack{
                    if !addingAmount{
                        Text("Expense").font(.headline)
                            .matchedGeometryEffect(id: "expense", in: buttonAnimation)
                        Spacer()
                        
                        if eventManager.event.expense != nil {
                            Text("$\((eventManager.event.expense ?? 0),  specifier: "%.2f")")
                        }else {
                            if !editable{
                                Text("-")
                            }
                        }
                        
                        if editable{
                            Button{
                                expenseAmount = eventManager.event.expense==nil ? "":"\(eventManager.event.expense ?? 0)"
                                withAnimation {
                                    addingAmount.toggle()
                                }
                                isFocused = true
                            } label: {
                                if eventManager.event.expense == nil{
                                    Text("Add")
                                } else {
                                    Image(systemName: "pencil.line")
                                }
                            }
                            .matchedGeometryEffect(id: "expenseAddButton", in: buttonAnimation)
                        }
                        
                    } else {
                        VStack{
                            
                            HStack{
                                Text("Expense").font(.headline)
                                    .matchedGeometryEffect(id: "expense", in: buttonAnimation)
                                Text("$").padding(.leading,40)
                                TextField("", text: $expenseAmount).frame(width: 100).textFieldStyle(.roundedBorder)
                                    .focused($isFocused)
                                Spacer()
                            }.padding(.bottom, 20)
                            
                            HStack{
                                Button("Cancel"){
                                    withAnimation {
                                        addingAmount.toggle()
                                    }
                                }
                                Spacer()
                                Button("Save"){
                                    tripManager.updateEventExpense(eventDay: eventDay, eventIndex: eventIndex, amount: Double(expenseAmount) ?? 0)
                                    withAnimation {
                                        addingAmount.toggle()
                                    }
                                }
                                .disabled(!validAmount)
                                .buttonStyle(.borderedProminent)
                                .matchedGeometryEffect(id: "expenseAddButton", in: buttonAnimation)

                            }
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                
                Divider()
            } else {
                Button{
                    withAnimation {
                        let result = tripManager.editEvent(eventDay: eventDay,
                                                           eventIndex: eventIndex,
                                                           eventCategory: eventManager.eventCategory,
                                                           startDay: eventManager.edittingStartDay,
                                                           endDay: eventManager.edittingEndDay,
                                                           startTime: eventManager.edittingStartTime,
                                                           endTime: eventManager.edittingEndTime,
                                                           location: eventManager.edittingLocation,
                                                           destination: eventManager.edittingDestination)
                        if result == true{
                            isEditting.toggle()
                        } else {
                            didError.toggle()
                        }
                    }
                } label: {
                    Text("Save Change").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.accent)
                .matchedGeometryEffect(id: "edit", in: buttonAnimation)
                .alert("Failed to Save Event", isPresented: $didError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text(tripManager.newEventErrorMessage)
                }
                .disabled(eventManager.invalidEdittingEvent)
                
                Button{
                    withAnimation {
                        isEditting.toggle()
                    }
                } label: {
                    Text("Cancel").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.accent)
            }
        }
        .padding(.horizontal)
    }
}

struct EventEditView: View {
    
    @EnvironmentObject var tripManager: TripManager
    @ObservedObject var eventManager: EventManager
    
    @State var startEdittingLocation = false
    @State var startEdittingDestination = false
    
    var editAnimation: Namespace.ID

    let columns = [
        GridItem(.fixed(120), alignment: .leading),
        GridItem(.flexible(), alignment: .trailing)
        ]
    
    var body: some View {
        
        VStack{
            HStack{
                TripCirceleIcon(image: Image(systemName: eventManager.eventCategory.icon), color: .accent, dimension:60).padding(.horizontal)
                Picker("Category", selection: $eventManager.eventCategory){
                    ForEach(EventType.allCases){category in
                        Text(category.name)
                            .tag(category)
                    }
                }.pickerStyle(.menu)
                Spacer()
            }.padding()
            
            LazyVGrid(columns: columns, spacing: 25) {
    
                // Edit Event Period
                if tripManager.trip.startDate == nil{
                    Text("Start Time").font(.headline)
                    HStack{
                        Picker("Day", selection: $eventManager.edittingStartDay){
                            ForEach(1..<(tripManager.trip.totalDays ?? 0)){ day in
                                Text("Day \(day)").tag(day)
                            }
                        }
                        DatePicker("StartTime",
                                   selection: $eventManager.edittingStartTime,
                                   displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                    }
                    
                    Text("Start Time").font(.headline)
                    HStack{
                        Picker("Day", selection: $eventManager.edittingEndDay){
                            ForEach(1..<(tripManager.trip.totalDays ?? 0)){ day in
                                Text("Day \(day)").tag(day)
                            }
                        }
                        DatePicker("StartTime",
                                   selection: $eventManager.edittingEndTime,
                                   displayedComponents: [.hourAndMinute])
                        .labelsHidden()
                    }
                } else {
                    Text("Start Time").font(.headline)
                    DatePicker("StartTime",
                               selection: $eventManager.edittingStartTime,
                               in: tripManager.getTripRange(),
                               displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .matchedGeometryEffect(id: "startTime", in: editAnimation)
                    
                    Text("End Time").font(.headline)
                    DatePicker("EndTime",
                               selection: $eventManager.edittingEndTime,
                               in: tripManager.getTripRange(),
                               displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .matchedGeometryEffect(id: "endTime", in: editAnimation)
                }
                
                // Edit Event Location
                Text("Location").font(.headline)
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.secondary).opacity(0.6)
                    .opacity(0.2)
                    .frame(width: 150, height: 35)
                    .overlay(alignment: .trailing) {
                        Text(eventManager.edittingLocation?.name ?? "").padding(.trailing)
                            .matchedGeometryEffect(id: "eventLocation", in: editAnimation)
                    }
                    .onTapGesture {
                        startEdittingLocation.toggle()
                    }
                
                if eventManager.eventCategory == .carRental || eventManager.eventCategory == .flight{
                    // Edit Event Destination
                    Text("Destination").font(.headline)
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.secondary).opacity(0.6)
                        .opacity(0.2)
                        .frame(width: 150, height: 35)
                        .overlay(alignment: .trailing) {
                            Text(eventManager.edittingDestination?.name ?? "").padding(.trailing)
                                .matchedGeometryEffect(id: "eventDestination", in: editAnimation)
                        }
                        .onTapGesture {
                            startEdittingDestination.toggle()
                        }
                }
            }
        }
        .padding()
        
        .sheet(isPresented: $startEdittingLocation, content: {
            SearchLocationSheet(tripManager: tripManager, location: $eventManager.edittingLocation, prompt: "")
        })
        
        .sheet(isPresented: $startEdittingDestination, content: {
            SearchLocationSheet(tripManager: tripManager, location: $eventManager.edittingDestination, prompt: "")
        })
    }
}

#Preview("Place Event Detail View") {
    EventDetailView(eventManager: EventManager(event: event3), eventDay: 0,  eventIndex: 0, editable: false)
        .environmentObject(TripManager(trip: itinerary1))
}

#Preview("Periodic Event Detail View"){
    EventDetailView(eventManager: EventManager(event: event2), eventDay: 0, eventIndex: 0, editable: false)
        .environmentObject(TripManager(trip: itinerary1))
}

#Preview("Transportation Event Detail View"){
    EventDetailView(eventManager: EventManager(event: event1), eventDay: 0, eventIndex: 0, editable: false)
        .environmentObject(TripManager(trip: itinerary1))
}

struct EventEditView_Previews: PreviewProvider {
    @Namespace static var namespace // <- This

    static var previews: some View {
        EventEditView(eventManager: EventManager(event: event3), editAnimation: namespace)
            .environmentObject(TripManager(trip: itinerary1))
    }
}
