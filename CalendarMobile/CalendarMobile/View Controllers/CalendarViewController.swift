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
    
    var events = [Event]() {
        didSet {
            // TODO: weird UI problem must be fixed
            //calendarCollectionView.reloadData()
            calendarEventsTableView.reloadData()
        }
    }
    
    //private var months: [String] = []
    
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
            let oldIndexPath = IndexPath.init(row: currectSelectedDay-1, section: 0)
            let oldCalendarCell = collectionView.cellForItem(at: oldIndexPath) as! CalendarCollectionViewCell
            oldCalendarCell.calendarIndicatorView.layer.borderWidth = 0
            oldCalendarCell.calendarIndicatorView.layer.borderColor = UIColor.clear.cgColor
        }
        currentSelectedDay = indexPath.row + 1
        let calendarCell = collectionView.cellForItem(at: indexPath) as! CalendarCollectionViewCell
        calendarCell.calendarIndicatorView.layer.borderWidth = 1.0
        calendarCell.calendarIndicatorView.layer.borderColor = UIColor.blue.cgColor
    }
}

extension CalendarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 31
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let calendarCell = collectionView.dequeueReusableCell(withReuseIdentifier: "calendar cell", for: indexPath) as! CalendarCollectionViewCell
        calendarCell.dayLabel.text = "\(indexPath.row + 1)"
        return calendarCell
    }
}

extension CalendarViewController: UITableViewDelegate {
    
}

extension CalendarViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Events"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let eventCell = tableView.dequeueReusableCell(withIdentifier: "event cell", for: indexPath)
        let event = events[indexPath.row]
        eventCell.textLabel?.text = event.title
        eventCell.detailTextLabel?.text = event.description
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
