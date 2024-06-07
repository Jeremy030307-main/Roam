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
    let editable: Bool
    
    var body: some View {
        NavigationStack{
            ZStack(alignment: .bottom){
                VStack{
                    ItineraryTopNavBar(totalDays: tripManager.trip.totalDays ?? 0,
                                       startDate: tripManager.trip.startDate, endDate: tripManager.trip.endDate, daySelected: $selectedDay)
                    .padding(.top, 5)
                    
                    TabView(selection: $selectedDay){
                       ForEach(1..<(tripManager.trip.totalDays ?? 0)+1){ day in
                           VStack{
                               VStack(alignment: .leading){
                                   Text("Event Expense").font(.title2).bold()
                                   ForEach(Array(tripManager.trip.events[selectedDay-1].events.enumerated()), id: \.1.id){ index, event in
                                       ExpenseCardview(tripManager: tripManager,day: selectedDay, index: index, event: event, editable: editable)
                                   }
                               }
                               .padding()
                               
                               VStack(alignment: .leading){
                                   Text("Other Expense").font(.title2).bold()
                                   ForEach(Array(tripManager.trip.expenses[selectedDay-1].expensesPerDay.enumerated()), id: \.1.id){ index, expense in
                                       ExpenseCardview(tripManager: tripManager,day: selectedDay, index: index, expense: expense,editable: editable)
                                   }
                               }
                               .padding()
                               Spacer()
                           }
                           .tag(day)
                           .tabItem { Text("\(day)") }
                           .toolbar(.hidden, for: .tabBar)
                           .simultaneousGesture(DragGesture())
                       }
                   }
                   .animation(.easeOut(duration: 0.2), value: tripManager.selectedDay)
                   .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                if editable{
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
            }
            .background(Color(.secondarySystemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Expense").font(.headline)
                        Text(tripManager.trip.title ?? "").font(.subheadline)
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
    
    @ObservedObject var tripManager: TripManager
    @State var showDetail = false
    var day: Int
    var index: Int
    var expense: Expense?
    var event: Event?
    let editable: Bool

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
                        
                        Text(event.location.name ?? "").font(.caption).bold().lineLimit(1)
                        Spacer()
                        Text("$ \((event.expense ?? 0),  specifier: "%.2f")").font(.caption).bold()
                    }
                }
            }
        }
        .foregroundStyle(.primary)
        .sheet(isPresented: $showDetail){
            ExpenseDetailView(tripManager: tripManager,expenseDay: day, expenseIndex: index, expense: expense, event: event, editable: editable)
        }
    }
}

struct ExpenseDetailView: View {
    
    @ObservedObject var tripManager: TripManager
    
    @State var isEditting = false
    @State var editingDescription: String = ""
    @State var edittingDate: Date = .now
    @State var editingAmount: String = ""
    @State var expenseCategory: ExpenseCategory = .food
    @State var edittingDay: Int = 0
    @Namespace var editAnimation
    @FocusState var isFocused: Bool

    @State var deleteExpense = false
    var expenseDay: Int
    var expenseIndex: Int
    var expense: Expense?
    var event: Event?
    var invalidExpense: Bool{
        if let num = Double(editingAmount){
            if num > 0 && !editingDescription.trimmingCharacters(in: .whitespaces).isEmpty{
                return false
            }
        }
        return true
    }
    var editable: Bool
    
