//
//  CreateEventViewController.swift
//  CalendarMobile
//
//  Created by Luis Calle on 6/20/18.
//  Copyright © 2018 Lucho. All rights reserved.
//

import UIKit

protocol CreateEventViewControllerDelegate: class {
    func didCreateNewEvent()
}

class CreateEventViewController: UIViewController {
    @IBOutlet weak var eventTitleTextField: UITextField!
    @IBOutlet weak var eventDescriptionTextView: UITextView!
    @IBOutlet weak var eventStartTimePicker: UIDatePicker!
    @IBOutlet weak var eventEndTimePicker: UIDatePicker!
    
    weak var delegate: CreateEventViewControllerDelegate?
    
    var day: Int?
    var month: Int?
    var year: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func createEventPressed(_ sender: UIBarButtonItem) {
        guard let day = day, let month = month, let year = year else {
            print("error here")
            return
        }
        // TODO: Handle when minutes is less that 10
        let units: Set<Calendar.Component> = [.hour, .minute]
        let compsStart = Calendar.current.dateComponents(units, from: eventStartTimePicker.date)
        let startTimeStr = "\(compsStart.hour!):\(compsStart.minute!)"
        let compsEnd = Calendar.current.dateComponents(units, from: eventEndTimePicker.date)
        let endTimeStr = "\(compsEnd.hour!):\(compsEnd.minute!)"
        
        let eventToCreate = Event(_id: nil, title: eventTitleTextField.text!, description: eventDescriptionTextView.text, startTime: eventStartTimePicker.date.timeIntervalSince1970, endTime: eventEndTimePicker.date.timeIntervalSince1970, day: day, month: month, year: year, startTimeStr: startTimeStr, endTimeStr: endTimeStr)
        EventsAPIClient.manager.createEvent(event: eventToCreate, completionHandler: { (response) in
            print((response as! HTTPURLResponse).statusCode)
            self.delegate?.didCreateNewEvent()
        }, errorHandler: { print($0) })
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
