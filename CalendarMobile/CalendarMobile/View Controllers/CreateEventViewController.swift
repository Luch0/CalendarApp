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
        eventTitleTextField.delegate = self
        setupEventDescriptionToolBar()
    }
    
    @IBAction func createEventPressed(_ sender: UIBarButtonItem) {
        guard let day = day, let month = month, let year = year else {
            print("error here")
            return
        }
        
        guard !eventTitleTextField.text!.isEmpty else {
            showAlert(title: "Error", message: "Must enter a title for the event")
            return
        }
        
        let units: Set<Calendar.Component> = [.hour, .minute]
        let compsStart = Calendar.current.dateComponents(units, from: eventStartTimePicker.date)
        let startTimeStr = "\(compsStart.hour!):\(formatMinute(minutes: compsStart.minute!))"
        let compsEnd = Calendar.current.dateComponents(units, from: eventEndTimePicker.date)
        let endTimeStr = "\(compsEnd.hour!):\(formatMinute(minutes: compsEnd.minute!))"
        
        guard eventStartTimePicker.date < eventEndTimePicker.date else {
            showAlert(title: "Error", message: "Cannot create event with that time!")
            return
        }
        
        var eventDescriptionText = "No description"
        if !eventDescriptionTextView.text.isEmpty {
            eventDescriptionText = eventDescriptionTextView.text
        }
        
        let eventToCreate = Event(_id: nil, title: eventTitleTextField.text!, description: eventDescriptionText, startTime: eventStartTimePicker.date.timeIntervalSince1970, endTime: eventEndTimePicker.date.timeIntervalSince1970, day: day, month: month, year: year, startTimeStr: startTimeStr, endTimeStr: endTimeStr)
        EventsAPIClient.manager.createEvent(event: eventToCreate, completionHandler: { (response) in
            self.delegate?.didCreateNewEvent()
        }, errorHandler: { print($0) })
        self.dismiss(animated: true, completion: nil)
    }
    
    private func formatMinute(minutes: Int) -> String {
        if minutes < 10 { return "0\(minutes)" }
        else { return "\(minutes)" }
    }
    
    private func setupEventDescriptionToolBar() {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([flexibleSpace, doneButton], animated: true)
        eventDescriptionTextView.inputAccessoryView = toolBar
    }
    
    @objc private func doneButtonTapped() {
        eventDescriptionTextView.resignFirstResponder()
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { alert in }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension CreateEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
