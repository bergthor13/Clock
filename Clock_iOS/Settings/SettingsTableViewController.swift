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
    @IBOutlet weak var schShowWeekNumber: UISwitch!
    @IBOutlet weak var holidayColorView: UIView!
    weak var coordinator: MainCoordinator!

    override func viewDidLoad() {
        super.viewDidLoad()

        let showSeconds = UserDefaults.standard.bool(forKey: "ShowSeconds")
        let showMillis = UserDefaults.standard.bool(forKey: "ShowMillis")
        let sundaysAsHolidays = UserDefaults.standard.bool(forKey: "SundayIsHoliday")
        let showWeekNumber = UserDefaults.standard.bool(forKey: "ShowWeekNumber")
        schShowSeconds.setOn(showSeconds, animated: false)
        schShowMillis.setOn(showMillis, animated: false)
        schSundayHoliday.setOn(sundaysAsHolidays, animated: false)
        schShowWeekNumber.setOn(showWeekNumber, animated: false)
        
        // Setup holiday color will be called after table view loads
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Setup holiday color after table view is fully loaded
        setupHolidayColor()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Update corner radius after layout is complete
        setupHolidayColorAppearance()
    }
    
    private func setupHolidayColor() {
        // Try to find color view - either from outlet or by searching
        let colorView = findHolidayColorView()
        
        guard let view = colorView else {
            print("Warning: Could not find holiday color view")
            return
        }
        
        // Store reference for future use
        holidayColorView = view
        
        // Load saved holiday color or use default
        let savedColor = loadHolidayColor()
        view.backgroundColor = savedColor
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(holidayColorTapped))
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
        // Setup appearance will be called in viewDidLayoutSubviews
    }
    
    private func findHolidayColorView() -> UIView? {
        // First try the outlet
        if let outlet = holidayColorView {
            return outlet
        }
        
        // Fallback: search for the view by traversing the Holiday Color cell
        let holidayIndexPath = IndexPath(row: 0, section: 2)
        if let cell = tableView.cellForRow(at: holidayIndexPath) {
            return findColorViewInView(cell.contentView)
        }
        
        return nil
    }
    
    private func findColorViewInView(_ view: UIView) -> UIView? {
        // Look for a view that looks like a color indicator
        for subview in view.subviews {
            // Check if this view has the characteristics of a color view
            if subview.frame.width > 20 && subview.frame.width < 40 &&
               subview.frame.height > 20 && subview.frame.height < 40 &&
               subview.backgroundColor != UIColor.clear &&
               subview.backgroundColor != UIColor.white {
                return subview
            }
            
            // Recursively search in subviews
            if let found = findColorViewInView(subview) {
                return found
            }
        }
        return nil
    }
    
    private func setupHolidayColorAppearance() {
        guard let colorView = holidayColorView else { return }
        
        // Make it a perfect circle
        colorView.layer.cornerRadius = min(colorView.frame.width, colorView.frame.height) / 2
        colorView.layer.borderWidth = 2.0
        
        // Use system color if available, fallback for older iOS
        if #available(iOS 13.0, *) {
            colorView.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            colorView.layer.borderColor = UIColor.lightGray.cgColor
        }
        colorView.clipsToBounds = true
        
        // Add subtle shadow for better visual appearance
        colorView.layer.shadowColor = UIColor.black.cgColor
        colorView.layer.shadowOffset = CGSize(width: 0, height: 1)
        colorView.layer.shadowRadius = 2
        colorView.layer.shadowOpacity = 0.2
        colorView.layer.masksToBounds = false
    }
    
    @objc private func holidayColorTapped() {
        // Find the Holiday Color cell for popover positioning
        let holidayIndexPath = IndexPath(row: 0, section: 2)
        presentColorPicker(sourceIndexPath: holidayIndexPath)
    }
    
    private func loadHolidayColor() -> UIColor {
        // Try to load from UserDefaults
        if let colorData = UserDefaults.standard.data(forKey: "HolidayColor") {
            do {
                if let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
                    return color
                }
            } catch {
                print("Error loading holiday color: \(error)")
            }
        }
        
        // Default holiday color (red)
        return UIColor(red: 255.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)
    }
    
    private func saveHolidayColor(_ color: UIColor) {
        do {
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
            UserDefaults.standard.set(colorData, forKey: "HolidayColor")
        } catch {
            print("Error saving holiday color: \(error)")
        }
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
    
    @IBAction func showWeekNumberToggle(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "ShowWeekNumber")
        
        // Uppfæra UI-ið strax
        if let coordinator = coordinator {
            coordinator.weekNumberValueDidChange(value: sender.isOn)
        }
    }
    
    private func presentColorPicker(sourceIndexPath: IndexPath? = nil) {
        // Create a custom view controller for better color preview
        presentCustomColorPicker(sourceIndexPath: sourceIndexPath)
    }
    
    private func presentCustomColorPicker(sourceIndexPath: IndexPath? = nil) {
        let alert = UIAlertController(title: "Veldu lit fyrir frídaga", message: "Veldu einn af þessum litum:", preferredStyle: .actionSheet)
        
        // Predefined colors
        let colors: [(name: String, color: UIColor)] = [
            ("Rauður", UIColor(red: 255.0/255.0, green: 75.0/255.0, blue: 75.0/255.0, alpha: 1.0)),
            ("Blár", UIColor(red: 50.0/255.0, green: 150.0/255.0, blue: 255.0/255.0, alpha: 1.0)),
            ("Grænn", UIColor(red: 75.0/255.0, green: 200.0/255.0, blue: 75.0/255.0, alpha: 1.0)),
            ("Fjólublár", UIColor(red: 150.0/255.0, green: 75.0/255.0, blue: 255.0/255.0, alpha: 1.0)),
            ("Appelsínugulur", UIColor(red: 255.0/255.0, green: 150.0/255.0, blue: 0.0/255.0, alpha: 1.0)),
            ("Bleikur", UIColor(red: 255.0/255.0, green: 100.0/255.0, blue: 150.0/255.0, alpha: 1.0)),
            ("Gullinn", UIColor(red: 255.0/255.0, green: 215.0/255.0, blue: 0.0/255.0, alpha: 1.0)),
            ("Dökkrauður", UIColor(red: 139.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0))
        ]
        
        for (name, color) in colors {
            let action = UIAlertAction(title: name, style: .default) { _ in
                self.updateHolidayColor(color)
            }
            
            // Create color preview for the action
            let colorPreview = self.createColorPreviewImage(color: color)
            action.setValue(colorPreview, forKey: "image")
            
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Hætta við", style: .cancel)
        alert.addAction(cancelAction)
        
        // For iPad support - setup popover
        if let popover = alert.popoverPresentationController {
            if let indexPath = sourceIndexPath,
               let cell = tableView.cellForRow(at: indexPath) {
                // Use the table cell as source
                popover.sourceView = cell
                popover.sourceRect = cell.bounds
            } else if let colorView = holidayColorView {
                // Fallback to color view if available
                popover.sourceView = colorView
                popover.sourceRect = colorView.bounds
            } else {
                // Last resort fallback
                popover.sourceView = self.view
                popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
        }
        
        present(alert, animated: true)
    }
    
    private func createColorPreviewImage(color: UIColor) -> UIImage? {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Draw circle background
            color.setFill()
            let rect = CGRect(origin: .zero, size: size).insetBy(dx: 1, dy: 1)
            let circlePath = UIBezierPath(ovalIn: rect)
            circlePath.fill()
            
            // Add border
            UIColor.darkGray.setStroke()
            circlePath.lineWidth = 1.0
            circlePath.stroke()
        }
        
        // Prevent the image from being used as a template (which would tint it)
        return image.withRenderingMode(.alwaysOriginal)
    }
    
    private func updateHolidayColor(_ color: UIColor) {
        // Update UI
        holidayColorView?.backgroundColor = color
        
        // Refresh appearance to ensure circle stays perfect
        setupHolidayColorAppearance()
        
        // Save to UserDefaults
        saveHolidayColor(color)
        
        // Notify coordinator if needed
        coordinator?.holidayColorDidChange(color: color)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                // Camera
            }
            if indexPath.row == 2 {
                // Photo Library
            }
        } else if indexPath.section == 2 { // Holidays section
            if indexPath.row == 0 { // Holiday Color cell
                presentColorPicker(sourceIndexPath: indexPath)
            }
        }
    }
}