    var body: some View{
        if let expense = expense {
            if !isEditting{
                VStack(alignment: .leading){
                    HStack(alignment: .top){
                        TripCirceleIcon(image: Image(systemName: ExpenseCategory(rawValue: expense.catogery)?.icon ?? ""), color: ExpenseCategory(rawValue: expense.catogery)?.color ?? .accent, dimension:40)
                            .matchedGeometryEffect(id: "categoryIcon", in: editAnimation)
                        
                        VStack(alignment:. leading){
                            Text(ExpenseCategory(rawValue: expense.catogery)?.name ?? "").font(.title2).bold()
                                .matchedGeometryEffect(id: "categoryName", in: editAnimation)
                            Text(expense.title).font(.title3).foregroundStyle(.secondary)
                                .matchedGeometryEffect(id: "title", in: editAnimation)
                            Text("$ \(expense.amount, specifier: "%.2f")")
                                .matchedGeometryEffect(id: "amount", in: editAnimation)
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
                            .matchedGeometryEffect(id: "date", in: editAnimation)
                    }
                    .padding()
                    .padding(.horizontal)
                }
            } else {
                EditExpenseView(tripManager: tripManager, editingDescription: $editingDescription, edittingDate: $edittingDate, editingAmount: $editingAmount, expenseCategory: $expenseCategory, expenseDay: $edittingDay, editAnimation: editAnimation)
            }
        }
        
        if let event = event {
            HStack(alignment: .top){
                TripCirceleIcon(image: Image(systemName: EventType(rawValue: event.type)?.icon ?? ""), color: .accent, dimension:40)
                
                VStack(alignment:. leading){
                    Text(EventType(rawValue: event.type)?.name ?? "").font(.title2).bold()
                    Text(event.location.name ?? "").font(.title3).foregroundStyle(.secondary)
                    
                    if !isEditting{
                        Text("$ \(event.expense ?? 0, specifier: "%.2f")")
                            .font(.title).bold()
                            .padding(.vertical)
                    } else {
                        HStack{
                            Text("$").font(.title).bold()

                            TextField("", text: $editingAmount)
                                .focused($isFocused)
                                .font(.title).bold()
                                .padding(.vertical)
                        }
                    }
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
        
        if editable{
            VStack{
                if !isEditting{
                    Button{
                        editingAmount = expense?.amount == nil ? "":"\(expense?.amount ?? 0)"
                        editingDescription = expense?.title ?? ""
                        edittingDate = expense?.date ?? .now
                        expenseCategory = ExpenseCategory(rawValue: expense?.catogery ?? 0) ?? .food
                        edittingDay = expense?.day ?? 0
                        if let event = event{
                            editingAmount = event.expense == nil ? "":"\(event.expense!)"
                            editingDescription = "event"
                        }
                        withAnimation {
                            isEditting.toggle()
                            isFocused = true
                        }
                    } label: {
                        Text("Edit").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.accent)
                    
                    if let expense = expense{
                        Button{
                            deleteExpense.toggle()
                        } label: {
                            Text("Delete").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                    
                } else {
                    Button{
                        withAnimation {
                            isEditting.toggle()
                            if let expense = expense{
                                tripManager.editExpense(expenseDay: expenseDay, expenseIndex: expenseIndex, expenseCaegory: expenseCategory, title: editingDescription, amount: Double(editingAmount) ?? 0, date: edittingDate, day: edittingDay)
                            }
                            if let event = event {
                                tripManager.updateEventExpense(eventDay: expenseDay, eventIndex: expenseIndex, amount: Double(editingAmount) ?? 0)
                            }
                        }
                    } label: {
                        Text("Save Change").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.accent)
                    .disabled(invalidExpense)
                    
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
            .alert("Delete this expense?", isPresented: $deleteExpense) {
                Button("Cancel", role: .cancel) {
                    deleteExpense.toggle()
                }
                Button("Delete", role: .destructive) {
                    tripManager.deleteExpense(expenseDay: expenseDay, expenseIndex: expenseIndex)
                }
            }
            .padding()
        }
        Spacer()
    }
}

struct EditExpenseView: View {
    
    @ObservedObject var tripManager: TripManager
    @Binding var editingDescription: String
    @Binding var edittingDate: Date
    @Binding var editingAmount: String
    @Binding var expenseCategory: ExpenseCategory
    @Binding var expenseDay: Int
    
    var editAnimation: Namespace.ID

    let columns = [
        GridItem(.fixed(120), alignment: .leading),
        GridItem(.flexible(), alignment: .trailing)
        ]
    
    var body: some View {
        
        LazyVGrid(columns: columns, spacing: 25) {
            Text("Category").font(.headline)
            HStack{
                Picker("Category", selection: $expenseCategory){
                    ForEach(ExpenseCategory.allCases){category in
                        Text(category.name)
                            .tag(category)
                    }
                }.matchedGeometryEffect(id: "categoryName", in: editAnimation)

                TripCirceleIcon(image: Image(systemName: expenseCategory.icon), color: expenseCategory.color, dimension:30)                            .matchedGeometryEffect(id: "categoryIcon", in: editAnimation)

            }
            Text("Description").font(.headline)
            TextField("", text: $editingDescription).textFieldStyle(.roundedBorder).frame(width: 150)
                .matchedGeometryEffect(id: "title", in: editAnimation)

            Text("Amount").font(.headline)
            TextField("", text: $editingAmount).textFieldStyle(.roundedBorder).frame(width: 150)
                .matchedGeometryEffect(id: "amount", in: editAnimation)

            Text("Date").font(.headline)
            if tripManager.trip.startDate == nil{
                Picker("Day", selection: $expenseDay){
                    ForEach(1..<(tripManager.trip.totalDays ?? 0) + 1){ day in
                        Text("Day \(day)").tag(day)
                    }
                }
            } else {
                DatePicker("Date",
                           selection: $edittingDate,
                           in: tripManager.getTripRange(),
                           displayedComponents: .date)
                .labelsHidden()
                .matchedGeometryEffect(id: "date", in: editAnimation)
            }
        }
        .padding()
    }
}


#Preview("Main View") {
    ExpenseView(tripManager: TripManager(trip: itinerary2), editable: false)
}

#Preview("Detail View"){
    ExpenseDetailView(tripManager: TripManager(trip: itinerary2),expenseDay: 0, expenseIndex: 0, expense: expense1, editable: false)
}

#Preview("Detail View (Event)"){
    ExpenseDetailView(tripManager: TripManager(trip: itinerary2),expenseDay: 0, expenseIndex: 0, event: event1, editable: false)
}

struct EditExpenseView_Previews: PreviewProvider {
    @Namespace static var namespace // <- This

    static var previews: some View {
        EditExpenseView(tripManager: TripManager(trip: itinerary2), editingDescription: .constant(""), edittingDate: .constant(.now), editingAmount: .constant(""), expenseCategory: .constant(.food), expenseDay: .constant(1), editAnimation: namespace)
    }
}


