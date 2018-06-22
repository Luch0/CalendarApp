//
//  CalendarCollectionViewCell.swift
//  CalendarMobile
//
//  Created by Luis Calle on 6/19/18.
//  Copyright © 2018 Lucho. All rights reserved.
//

import UIKit

class CalendarCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var calendarIndicatorView: UIView!
    @IBOutlet weak var dayLabel: UILabel!
        
    override func layoutSubviews() {
        super.layoutSubviews()
        self.calendarIndicatorView.layer.cornerRadius = self.calendarIndicatorView.bounds.width/2.0
    }
    
}
