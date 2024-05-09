//
//  textfille.swift
//  Roam
//
//  Created by Jeremy Teng  on 09/05/2024.
//

import SwiftUI

struct textfille: View {
    
    var locationData: LocationData
    var locationDetail: LocationDetail?
    
    var body: some View {
        Text(locationData.name ?? "")
        Text(locationDetail?.address ?? "hihi")
        Text("fgsgfgsg")
    }
}

