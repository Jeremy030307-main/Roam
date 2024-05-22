//
//  ExpenseView.swift
//  Roam
//
//  Created by Jeremy Teng  on 30/04/2024.
//

import SwiftUI

struct ExpenseView: View {
    
    @ObservedObject var tripManager: TripManager
    @State var selectedDay = 1
    @State var addExpense = false
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .bottom){
                VStack{
                    ItineraryTopNavBar(totalDays: tripManager.trip.totalDays,
                                       startDate: tripManager.trip.startDate, endDate: tripManager.trip.endDate, daySelected: $selectedDay)
                    .padding(.top, 5)
                    
                    VStack(alignment: .leading){
                        Text("Event Expense").font(.title2).bold()
                        ForEach(tripManager.trip.events[selectedDay] ?? []){ event in
                            ExpenseCardview(event: event)
                        }
                    }
                    .padding()
                    
                    VStack(alignment: .leading){
                        Text("Other Expense").font(.title2).bold()
                        ForEach(tripManager.trip.expenses[selectedDay] ?? []){ expense in
                            ExpenseCardview(expense: expense)
                        }
                    }
                    .padding()
                    Spacer()
                    
                }
                
                HStack{
                    Spacer()
                    Button{
                        addExpense.toggle()
                    }label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 50)
                    }
                    .padding(35)
                }
            }
            .background(Color(.secondarySystemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Expense").font(.headline)
                        Text(tripManager.trip.title).font(.subheadline)
                    }
                }
            }
            .sheet(isPresented: $addExpense){
                AddExpenseview(tripManager: tripManager, addingExpense: $addExpense)
            }
            
        }
    }
}

struct ExpenseCardview: View {
    
    @State var showDetail = false
    
    var expense: Expense?
    var event: Event?
    
    var body: some View{
        Button{
            showDetail.toggle()
        } label: {
            if let expense = expense {
                BlankCard(cardColor: .white) {
                    HStack{
                        TripCirceleIcon(image: Image(systemName: ExpenseCategory(rawValue: expense.catogery)?.icon ?? ""), color: ExpenseCategory(rawValue: expense.catogery)?.color ?? .accent, dimension:25)
                        
                        Text(expense.title).font(.caption).bold()
                        Spacer()
                        Text("$ \((expense.amount),  specifier: "%.2f")").font(.caption).bold()
                    }
                }
            }
            
            if let event = event {
                BlankCard(cardColor: .white) {
                    HStack{
                        TripCirceleIcon(image: Image(systemName: EventType(rawValue: event.type)?.icon ?? ""), color: .accent, dimension: 25)
                        
                        Text(event.location.name).font(.caption).bold().lineLimit(1)
                        Spacer()
                        Text("$ \((event.expense ?? 0),  specifier: "%.2f")").font(.caption).bold()
                    }
                }
            }
        }
        .foregroundStyle(.primary)
        .sheet(isPresented: $showDetail){
            ExpenseDetailView(expense: expense, event: event)
        }
    }
}

struct ExpenseDetailView: View {
    
    var expense: Expense?
    var event: Event?
    
    var body: some View{
        if let expense = expense {
            VStack(alignment: .leading){
                HStack(alignment: .top){
                    TripCirceleIcon(image: Image(systemName: ExpenseCategory(rawValue: expense.catogery)?.icon ?? ""), color: ExpenseCategory(rawValue: expense.catogery)?.color ?? .accent, dimension:40)
                    
                    VStack(alignment:. leading){
                        Text(ExpenseCategory(rawValue: expense.catogery)?.name ?? "").font(.title2).bold()
                        Text(expense.title).font(.title3).foregroundStyle(.secondary)
                        
                        Text("$ \(expense.amount, specifier: "%.2f")")
                            .font(.title).bold()
                            .padding(.vertical)
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 5)
                    Spacer()
                }
                .padding()
                .padding(.horizontal, 15)
                
                Divider()
                
                HStack{
                    Image(systemName: "calendar").foregroundStyle(.accent).imageScale(.large)
                    Text(expense.date ?? .now, style: .date) .padding(.horizontal)
                }
                .padding()
                .padding(.horizontal)
            }
        }
        
        if let event = event {
            HStack(alignment: .top){
                TripCirceleIcon(image: Image(systemName: EventType(rawValue: event.type)?.icon ?? ""), color: .accent, dimension:40)
                
                VStack(alignment:. leading){
                    Text(EventType(rawValue: event.type)?.name ?? "").font(.title2).bold()
                    Text(event.location.name).font(.title3).foregroundStyle(.secondary)
                    
                    Text("$ \(event.expense ?? 0, specifier: "%.2f")")
                        .font(.title).bold()
                        .padding(.vertical)
                }
                .padding(.horizontal, 10)
                .padding(.top, 5)
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal)
            .padding(.horizontal, 15)
            
            Divider()
            
            let eventManager = EventManager(event: event)
            switch EventType(rawValue: eventManager.event.type){
            case .activity, .restaurant :
                LocationDetailView(eventManager: eventManager)

            case .flight, .tour, .transportation:
                TransportationEventDetailView(eventManager: eventManager)
                    .frame(maxWidth: .infinity)

            case .accomodation:
                PeriodicDetailView(eventManager: eventManager, startText: "Check In", endText: "Check Out")
                
            case .carRental:
                PeriodicDetailView(eventManager: eventManager, startText: "Pick Up", endText: "Drop Off")
                
            case .none:
                Text("")
            }
        }
        
        VStack{
            Button{
                
            } label: {
                Text("Edit").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.accent)
            Button{
                
            } label: {
                Text("Delete").frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
        }
        .padding()
        
        Spacer()
    }
}

#Preview("Main View") {
    ExpenseView(tripManager: TripManager(trip: itinerary2))
}

#Preview("Detail View"){
    ExpenseDetailView(expense: expense1)
}

#Preview("Detail View (Event)"){
    ExpenseDetailView(event: event1)
}
