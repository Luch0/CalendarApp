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
        
        let postString = "title=\(event.title)&description=\(event.description)&startTime=\(event.startTime)&endTime=\(event.endTime)&day=\(event.day)&month=\(event.month)&year=\(event.year)"
        urlRequest.httpBody = postString.data(using: .utf8)
        NetworkService.manager.performDataTask(with: urlRequest, completionResponse: { (response) in
            completionHandler(response)
        }, errorHandler: { print($0) })
        
    }
    
    func getAllEvents(completionHandler: @escaping ([Event]) -> Void, errorHandler: @escaping (Error) -> Void) {
        let stringURL = "http://localhost:8000/events/"
        guard let url = URL(string: stringURL) else {
            errorHandler(AppError.badURL(str: stringURL))
            return
        }
        let urlRequest = URLRequest(url: url)
        let completion: (Data) -> Void = {(data: Data) in
            do {
                let events = try JSONDecoder().decode([Event].self, from: data)
                completionHandler(events)
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
    
}