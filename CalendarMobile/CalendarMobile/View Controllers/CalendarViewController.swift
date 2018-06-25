//
//  CalendarViewController.swift
//  CalendarMobile
//
//  Created by Luis Calle on 6/19/18.
//  Copyright © 2018 Lucho. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController {
    @IBOutlet weak var calendarCollectionView: UICollectionView!
    @IBOutlet weak var calendarEventsTableView: UITableView!
    @IBOutlet weak var createEventButton: UIButton!
    
    var currentSelectedDay: Int? {
        didSet {
            if createEventButton.layer.opacity == 1.0 { return }
            createEventButton.isEnabled = true
            UIView.animate(withDuration: 0.2) {
                self.createEventButton.transform = CGAffineTransform.identity
                self.createEventButton.layer.opacity = 1.0
            }
        }
    }
    
    //private var months: [String] = []
    
    var events = [Int: [Event]]() {
        didSet {
            calendarEventsTableView.reloadData()
            calendarCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarCollectionView.delegate = self
        calendarCollectionView.dataSource = self
        calendarEventsTableView.delegate = self
        calendarEventsTableView.dataSource = self
        calendarEventsTableView.bounces = false
        createEventButton.isEnabled = false
        createEventButton.layer.opacity = 0.0
        UIView.animate(withDuration: 0) {
            self.createEventButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
        loadEvents()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        createEventButton.layer.cornerRadius = createEventButton.bounds.width/2.0
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController {
            if let destination = nav.topViewController as? CreateEventViewController {
                destination.day = currentSelectedDay
                destination.month = 6
                destination.year = 2018
                destination.delegate = self
            }
        }
    }
    
    private func loadEvents() {
        EventsAPIClient.manager.getAllEvents(completionHandler: {
            self.events = $0
        }, errorHandler: { print($0) })
    }
    
    @IBAction func createEventPressed(_ sender: UIButton) {
        print("Show create event form")
    }
    
}

extension CalendarViewController: CreateEventViewControllerDelegate {
    func didCreateNewEvent() {
        loadEvents()
    }
}

extension CalendarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let currectSelectedDay = self.currentSelectedDay {
            let oldIndexPath = IndexPath(row: currectSelectedDay-1, section: 0)
            let oldCalendarCell = collectionView.cellForItem(at: oldIndexPath) as! CalendarCollectionViewCell
            oldCalendarCell.calendarIndicatorView.layer.borderWidth = 0
            oldCalendarCell.calendarIndicatorView.layer.borderColor = UIColor.clear.cgColor
        }
        currentSelectedDay = indexPath.row + 1
        let calendarCell = collectionView.cellForItem(at: indexPath) as! CalendarCollectionViewCell
        calendarCell.calendarIndicatorView.layer.borderWidth = 1.0
        calendarCell.calendarIndicatorView.layer.borderColor = UIColor.blue.cgColor
        calendarEventsTableView.reloadData()
    }
}

extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 31
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let calendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendar cell", for: indexPath) as! CalendarCollectionViewCell
        if currentSelectedDay == indexPath.row + 1 {
            calendarCell.calendarIndicatorView.layer.borderWidth = 1
            calendarCell.calendarIndicatorView.layer.borderColor = UIColor.blue.cgColor
        } else {
            calendarCell.calendarIndicatorView.layer.borderWidth = 0
            calendarCell.calendarIndicatorView.layer.borderColor = UIColor.clear.cgColor
        }
        calendarCell.dayLabel.text = "\(indexPath.row + 1)"
        guard let dayEvents = events[indexPath.row + 1] else {
            calendarCell.calendarIndicatorView.backgroundColor = UIColor.clear
            return calendarCell
        }
        if dayEvents.count >= 0 {
            calendarCell.calendarIndicatorView.backgroundColor = UIColor.green
        } else {
            calendarCell.calendarIndicatorView.backgroundColor = UIColor.clear
        }
        return calendarCell
    }
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        EventsAPIClient.manager.deleteEvent(event: events[currentSelectedDay!]![indexPath.row], completionHandler: { (response) in
            self.loadEvents()
        }, errorHandler: { print($0) })
    }
}

extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let currentSelectedDay = currentSelectedDay else {
            return "Day Events"
        }
        return "June \(currentSelectedDay), 2018"
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        
//        guard let currentSelectedDay = currentSelectedDay, let numEvents = events[currentSelectedDay] else {
//            return 0
//        }
//        
//        var numOfSections: Int = 0
//        if numEvents.count > 0 {
//            tableView.backgroundView = nil
//            tableView.separatorStyle = .singleLine
//            numOfSections = 1
//        } else {
//            let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
//            noDataLabel.text = "No events this day"
//            noDataLabel.font = UIFont.systemFont(ofSize: 22, weight: .medium)
//            noDataLabel.textAlignment = .center
//            tableView.backgroundView = noDataLabel
//            tableView.separatorStyle = .none
//        }
//        return numOfSections
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currentSelectedDay = currentSelectedDay else {
            return 0
        }
        return (events[currentSelectedDay] ?? []).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "event cell", for: indexPath)
        guard let currentSelectedDay = currentSelectedDay, let arrayEvents =  events[currentSelectedDay] else {
            return UITableViewCell()
        }
        let event = arrayEvents[indexPath.row]
        eventCell.textLabel?.text = event.title
        eventCell.detailTextLabel?.text = "\(event.startTimeStr) - \(event.endTimeStr)"
        return eventCell
    }
}

extension CalendarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numColumns: CGFloat = 7.0
        let numRows: CGFloat = 5.0
        let collectionViewWidth: CGFloat = collectionView.bounds.width
        let collectionViewHeight: CGFloat = collectionView.bounds.height
        return CGSize(width: collectionViewWidth/numColumns, height: collectionViewHeight/numRows)
    }
}
