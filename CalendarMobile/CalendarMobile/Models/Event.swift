//
//  Event.swift
//  CalendarMobile
//
//  Created by Luis Calle on 6/20/18.
//  Copyright © 2018 Lucho. All rights reserved.
//

import Foundation

struct Event: Codable {
    let _id: String?
    let title: String
    let description: String
    let startTime: Double
    let endTime: Double
    let day: Int
    let month: Int
    let year: Int
    let startTimeStr: String
    let endTimeStr: String
}
