//
//  AddExpenseview.swift
//  Roam
//
//  Created by Jeremy Teng  on 16/05/2024.
//

import SwiftUI

struct AddExpenseview: View {
    
    @ObservedObject var tripManager: TripManager
    @Binding var addingExpense: Bool

    @State var selectedCategory = false
    @Namespace var enterCatogeoryFormAnimation
    @State var expenseAmount = ""
    var invalidExpense: Bool{
        if let num = Double(expenseAmount){
            if num > 0 && !tripManager.newExpenseTitle.trimmingCharacters(in: .whitespaces).isEmpty{
                return false
            }
        }
        return true
    }
    
    var body: some View {
        NavigationStack{
            Form {
                switch selectedCategory{
                case true:
                    AddExpenseForm(tripManager: tripManager, expenseAmount: $expenseAmount, animation: enterCatogeoryFormAnimation)
                case false:
                    Section("Expense Category"){
                        ForEach(ExpenseCategory.allCases) {category in
                            Button{
                                withAnimation(.easeInOut) {
                                    tripManager.newExpenseType = category
                                    selectedCategory.toggle()
                                }
                            }label: {
                                HStack{
                                    TripCirceleIcon(image: Image(systemName: category.icon), color: category.color, dimension: 30)
                                        .frame(width: 30)
                                        .matchedGeometryEffect(id: category.icon, in: enterCatogeoryFormAnimation, isSource: true)
                                    
                                    Text(category.name).padding(.horizontal, 10)
                                        .matchedGeometryEffect(id: category.name, in: enterCatogeoryFormAnimation,isSource: true)
                                }
                                .padding(4)
                            }
                            .foregroundStyle(.primary)
                        }
                    }
                    .headerProminence(.increased)
                }
            }
            .toolbar{
                ToolbarItem(placement: .topBarLeading) {
                    if selectedCategory == true{
                        Button("Cancel"){
                            withAnimation {
                                selectedCategory.toggle()
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    switch selectedCategory {
                    case false:
                        Button("Cancel"){
                            addingExpense.toggle()
                        }
                    case true:
                        Button("Save"){
                            tripManager.newExpenseAmount = Double(expenseAmount)!
                            tripManager.saveNewExpense()
                            addingExpense.toggle()
                        }
                        .disabled(invalidExpense)
                    }
                }
            }
        }
    }
}

struct AddExpenseForm: View {
    
    @ObservedObject var tripManager: TripManager
    @Binding var expenseAmount: String
    var animation: Namespace.ID
    
    var body: some View {
            Section{
                TextField("0.00", text: $expenseAmount)
                    .keyboardType(.numberPad)
            } header: {
                VStack(alignment:.leading){
                    HStack{
                        TripCirceleIcon(image: Image(systemName: tripManager.newExpenseType.icon), color: tripManager.newExpenseType.color, dimension: 40)
                            .frame(width: 40)
                            .matchedGeometryEffect(id: tripManager.newExpenseType.icon, in: animation)
                        
                        Text(tripManager.newExpenseType.name).padding(.horizontal, 10).font(.title3).bold().textCase(nil).foregroundStyle(.black)
                            .matchedGeometryEffect(id: tripManager.newExpenseType.name, in: animation)
                    }.padding(.bottom, 15)
                    Text("Amount").foregroundStyle(.accent)
                }
            }
            .headerProminence(.standard)
            
            Section{
                TextField("Enter description", text: $tripManager.newExpenseTitle)
                if tripManager.trip.startDate == nil{
                    Picker("Day", selection: $tripManager.newExpenseDay){
                        ForEach(1..<(tripManager.trip.totalDays ?? 0)+1){ day in
                            Text("Day \(day)").tag(day)
                        }
                    }
                } else {
                    DatePicker("Date",
                               selection: $tripManager.newExpenseDate,
                               in: tripManager.getTripRange(),
                               displayedComponents: .date)
                }
            } header: {
                Text("Details").foregroundStyle(.accent)
            }
    }
}

#Preview{
    AddExpenseview(tripManager: TripManager(trip: itinerary4), addingExpense: .constant(true))
}

struct AddExpenseForm_Previews: PreviewProvider {
    @Namespace static var namespace

    static var previews: some View {
        AddExpenseForm(tripManager: TripManager(trip: itinerary1), expenseAmount: .constant(""), animation: namespace)
    }
}
