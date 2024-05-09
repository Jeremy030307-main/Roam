//
//  EventManager.swift
//  Roam
//
//  Created by Jeremy Teng  on 01/05/2024.
//

import Foundation
import SwiftUI

class EventManager: ObservableObject {
    
    @Published var event: Event
    
    init(event: Event) {
        self.event = event
    }
    
    func getStartTimeText() -> String {
        
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "HH:mm"
            return formatter
        }
        
        return dateFormatter.string(from: event.startTime)
    }
    
    func getEndTimeText() -> String {
        
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "HH:mm"
            return formatter
        }
        
        return dateFormatter.string(from: event.endTime)
    }
    
    func getEventHeight() -> CGFloat {
        
        let diffComponents = Calendar.current.dateComponents([.minute], from: event.startTime, to: event.endTime)
        
        guard let minutes: Int = diffComponents.minute else {
            return CGFloat(0)
        }
        
        return CGFloat(Double(minutes) * 1.5)
    }
    
    func getEventDurationText() -> String {
        
        let diffComponents = Calendar.current.dateComponents([.hour, .minute], from: event.startTime, to: event.endTime)
        
        guard let hours: Int = diffComponents.hour, let minutes: Int = diffComponents.minute else {
            return ""
        }
        
        if minutes == 0 {
            return  hours > 1 ? "\(hours) hours":"\(hours) hour"
        }
        else {
            let firstPart = hours > 1 ? "\(hours) hours":"\(hours) hour"
            let secondPart = minutes > 1 ? "\(minutes) minutes": "\(minutes) minute"
            return firstPart + " " + secondPart
        }
        
    }
    
    func getIcon() -> Image {
        
        let imageName = EventType(rawValue: event.type)?.icon ?? ""
        return Image(systemName: imageName)
    }
    
    func getEventDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM dd yyyy"
        let weekDay = dateFormatter.string(from: event.startTime)
        return weekDay
    }

    func getLocationStar() -> [String]{
        
        var ratingCounter = event.location.rating
        var returnList: [String] = []
        for _ in 0..<5{
            if ratingCounter == 0.5{
                returnList.append("star.leadinghalf.filled")
            }else if ratingCounter <= 0{
                returnList.append("star")
            }else {
                returnList.append("star.fill")
            }
            ratingCounter-=1
        }
        return returnList
    }
}
