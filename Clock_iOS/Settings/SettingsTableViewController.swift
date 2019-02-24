//
//  SettingsTableViewController.swift
//  Clock_iOS
//
//  Created by Bergþór Þrastarson on 5.5.2018.
//  Copyright © 2018 Bergþór Þrastarson. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIImagePickerControllerDelegate {

    @IBOutlet weak var schShowSeconds: UISwitch!
    @IBOutlet weak var schShowMillis: UISwitch!
    @IBOutlet weak var schSundayHoliday: UISwitch!
    weak var coordinator: MainCoordinator!

    override func viewDidLoad() {
        super.viewDidLoad()

        let showSeconds = UserDefaults.standard.bool(forKey: "ShowSeconds")
        let showMillis = UserDefaults.standard.bool(forKey: "ShowMillis")
        let sundaysAsHolidays = UserDefaults.standard.bool(forKey: "SundayIsHoliday")
        schShowSeconds.setOn(showSeconds, animated: false)
        schShowMillis.setOn(showMillis, animated: false)
        schSundayHoliday.setOn(sundaysAsHolidays, animated: false)
    }

    @IBAction func schShowSeconds(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "ShowSeconds")
        coordinator.secondsValueDidChange(value: sender.isOn)
    }
    @IBAction func schShowMilliseconds(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "ShowMillis")
        coordinator.millisValueDidChange(value: sender.isOn)
    }
    @IBAction func sundayIsHolidayToggle(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "SundayIsHoliday")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                // Camera
            }
            if indexPath.row == 2 {
                // Photo Library
            }
        }
    }
}
