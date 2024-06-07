//
//  EventManager.swift
//  Roam
//
//  Created by Jeremy Teng  on 01/05/2024.
//

import Foundation
import SwiftUI
enum EventPeriod {
    case start, end
}

class EventManager: ObservableObject {
    
    @Published var event: Event
    
    @Published var eventCategory: EventType = .accomodation
    @Published var edittingStartDay: Int = 0
    @Published var edittingEndDay: Int = 0
    @Published var edittingStartTime: Date = .now
    @Published var edittingEndTime: Date = .now
    @Published var edittingLocation: LocationData?
    @Published var edittingDestination: LocationData?
    var invalidEdittingEvent : Bool {
        if edittingEndDay < edittingStartDay {
            return true
        } else  if edittingEndDay == edittingStartDay{
            if edittingEndTime < edittingStartTime {
                return true
            }
        }
        
        if eventCategory == .flight || eventCategory == .carRental {
            if edittingDestination == nil {
                return true
            }
        }
        
        return false
    }
    
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
        
        return dateFormatter.string(from: event.startTime )
    }
    
    func getEndTimeText() -> String {
        
        var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "HH:mm"
            return formatter
        }
        
        return dateFormatter.string(from: event.endTime  )
    }
    
    func getEventHeight(atDay: Int) -> CGFloat {
        
        let startHour = Calendar.current.dateComponents([.hour], from: event.startTime)
        let startMin = Calendar.current.dateComponents([.minute], from: event.startTime)
        let endHour = Calendar.current.dateComponents([.hour], from: event.endTime)
        let endMin = Calendar.current.dateComponents([.minute], from: event.endTime)
        var minute: Int = 0
        if event.startDay == event.endDay {  // the event start and end at same day
            if let startHour = startHour.hour, let endHour = endHour.hour, let startMin = startMin.minute, let endMin = endMin.minute {
                minute = (endHour*60 + endMin) - (startHour*60 + startMin)
            }

        } else {  // the event start at one day and end at one day
            if atDay == event.startDay{  // display block the part of event that appear at firsst dat
                if let dateHour = startHour.hour, let dateMinute = startMin.minute {
                    minute = (24*60) - (dateHour*60) - dateMinute
                    print(minute, 1)

                }
                
            } else if atDay == event.endDay {
                if let dateHour = endHour.hour, let dateMinute = endMin.minute {
                    minute = (dateHour*60) + dateMinute
                    print(minute, 2)
                }
                
            } else {
                minute = (24*60)
            }
        }
        return CGFloat(Double(minute) * 1.5)
    }
    
    func getEventDurationText() -> String {
        
        let startHour = Calendar.current.dateComponents([.hour], from: event.startTime).hour ?? 0
        let startMin = Calendar.current.dateComponents([.minute], from: event.startTime).minute ?? 0
        let endHour = Calendar.current.dateComponents([.hour], from: event.endTime).hour ?? 0
        let endMin = Calendar.current.dateComponents([.minute], from: event.endTime).minute ?? 0
        
        var duration: Int = 0
        if event.startDay == event.endDay{
            duration = ((endHour*60) + endMin) - ((startHour*60) + startMin)
        } else {
            duration = ((24*60) - ((startHour*60) + startMin) + ((endHour*60) + endMin))
            print(duration,startHour,startMin,endHour,endMin)
        }
        let hours = Int(floor(Double(duration/60)))
        print(hours)
        let minutes = duration - hours*60
        print(minutes)
        var returnText = ""
        if event.endDay - event.startDay > 2{
            let dayBetween = event.endDay - event.startDay - 1
            returnText = dayBetween>1 ? "\(dayBetween) days": "\(dayBetween) day"
        }
        
        if minutes == 0 {
            returnText += " " + (hours > 1 ? "\(hours) hours":"\(hours) hour")
        }
        else {
            let firstPart = hours > 1 ? "\(hours) hours":"\(hours) hour"
            let secondPart = minutes > 1 ? "\(minutes) minutes": "\(minutes) minute"
            returnText += " " + firstPart + " " + secondPart
        }
        
        return returnText
    }
    
    func getIcon() -> Image {
        
        let imageName = EventType(rawValue: event.type)?.icon ?? ""
        return Image(systemName: imageName)
    }
    
    func getEventDate(period: EventPeriod) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM dd yyyy"
        let weekDay = dateFormatter.string(from: period == .start ? event.startTime:event.endTime )
        return weekDay
    }

    func getLocationStar() -> [String]{
        
        var ratingCounter = event.location.rating
        var returnList: [String] = []
        for _ in 0..<5{
            if ratingCounter == 0.5{
                returnList.append("star.leadinghalf.filled")
            }else if ratingCounter ?? 0 <= 0{
                returnList.append("star")
            }else {
                returnList.append("star.fill")
            }
            ratingCounter!-=1
        }
        return returnList
    }
    
    func updateValue(){
        self.eventCategory = EventType(rawValue: self.event.type) ?? .accomodation
        self.edittingStartDay = event.startDay
        self.edittingEndDay = event.endDay
        self.edittingStartTime = event.startTime
        self.edittingEndTime = event.endTime
        self.edittingLocation = LocationData(location: event.location)
        if let destination = event.destination{
            self.edittingDestination = LocationData(location: destination)
        }
    }
}
