//
//  test.swift
//  Roam
//
//  Created by Jeremy Teng  on 10/05/2024.
//

import SwiftUI

struct test: View {

    @Environment(\.dismiss) var dismiss
    @ObservedObject var locationService: CitySearchViewModal
    var animation: Namespace.ID

    var body: some View {
            Section(header: Text("Location Search")) {
                ZStack(alignment: .trailing) {
                    TextField("Search", text: $locationService.queryFragment)
                    // This is optional and simply displays an icon during an active search
                    if locationService.status == .isSearching {
                        Image(systemName: "clock")
                            .foregroundColor(Color.gray)
                    }
                }
                .matchedGeometryEffect(id: "destinationSearch", in: animation)
            }
            Section(header: Text("Results")) {
                List {
                    ForEach(locationService.returnText(), id:\.self) { completionResult in
                        // This simply lists the results, use a button in case you'd like to perform an action
                        // or use a NavigationLink to move to the next view upon selection.
                        Text(completionResult)
                    }
                }
            }
    }
}

struct test_Previews: PreviewProvider {
    @Namespace static var namespace // <- This

    static var previews: some View {
        test(locationService: CitySearchViewModal(), animation: namespace)
    }
}
