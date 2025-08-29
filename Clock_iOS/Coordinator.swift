//
//  Coordinator.swift
//  Clock_iOS
//
//  Created by Bergþór Þrastarson on 27/01/2019.
//  Copyright © 2019 Bergþór Þrastarson. All rights reserved.
//

import UIKit

protocol Coordinator {
    var mainViewController: UIViewController { get set }
    
    func start()
}

class MainCoordinator: Coordinator {
    var mainViewController: UIViewController

    init(mainViewController: UIViewController) {
        self.mainViewController = mainViewController
    }
    
    func start() {
        
    }
    
    func secondsValueDidChange(value:Bool) {
        (mainViewController as! ViewController).setShowSeconds(showSeconds: value)
    }
    
    func millisValueDidChange(value:Bool) {
        (mainViewController as! ViewController).setShowMillis(showMillis: value)
    }
    
    func weekNumberValueDidChange(value:Bool) {
        (mainViewController as! ViewController).updateDayName()
    }
    
    func holidayColorDidChange(color: UIColor) {
        // Update main view controller with new holiday color
        // This will be used to update the date label color when it's a holiday
        (mainViewController as! ViewController).updateDayName()
    }
}
