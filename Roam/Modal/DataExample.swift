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
let location1 = Location(name: "Sydney", address: "blablabla", rating: 5, phone: "01234333242342", operatingHour: "1-234", price: "$$")

let location2 = Location(name: "Sydney Harbour Mariott Hotel at Circular Quay",
                         address: "16 Bulletin Pl, Sydney NSW 2000",
                         rating: 4.5,
                         phone: "(02) 9251 2929",
                         operatingHour: "Friday: 12–3 pm, 6–10 pm",
                         image: "SydneyHotel", price: "$$$")

let location3 = Location(name: "Nepal Dining Room", address: "156 Waverley Rd, Malvern East VIC 3145", rating: 4.3, phone: "(03) 9569 3358", operatingHour: "", image: "https://s3-media0.fl.yelpcdn.com/bphoto/LbenF56zi-OnVTKhdyTQ0g/o.jpg", price: "$$")

let start = Location(name: "Melbourne", address: "blablabla", rating: 5, phone: "34324342424", operatingHour: "1222", price: "$$")

let expense1 = Expense(catogery: ExpenseCategory.food.rawValue, title: "Tiramisu", amount: 7.0, day: 1)

let checklist1 = Checklist(title: "Puffer acket", completed: false)
//Saved Places List example
let list1 = SavedPlace(title: "Cafés", icon: SavePlaceIcon.food.rawValue, color: SavedPlaceColor.brown.rawValue, places: [location1, location2])
let list2 = SavedPlace(title: "Brunch Spot", icon: SavePlaceIcon.food.rawValue, color: SavedPlaceColor.orange.rawValue)
let list3 = SavedPlace(title: "Jogging Park", icon: SavePlaceIcon.walk.rawValue, color: SavedPlaceColor.green.rawValue)
let list4 = SavedPlace(title: "Hotel", icon: SavePlaceIcon.bed.rawValue, color: SavedPlaceColor.cyan.rawValue)

// Event Object example
let formatter1: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd HH:mm"
    return formatter
}()

let event1 = Event(type: EventType.flight.rawValue,
                   startDay: 1,
                   endDay: 1, startTime: formatter1.date(from: "2024/03/07 15:30") ?? .now,
                   endTime: formatter1.date(from: "2024/03/07 16:55") ?? .now,
                   location: start,
                   destination: location1)

let event2 = Event(type: EventType.accomodation.rawValue,
                   startDay: 1, 
                   endDay: 3, startTime: formatter1.date(from: "2024/03/07 17:30") ?? .now,
                   endTime: formatter1.date(from: "2024/03/09 11:30") ?? .now,
                   location: location2)

let event3 = Event(type: EventType.restaurant.rawValue,
                   startDay: 1,
                   endDay: 1, startTime: formatter1.date(from: "2024/03/07 20:30") ?? .now,
                   endTime: formatter1.date(from: "2024/03/07 21:30") ?? .now,
                   location: location3)

let event4 = Event(type: EventType.restaurant.rawValue,
                   startDay: 1,
                   endDay: 2,
                   startTime: formatter1.date(from: "2024/03/07 23:30") ?? .now,
                   endTime: formatter1.date(from: "2024/03/08 02:30") ?? .now,
                   location: location3)


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
                      events: [EventPerDay(day: 1, events: [event1, event2, event4]),
                               EventPerDay(day: 2, events: [event4]),
                               EventPerDay(day: 3, events: [event2]),
                               EventPerDay(day: 4, events: []),
                               EventPerDay(day: 5, events: []),
                               EventPerDay(day: 6, events: []),
                               EventPerDay(day: 7, events: []),
                               EventPerDay(day: 8, events: []),
                               EventPerDay(day: 9, events: [])],
                      expenses: [ExpensePerDay(day: 1, expensesPerDay: [expense1]),
                                 ExpensePerDay(day: 2, expensesPerDay: []),
                                 ExpensePerDay(day: 3, expensesPerDay: []),
                                 ExpensePerDay(day: 4, expensesPerDay: []),
                                 ExpensePerDay(day: 5, expensesPerDay: []),
                                 ExpensePerDay(day: 6, expensesPerDay: []),
                                 ExpensePerDay(day: 7, expensesPerDay: []),
                                 ExpensePerDay(day: 8, expensesPerDay: []),
                                 ExpensePerDay(day: 9, expensesPerDay: [])],
                      checklist: [ChecklistCateogry(category_name: "Daily", checklists: [checklist1])]
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
var post1 = Post(authorID: user1.id ?? "",
                 authorName: user1.name ?? "", authorImage: "", title: "Budget Attraction to Sydney",
                 content: "I'm planning a one-week trip to Sydney, and I've heard that the living costs there are quite expensive. I want this trip to be on a budget, as I'm mindful of my expenses. Can anyone suggest some affordable accommodation options or tips for saving money on meals and transportation while still enjoying the best of what Sydney has to offer? Any insider tips on free or low-cost activities and attractions would also be greatly appreciated!")

let post1Comment = [
    Comment(authorID: user2.id ?? "",
            authorName: user2.name ?? "", authorImage: "", content:
    "Hey there! I totally understand your concern about expenses in Sydney. One budget-friendly accommodation option I'd recommend is checking out hostels in the city center or nearby suburbs. They often offer affordable dormitory-style rooms and sometimes even private rooms at a fraction of hotel prices. As for dining, exploring local markets like Paddy's Markets or Chinatown can be a great way to sample delicious food without spending too much. And don't miss out on free activities like walking tours of the city or visiting the beautiful beaches like Bondi and Manly. Enjoy your trip!"),
    
    Comment(authorID: user3.id ?? "",
            authorName: user3.name ?? "", authorImage: "", content:
    "Hi! Sydney can definitely be pricey, but there are plenty of ways to enjoy the city without breaking the bank. One tip for affordable accommodation is to look into Airbnb options, especially if you're traveling with friends or family and can split the cost. Many hosts offer budget-friendly rooms or entire apartments at competitive prices. When it comes to dining, consider grabbing meals from food trucks or local takeaway joints for tasty yet inexpensive eats. And don't forget to take advantage of free attractions like hiking in the Royal Botanic Garden or exploring the vibrant street art scene in Newtown. Have a fantastic trip!")]

var guide1 = Guide(authorID: user2.id ?? "",
                   authorName: user2.name ?? "", authorImage: "",itinerary: itinerary1)

var user10 = User(name: "Mark Stank",
                  username: "mark_stank_03",
                  email: "markstank@gmail.com",
                  password: "12345678",
                  posts: [post1],
                  guides: [guide1],
                  followers: [user1, user2, user3],
                  following: [user4, user5, user6],
                  trips: [itinerary1, itinerary2, itinerary3, itinerary4, itinerary5, itinerary6]
)
