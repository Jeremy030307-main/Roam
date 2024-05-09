//
//  DataExample.swift
//  Roam
//
//  Created by Jeremy Teng  on 26/04/2024.
//

import Foundation

let user1 = User(name: "Arya Rej", username: "arya_rej", email: "aryarej@gmail.com", password: "12345678")
let user2 = User(name: "Toney Kuctan", username: "tony_kuctan", email: "tony01234@gmail.com", password: "12345678")
let user3 = User(name: "Christ Eddie", username: "sleepingdude", email: "sleeping123@gmail.com", password: "12345678")
let user4 = User(name: "Jason Tan", username: "jason0201", email: "jason0201@gmail.com", password: "12345678")
let user5 = User(name: "Emila Clark", username: "emilia0123", email: "emilia0001@gmail.com", password: "12345678")
let user6 = User(name: "Thomas James", username: "thomas0023", email: "thomas0023@gmail.com", password: "12345678")
let user7 = User(name: "Kelvin Mag", username: "vibingvinchester", email: "vibing@gmail.com", password: "12345678")
let user8 = User(name: "Jessical" , username: "lovetravel", email: "hahahaha@gmail.com", password: "12345678")
let user9 = User(name: "Ismael Harim", username: "ismael123", email: "ismaelharim@gmail.com", password: "12345678")

// Location object example
let location1 = Location(name: "Sydney", address: "blablabla", rating: 5, descrition: "airport", phone: "01234333242342", operatingHour: "1-234")

let location2 = Location(name: "Sydney Harbour Mariott Hotel at Circular Quay",
                         address: "16 Bulletin Pl, Sydney NSW 2000",
                         rating: 4.5,
                         descrition: "Traditional Italian food served in a warm and intimate exposed brick dining space dating from 1861.",
                         phone: "(02) 9251 2929",
                         operatingHour: "Friday: 12–3 pm, 6–10 pm",
                         image: "SydneyHotel")

let start = Location(name: "Melbourne", address: "blablabla", rating: 5, descrition: "airport", phone: "34324342424", operatingHour: "1222")

//Saved Places List example
let list1 = SavedPlace(title: "Cafés", icon: "cup.and.saucer.fill", color: SavedPlaceColor.brown.rawValue)
let list2 = SavedPlace(title: "Brunch Spot", icon: "fork.knife", color: SavedPlaceColor.orange.rawValue)
let list3 = SavedPlace(title: "Jogging Park", icon: "figure.walk", color: SavedPlaceColor.green.rawValue)
let list4 = SavedPlace(title: "Hotel", icon: "bed.double", color: SavedPlaceColor.cyan.rawValue)

// Event Object example
let formatter1: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter
}()

let event1 = Event(type: EventType.flight.rawValue,
                   startTime: formatter1.date(from: "2024/03/07 15:30") ?? .now,
                   endTime: formatter1.date(from: "2024/03/07 16:55") ?? .now,
                   location: start,
                   destination: location1)

let event2 = Event(type: EventType.accomodation.rawValue,
                   startTime: formatter1.date(from: "2024/03/07 17:30") ?? .now,
                   endTime: formatter1.date(from: "2024/03/07 18:30") ?? .now,
                   location: location2)

// Trip object example
let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

let itinerary1 = Trip(image: "Melbourne",
                        title: "Year End Trip 2023",
                       destination: "Melbourne",
                       startDate: formatter.date(from: "2023/12/05") ?? .now,
                       endDate: formatter.date(from: "2023/12/15") ?? .now,
                       totalDays: 11,
                       pax: 2,
                       totalSpent: 2500,
                       savedPlaces: [list1, list2, list3, list4])

let itinerary2 = Trip(image: "Sydney",
                           title: "Mid Sem Trip",
                           destination: "Sydney",
                           startDate: formatter.date(from: "2024/03/07") ?? .now,
                           endDate: formatter.date(from: "2024/03/15") ?? .now,
                           totalDays: 9,
                      days: [1: [event1, event2]]
                           )

let itinerary3 = Trip(image: "Peninsula",
                           title: "Summer Trip",
                           destination: "Peninsula",
                           startDate: formatter.date(from: "2024/01/07") ?? .now,
                           endDate: formatter.date(from: "2024/01/10") ?? .now,
                           totalDays: 4
                           )

let itinerary4 = Trip(image: "Ballarat",
                           title: "One Day Trip to Ballarat",
                           destination: "Sydney",
                           totalDays: 9
                           )

let itinerary5 = Trip(image: "Japan",
                           title: "Year End Trip 2022",
                           destination: "Japan",
                           startDate: formatter.date(from: "2022/12/16") ?? .now,
                           endDate: formatter.date(from: "2022/12/24") ?? .now,
                           totalDays: 9
                           )

let itinerary6 = Trip(image: "PhillipIsland",
                           title: "Weekend Trip to Philip Island",
                           destination: "Phillip Island",
                           startDate: formatter.date(from: "2024/03/07") ?? .now,
                           endDate: formatter.date(from: "2024/03/15") ?? .now,
                           totalDays: 9
                           )

/* Post 1: Normal Text Post */
var post1 = Post(author: user1,
                 title: "Budget Attraction to Sydney",
                 content: "I'm planning a one-week trip to Sydney, and I've heard that the living costs there are quite expensive. I want this trip to be on a budget, as I'm mindful of my expenses. Can anyone suggest some affordable accommodation options or tips for saving money on meals and transportation while still enjoying the best of what Sydney has to offer? Any insider tips on free or low-cost activities and attractions would also be greatly appreciated!")

let post1Comment = [
    Comment(user: user2, post: post1, content:
    "Hey there! I totally understand your concern about expenses in Sydney. One budget-friendly accommodation option I'd recommend is checking out hostels in the city center or nearby suburbs. They often offer affordable dormitory-style rooms and sometimes even private rooms at a fraction of hotel prices. As for dining, exploring local markets like Paddy's Markets or Chinatown can be a great way to sample delicious food without spending too much. And don't miss out on free activities like walking tours of the city or visiting the beautiful beaches like Bondi and Manly. Enjoy your trip!"),
    
    Comment(user: user3, post: post1, content:
    "Hi! Sydney can definitely be pricey, but there are plenty of ways to enjoy the city without breaking the bank. One tip for affordable accommodation is to look into Airbnb options, especially if you're traveling with friends or family and can split the cost. Many hosts offer budget-friendly rooms or entire apartments at competitive prices. When it comes to dining, consider grabbing meals from food trucks or local takeaway joints for tasty yet inexpensive eats. And don't forget to take advantage of free attractions like hiking in the Royal Botanic Garden or exploring the vibrant street art scene in Newtown. Have a fantastic trip!")]

var guide1 = Guide(author: user2 ,itinerary: itinerary1)

var user10 = User(name: "Mark Stank",
                  username: "mark_stank_03",
                  email: "markstank@gmail.com",
                  password: "12345678",
                  posts: [post1],
                  guides: [guide1],
                  followers: [user1, user2, user3],
                  following: [user4, user5, user6],
                  itinerary: [itinerary2, itinerary3, itinerary4, itinerary5, itinerary6]
)
