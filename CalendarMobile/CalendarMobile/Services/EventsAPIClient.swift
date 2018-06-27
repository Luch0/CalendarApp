//
//  EventsAPIClient.swift
//  CalendarMobile
//
//  Created by Luis Calle on 6/20/18.
//  Copyright © 2018 Lucho. All rights reserved.
//

import Foundation

struct EventsAPIClient {
    private init() { }
    static let manager = EventsAPIClient()
    
    func createEvent(event: Event, completionHandler: @escaping (URLResponse) -> Void, errorHandler: @escaping (Error) -> Void) {
        let stringURL = "http://localhost:8000/events/"
        guard let url = URL(string: stringURL) else {
            errorHandler(AppError.badURL(str: stringURL))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let postString = "title=\(event.title)&description=\(event.description)&startTime=\(event.startTime)&endTime=\(event.endTime)&day=\(event.day)&month=\(event.month)&year=\(event.year)&startTimeStr=\(event.startTimeStr)&endTimeStr=\(event.endTimeStr)"
        urlRequest.httpBody = postString.data(using: .utf8)
        NetworkService.manager.performDataTask(with: urlRequest, completionResponse: { (response) in
            completionHandler(response)
        }, errorHandler: { print($0) })
        
    }
    
    func getAllEvents(completionHandler: @escaping ([Int:[Event]]) -> Void, errorHandler: @escaping (Error) -> Void) {
        let stringURL = "http://localhost:8000/events/"
        guard let url = URL(string: stringURL) else {
            errorHandler(AppError.badURL(str: stringURL))
            return
        }
        let urlRequest = URLRequest(url: url)
        var organizedEvents = [Int: [Event]]()
        let completion: (Data) -> Void = {(data: Data) in
            do {
                let events = try JSONDecoder().decode([Event].self, from: data)
                for event in events {
                    if let eventsSoFar = organizedEvents[event.day] {
                        var toAddNewEvent: [Event] = eventsSoFar
                        toAddNewEvent.append(event)
                        organizedEvents.updateValue(toAddNewEvent, forKey: event.day)
                    } else {
                        organizedEvents[event.day] = [event]
                    }
                }
                completionHandler(organizedEvents)
            }
            catch {
                errorHandler(AppError.couldNotParseJSON(rawError: error))
            }
        }
        NetworkService.manager.performDataTask(with: urlRequest, completionHandler: completion, errorHandler: errorHandler)
    }
    
    
    func getEventWith(id: String, completionHandler: @escaping (Event) -> Void, errorHandler: @escaping (Error) -> Void) {
        let stringURL = "http://localhost:8000/events/\(id)"
        guard let url = URL(string: stringURL) else {
            errorHandler(AppError.badURL(str: stringURL))
            return
        }
        let urlRequest = URLRequest(url: url)
        let completion: (Data) -> Void = {(data: Data) in
            do {
                let event = try JSONDecoder().decode(Event.self, from: data)
                completionHandler(event)
            }
            catch {
                errorHandler(AppError.couldNotParseJSON(rawError: error))
            }
        }
        NetworkService.manager.performDataTask(with: urlRequest, completionHandler: completion, errorHandler: errorHandler)
    }
    
    
    func deleteEvent(event: Event, completionHandler: @escaping (URLResponse) -> Void, errorHandler: @escaping (Error) -> Void) {
        let stringURL = "http://localhost:8000/events/\(event._id!)"
        guard let url = URL(string: stringURL) else {
            errorHandler(AppError.badURL(str: stringURL))
            return
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        NetworkService.manager.performDataTask(with: urlRequest, completionResponse: { (response) in
            completionHandler(response)
        }, errorHandler: { print($0) })
        
    }
    
    
}
