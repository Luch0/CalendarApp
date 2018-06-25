//
//  EventTableViewCell.swift
//  CalendarMobile
//
//  Created by Luis Calle on 6/25/18.
//  Copyright © 2018 Lucho. All rights reserved.
//

import UIKit

class EventTableViewCell: UITableViewCell {

    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
