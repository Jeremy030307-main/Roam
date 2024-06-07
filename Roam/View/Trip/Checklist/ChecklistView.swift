//
//  ChecklistView.swift
//  Roam
//
//  Created by Jeremy Teng  on 16/05/2024.
//

import SwiftUI

struct ChecklistView: View {
    
    @ObservedObject var tripManager: TripManager
    @State var addNewCatogory = false
    @FocusState var isFocused: Bool
    @State var newCategoryName = ""
    let editable: Bool
        
    var body: some View {
        NavigationStack{
            List{
                ForEach(Array(tripManager.trip.checklist.enumerated()), id: \.1.id) { index1, checklistCatogory in
                    CheckListSectionView(tripManager: tripManager, categoryIndex: index1, checklistCatogory: checklistCatogory, editable: editable)
                }
                if editable{
                    Section{
                        
                    } header: {
                        if addNewCatogory == false {
                            Button{
                                addNewCatogory.toggle()
                                isFocused = true
                            }label: {
                                Image(systemName: "plus.circle.kfill")
                                Text("New Section")
                            }
                        }
                        else {
                            HStack{
                                TextField("New Section", text: $newCategoryName).font(.callout)
                                    .focused($isFocused)
                                    .onSubmit {
                                        tripManager.addNewCheckCatogory(categoryName: newCategoryName)
                                        newCategoryName = ""
                                        addNewCatogory.toggle()
                                    }
                                
                                Button("Cancel"){
                                    newCategoryName = ""
                                    isFocused = false
                                    addNewCatogory.toggle()
                                }
                                
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Checklist").font(.headline)
                        Text(tripManager.trip.title ?? "").font(.subheadline)
                    }
                }
            }
        }
    }
}

struct CheckListSectionView: View {
    
    @ObservedObject var tripManager: TripManager
    var categoryIndex: Int
    var checklistCatogory: ChecklistCateogry
    let editable: Bool
    
    @State var collapsed = false
    
    var body: some View {
        Section{
            if !collapsed{
                ForEach(Array(checklistCatogory.checklists.enumerated()), id: \.1.id) { index2, checklistItem in
                    ChecklistRowView(tripManager: tripManager, categoryIndex: categoryIndex, checklistIndex: index2, checkListItem: checklistItem, editable: editable)
                }
                .onDelete { indexSet in
                    tripManager.deleteChecklistItem(at: indexSet, categoryIndex: categoryIndex)
                }
                .deleteDisabled(!editable)
                
                if editable{
                    ChecklistAddRowView(tripManager: tripManager, categoryIndex: categoryIndex)
                }
            }
        } header: {
            HStack{
                Text(checklistCatogory.category_name)
                Spacer()
                Button{
                    withAnimation(.interactiveSpring) {
                        collapsed.toggle()
                    }
                }label: {
                    Image(systemName: collapsed ? "chevron.forward":"chevron.down")
                }
            }
        }
        .headerProminence(.increased)
    }
}

struct ChecklistRowView: View {
    
    @ObservedObject var tripManager: TripManager
    var categoryIndex: Int
    var checklistIndex: Int
    var checkListItem: Checklist
    let editable: Bool
    @State var editedText = ""

    var body: some View{
        HStack{
            Button{
                tripManager.check(categoryIndex: categoryIndex, checklistIndex: checklistIndex)
            } label: {
                Image(systemName: checkListItem.completed ?? false ? "circle.fill":"circle")
            }.frame(width: 20).buttonStyle(.borderless)
                .disabled(!editable)
            
            VStack{
                TextField("", text: $editedText)
                    .disabled(!editable)
                    .onChange(of: editedText, { oldValue, newValue in
                        tripManager.editChecklistItem(categoryIndex: categoryIndex, checklistIndex: checklistIndex, updatedContent: editedText)

                    })
                    .foregroundStyle(checkListItem.completed ?? false ?  .secondary:.primary)
                    .disabled(checkListItem.completed ?? false )
            }
            Spacer()
        }
        .onAppear(perform: {
            editedText = checkListItem.title ?? ""
        })
    }
}

struct ChecklistAddRowView: View {
    
    @ObservedObject var tripManager: TripManager
    var categoryIndex: Int
    @State var newContent = ""
    
    var body: some View {
        HStack{
            Image(systemName: "circle.dashed").opacity(0.5)
            TextField("", text: $newContent)
                .onSubmit {
                    tripManager.addNewCheckListItem(cateogryIndex: categoryIndex, newContent: newContent)
                    newContent = ""
                }
        }
    }
}

#Preview {
    ChecklistView(tripManager: TripManager(trip: itinerary2), editable: false)
}
